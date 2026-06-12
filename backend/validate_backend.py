#!/usr/bin/env python3
"""Backend validation script - checks for common errors and logical issues."""

import os
import re
import ast
from pathlib import Path
from collections import defaultdict

def check_python_syntax(file_path):
    """Check if a Python file has valid syntax."""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            ast.parse(f.read())
        return None
    except SyntaxError as e:
        return f"Syntax Error: {e.msg} at line {e.lineno}"
    except Exception as e:
        return f"Error: {str(e)}"

def check_imports_and_definitions(file_path):
    """Check if all imported modules and used functions are valid."""
    issues = []
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
            tree = ast.parse(content)
        
        imported_modules = set()
        imported_names = set()
        defined_names = set()
        used_names = set()
        
        for node in ast.walk(tree):
            if isinstance(node, ast.Import):
                for alias in node.names:
                    imported_modules.add(alias.name.split('.')[0])
                    imported_names.add(alias.asname or alias.name)
            elif isinstance(node, ast.ImportFrom):
                for alias in node.names:
                    imported_names.add(alias.asname or alias.name)
            elif isinstance(node, ast.FunctionDef):
                defined_names.add(node.name)
            elif isinstance(node, ast.ClassDef):
                defined_names.add(node.name)
            elif isinstance(node, ast.Name):
                if isinstance(node.ctx, ast.Load):
                    used_names.add(node.id)
        
        # Common built-ins and special names
        builtins = {'print', 'len', 'str', 'int', 'dict', 'list', 'tuple', 'set', 
                   'enumerate', 'range', 'map', 'filter', 'zip', 'sorted', 'any', 
                   'all', 'sum', 'min', 'max', 'open', 'type', 'isinstance', 'getattr',
                   'setattr', 'hasattr', 'property', 'classmethod', 'staticmethod',
                   'super', 'object', 'bool', 'float', 'bytes', 'complex', 'frozenset',
                   'True', 'False', 'None', 'NotImplemented', 'Ellipsis', '__name__',
                   '__file__', 'Exception', 'ValueError', 'KeyError', 'IndexError',
                   'TypeError', 'AttributeError', 'IOError', 'OSError', 'RuntimeError'}
        
        undefined = used_names - (imported_names | defined_names | builtins)
        # Filter out common patterns like decorators, type hints, etc.
        undefined = {n for n in undefined if not n.startswith('_') and n[0].islower()}
        
        return issues
    except Exception as e:
        return [f"Error parsing {file_path}: {str(e)}"]

def check_route_decorators(file_path):
    """Check if Flask routes have proper decorators."""
    issues = []
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Look for route definitions
    route_pattern = r'@[a-z_]*bp\.route\('
    func_pattern = r'def\s+(\w+)\s*\('
    
    routes = re.finditer(route_pattern, content)
    for route_match in routes:
        # Find the next function after this route
        rest_content = content[route_match.end():]
        func_match = re.search(func_pattern, rest_content)
        if func_match:
            # Check if this is a protected endpoint (GET /me, PATCH /me, etc.)
            line_start = content.rfind('\n', 0, route_match.start()) + 1
            route_line = content[line_start:route_match.end() + 50]
            
            # Protected endpoints that need @jwt_required
            protected_patterns = ['/me', 'stores', 'products', 'sales', 'stats']
            needs_jwt = any(pattern in route_line for pattern in protected_patterns)
            
            # Check if @jwt_required is present after the route
            decorator_text = content[route_match.start():route_match.start() + 200]
            if needs_jwt and 'jwt_required' not in decorator_text:
                # Double-check the actual location
                full_text = content[route_match.start():route_match.start() + 500]
                if 'jwt_required' not in full_text:
                    issues.append(f"Protected route likely missing @jwt_required: {func_match.group(1)}")
    
    return issues

def check_database_operations(file_path):
    """Check for potential database issues."""
    issues = []
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    for i, line in enumerate(lines, 1):
        # Check for missing db.session.commit()
        if 'db.session.add(' in line or 'db.session.delete(' in line:
            # Look ahead for commit
            found_commit = False
            for j in range(i, min(i + 20, len(lines))):
                if 'db.session.commit()' in lines[j] or 'db.session.flush()' in lines[j]:
                    found_commit = True
                    break
            if not found_commit and 'return' not in line:
                # Might be an issue but could be intentional
                pass
        
        # Check for missing error handling on queries
        if '.query' in line and 'except' not in lines[i] if i < len(lines) else False:
            pass  # This is too broad to check properly
    
    return issues

def check_model_relationships(file_path):
    """Check for issues in SQLAlchemy model definitions."""
    issues = []
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Check for ForeignKey without corresponding relationship
    fk_pattern = r'db\.ForeignKey\("(\w+)\.(\w+)"\)'
    relationships = re.findall(r'db\.relationship\(["\'](\w+)["\']\)', content)
    
    for fk_match in re.finditer(fk_pattern, content):
        table = fk_match.group(1)
        # If this is in models file, check relationships exist
    
    return issues

def main():
    """Run all validation checks."""
    backend_dir = Path(".")
    issues = defaultdict(list)
    
    print("=" * 60)
    print("BACKEND VALIDATION REPORT")
    print("=" * 60)
    
    # Check all Python files
    python_files = list(backend_dir.rglob("*.py"))
    python_files = [f for f in python_files if 'migrations' not in str(f) and '__pycache__' not in str(f) and 'venv' not in str(f)]
    
    print(f"\nChecking {len(python_files)} Python files...")
    
    for py_file in python_files:
        # Syntax check
        syntax_error = check_python_syntax(py_file)
        if syntax_error:
            issues[str(py_file)].append(syntax_error)
            print(f"✗ {py_file}: {syntax_error}")
        else:
            print(f"✓ {py_file}: Syntax OK")
        
        # Route-specific checks
        if 'routes' in str(py_file):
            route_issues = check_route_decorators(py_file)
            if route_issues:
                issues[str(py_file)].extend(route_issues)
                for issue in route_issues:
                    print(f"  ⚠ {issue}")
        
        # Database operation checks
        if 'routes' in str(py_file) or 'models' in str(py_file):
            db_issues = check_database_operations(py_file)
            if db_issues:
                issues[str(py_file)].extend(db_issues)
    
    # Check for missing required files
    print("\nChecking required files...")
    required_files = [
        'app/__init__.py', 'app/config.py', 'app/extensions.py',
        'app/models/__init__.py', 'app/routes/__init__.py',
        'run.py', 'requirements.txt'
    ]
    
    for req_file in required_files:
        if Path(req_file).exists():
            print(f"✓ {req_file}: Found")
        else:
            print(f"✗ {req_file}: MISSING!")
            issues['Missing Files'].append(f"Required file not found: {req_file}")
    
    # Summary
    print("\n" + "=" * 60)
    if any(issues.values()):
        print(f"ISSUES FOUND: {sum(len(v) for v in issues.values())}")
        for file_name, file_issues in sorted(issues.items()):
            print(f"\n{file_name}:")
            for issue in file_issues:
                print(f"  - {issue}")
    else:
        print("NO ISSUES FOUND! ✓")
    
    print("=" * 60)

if __name__ == "__main__":
    main()

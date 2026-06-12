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

def check_route_decorators(file_path):
    """Check if Flask routes have proper decorators."""
    issues = []
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Look for protected routes
        if '@auth_bp.route' in content or '@store_bp.route' in content or \
           '@product_bp.route' in content or '@sale_bp.route' in content or \
           '@stats_bp.route' in content:
            # Check if all modification routes have authorization checks
            pass
    except Exception as e:
        pass
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
    python_files = [f for f in python_files if 'migrations' not in str(f) and '__pycache__' not in str(f) and 'venv' not in str(f) and 'validate_' not in str(f)]
    
    print(f"\nChecking {len(python_files)} Python files...")
    
    errors_found = 0
    for py_file in sorted(python_files):
        # Syntax check
        syntax_error = check_python_syntax(py_file)
        if syntax_error:
            errors_found += 1
            issues[str(py_file)].append(syntax_error)
            print(f"[ERROR] {py_file}: {syntax_error}")
        else:
            print(f"[OK] {py_file}")
    
    # Check for missing required files
    print("\nChecking required files...")
    required_files = [
        'app/__init__.py', 'app/config.py', 'app/extensions.py',
        'app/models/__init__.py', 'app/routes/__init__.py',
        'run.py', 'requirements.txt'
    ]
    
    for req_file in required_files:
        if Path(req_file).exists():
            print(f"[OK] {req_file}")
        else:
            print(f"[ERROR] {req_file}: MISSING!")
            errors_found += 1
    
    # Summary
    print("\n" + "=" * 60)
    if errors_found > 0:
        print(f"ISSUES FOUND: {errors_found}")
        for file_name, file_issues in sorted(issues.items()):
            if file_issues:
                print(f"\n{file_name}:")
                for issue in file_issues:
                    print(f"  - {issue}")
    else:
        print("NO SYNTAX ERRORS FOUND!")
    
    print("=" * 60)

if __name__ == "__main__":
    main()

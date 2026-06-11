import re


def validate_registration(data):
    errors = {}

    full_name = data.get("full_name", "").strip()
    email = data.get("email", "").strip()
    password = data.get("password", "")

    # Full Name
    if not full_name:
        errors["full_name"] = "Full name is required"
    elif len(full_name) < 3:
        errors["full_name"] = "Full name must be at least 3 characters"
    elif len(full_name) > 100:
        errors["full_name"] = "Full name cannot exceed 100 characters"

    # Email
    email_regex = r"^[^\s@]+@[^\s@]+\.[^\s@]+$"

    if not email:
        errors["email"] = "Email is required"
    elif not re.match(email_regex, email):
        errors["email"] = "Invalid email format"

    # Password
    if not password:
        errors["password"] = "Password is required"
    elif len(password) < 8:
        errors["password"] = "Password must be at least 8 characters"
    elif not re.search(r"[A-Z]", password):
        errors["password"] = "Password must contain at least one uppercase letter"
    elif not re.search(r"[a-z]", password):
        errors["password"] = "Password must contain at least one lowercase letter"
    elif not re.search(r"\d", password):
        errors["password"] = "Password must contain at least one number"

    return errors
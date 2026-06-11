from flask import Blueprint, request, jsonify
from flask_jwt_extended import (
    create_access_token,
    create_refresh_token,
    jwt_required,
    get_jwt_identity,
)
import os
import urllib.request
import json
from app.utils.validators import validate_registration
from app.extensions import db
from app.models.user import User

auth_bp = Blueprint("auth", __name__)

GOOGLE_CLIENT_ID = os.getenv("GOOGLE_CLIENT_ID", "")


def _user_payload(user):
    return {
        "id": user.id,
        "full_name": user.full_name,
        "email": user.email,
        "language": user.language,
    }


def _token_response(user):
    return {
        "success": True,
        "access_token": create_access_token(identity=str(user.id)),
        "refresh_token": create_refresh_token(identity=str(user.id)),
        "user": _user_payload(user),
    }


def _verify_google_token(id_token):
    url = f"https://oauth2.googleapis.com/tokeninfo?id_token={id_token}"
    try:
        with urllib.request.urlopen(url, timeout=10) as response:
            data = json.loads(response.read().decode())
    except Exception:
        return None

    if GOOGLE_CLIENT_ID and data.get("aud") != GOOGLE_CLIENT_ID:
        return None

    return data


@auth_bp.route("/google", methods=["POST"])
def google_auth():
    data = request.get_json() or {}
    id_token = data.get("id_token", "")

    if not id_token:
        return jsonify({"success": False, "message": "ID token is required"}), 400

    google_data = _verify_google_token(id_token)
    if not google_data:
        return jsonify({"success": False, "message": "Invalid Google token"}), 401

    google_id = google_data.get("sub")
    email = google_data.get("email", "").strip().lower()
    full_name = data.get("full_name") or google_data.get("name") or email.split("@")[0]

    if not google_id or not email:
        return jsonify({"success": False, "message": "Invalid Google account data"}), 400

    user = User.query.filter(
        (User.google_id == google_id) | (User.email == email)
    ).first()

    if user:
        if not user.google_id:
            user.google_id = google_id
        if not user.full_name or user.full_name == email.split("@")[0]:
            user.full_name = full_name
        db.session.commit()
    else:
        user = User(
            full_name=full_name,
            email=email,
            google_id=google_id,
        )
        db.session.add(user)
        db.session.commit()

    return jsonify(_token_response(user)), 200


@auth_bp.route("/login", methods=["POST"])
def login():
    data = request.get_json()

    email = data.get("email", "").strip().lower()
    password = data.get("password", "")

    if not email or not password:
        return jsonify({
            "success": False,
            "message": "Email and password are required",
        }), 400

    user = User.query.filter_by(email=email).first()

    if not user or not user.check_password(password):
        return jsonify({
            "success": False,
            "message": "Invalid email or password",
        }), 401

    return jsonify(_token_response(user)), 200


@auth_bp.route("/register", methods=["POST"])
def register():
    data = request.get_json()
    errors = validate_registration(data)
    if errors:
        return jsonify({
            "success": False,
            "errors": errors,
        }), 400

    full_name = data.get("full_name", "").strip()
    email = data.get("email", "").strip().lower()
    password = data.get("password", "")

    existing_user = User.query.filter_by(email=email).first()
    if existing_user:
        return jsonify({
            "success": False,
            "message": "Email already exists",
        }), 409

    user = User(full_name=full_name, email=email)
    user.set_password(password)

    db.session.add(user)
    db.session.commit()

    return jsonify(_token_response(user)), 201


@auth_bp.route("/refresh", methods=["POST"])
@jwt_required(refresh=True)
def refresh():
    user_id = int(get_jwt_identity())
    user = User.query.get(user_id)

    if not user:
        return jsonify({"success": False, "message": "User not found"}), 404

    return jsonify({
        "success": True,
        "access_token": create_access_token(identity=str(user.id)),
    }), 200


@auth_bp.route("/me", methods=["GET"])
@jwt_required()
def me():
    user_id = int(get_jwt_identity())
    user = User.query.get(user_id)

    if not user:
        return jsonify({"message": "User not found"}), 404

    return jsonify(_user_payload(user))


@auth_bp.route("/me", methods=["PATCH"])
@jwt_required()
def update_me():
    user_id = int(get_jwt_identity())
    user = User.query.get(user_id)

    if not user:
        return jsonify({"message": "User not found"}), 404

    data = request.get_json() or {}

    if "full_name" in data:
        full_name = data["full_name"].strip()
        if len(full_name) < 3:
            return jsonify({"message": "Full name must be at least 3 characters"}), 400
        user.full_name = full_name

    if "language" in data:
        user.language = data["language"]

    db.session.commit()

    return jsonify(_user_payload(user))

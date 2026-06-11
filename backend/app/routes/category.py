from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity

from app.extensions import db
from app.models.category import Category
from app.models.store_member import StoreMember

category_bp = Blueprint("category", __name__)


def _user_can_access_store(user_id, store_id):
    return StoreMember.query.filter_by(
        store_id=store_id,
        user_id=user_id,
    ).first() is not None


@category_bp.route("/", methods=["GET"])
@jwt_required()
def get_categories():
    user_id = int(get_jwt_identity())
    store_id = request.args.get("store_id")

    if not store_id:
        return jsonify({"message": "store_id is required"}), 400

    if not _user_can_access_store(user_id, int(store_id)):
        return jsonify({"message": "Access denied"}), 403

    categories = Category.query.filter_by(store_id=store_id).all()

    return jsonify([
        {"id": c.id, "name": c.name, "store_id": c.store_id}
        for c in categories
    ])


@category_bp.route("/", methods=["POST"])
@jwt_required()
def create_category():
    user_id = int(get_jwt_identity())
    data = request.get_json()

    store_id = data.get("store_id")
    name = data.get("name", "").strip()

    if not store_id or not name:
        return jsonify({"message": "store_id and name are required"}), 400

    if not _user_can_access_store(user_id, int(store_id)):
        return jsonify({"message": "Access denied"}), 403

    category = Category(store_id=store_id, name=name)
    db.session.add(category)
    db.session.commit()

    return jsonify({
        "id": category.id,
        "name": category.name,
        "store_id": category.store_id,
    }), 201

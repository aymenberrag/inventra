from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity

from app.extensions import db
from app.models.store import Store
from app.models.store_member import StoreMember
from app.models.product import Product

store_bp = Blueprint("store", __name__)


def _store_payload(store):
    return {
        "id": store.id,
        "name": store.name,
        "address": store.address,
        "currency": store.currency or "USD",
    }


def _user_can_access_store(user_id, store_id):
    return StoreMember.query.filter_by(
        store_id=store_id,
        user_id=user_id,
    ).first() is not None


@store_bp.route("/", methods=["POST"])
@jwt_required()
def create_store():
    user_id = int(get_jwt_identity())
    data = request.get_json()

    name = data.get("name", "").strip()
    address = data.get("address", "").strip() or None
    currency = data.get("currency", "USD")

    if not name:
        return jsonify({"message": "Store name is required"}), 400

    store = Store(
        name=name,
        address=address,
        currency=currency,
        owner_id=user_id,
    )

    db.session.add(store)
    db.session.commit()

    member = StoreMember(
        store_id=store.id,
        user_id=user_id,
        role="owner",
    )

    db.session.add(member)
    db.session.commit()

    return jsonify({
        "message": "Store created",
        "store": _store_payload(store),
    }), 201


@store_bp.route("/", methods=["GET"])
@jwt_required()
def get_stores():
    user_id = int(get_jwt_identity())

    stores = Store.query.join(StoreMember).filter(
        StoreMember.user_id == user_id
    ).all()

    return jsonify([_store_payload(s) for s in stores])


@store_bp.route("/<int:store_id>", methods=["GET"])
@jwt_required()
def get_store(store_id):
    user_id = int(get_jwt_identity())

    if not _user_can_access_store(user_id, store_id):
        return jsonify({"message": "Access denied"}), 403

    store = Store.query.get(store_id)
    if not store:
        return jsonify({"message": "Store not found"}), 404

    return jsonify(_store_payload(store))


@store_bp.route("/<int:store_id>", methods=["PATCH"])
@jwt_required()
def update_store(store_id):
    user_id = int(get_jwt_identity())

    if not _user_can_access_store(user_id, store_id):
        return jsonify({"message": "Access denied"}), 403

    store = Store.query.get(store_id)
    if not store:
        return jsonify({"message": "Store not found"}), 404

    data = request.get_json() or {}

    if "name" in data:
        name = data["name"].strip()
        if not name:
            return jsonify({"message": "Store name is required"}), 400
        store.name = name

    if "address" in data:
        store.address = data["address"].strip() or None

    if "currency" in data:
        store.currency = data["currency"]

    db.session.commit()

    return jsonify(_store_payload(store))


@store_bp.route("/<int:store_id>/notifications", methods=["GET"])
@jwt_required()
def get_notifications(store_id):
    user_id = int(get_jwt_identity())

    if not _user_can_access_store(user_id, store_id):
        return jsonify({"message": "Access denied"}), 403

    low_stock = Product.query.filter(
        Product.store_id == store_id,
        Product.quantity <= Product.low_stock_threshold,
    ).all()

    return jsonify([
        {
            "id": p.id,
            "type": "low_stock",
            "message": f"{p.name} is low on stock ({p.quantity} left)",
            "product_id": p.id,
            "product_name": p.name,
            "quantity": p.quantity,
        }
        for p in low_stock
    ])

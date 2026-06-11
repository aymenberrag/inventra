from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity

from app.extensions import db
from app.models.product import Product
from app.models.store_member import StoreMember

product_bp = Blueprint("product", __name__)


def _user_can_access_store(user_id, store_id):
    return StoreMember.query.filter_by(
        store_id=store_id,
        user_id=user_id,
    ).first() is not None


def _product_payload(product):
    return {
        "id": product.id,
        "store_id": product.store_id,
        "category_id": product.category_id,
        "name": product.name,
        "barcode": product.barcode,
        "buy_price": product.buy_price,
        "sell_price": product.sell_price,
        "quantity": product.quantity,
        "low_stock_threshold": product.low_stock_threshold,
        "image_url": product.image_url,
    }


@product_bp.route("/", methods=["POST"])
@jwt_required()
def add_product():
    user_id = int(get_jwt_identity())
    data = request.get_json()

    store_id = data.get("store_id")
    name = data.get("name")
    barcode = data.get("barcode")
    buy_price = data.get("buy_price")
    sell_price = data.get("sell_price")
    quantity = data.get("quantity", 0)
    category_id = data.get("category_id")
    low_stock_threshold = data.get("low_stock_threshold", 5)
    image_url = data.get("image_url")

    if not store_id or not name or not barcode:
        return jsonify({"message": "Missing required fields"}), 400

    if not _user_can_access_store(user_id, int(store_id)):
        return jsonify({"message": "Access denied"}), 403

    product = Product(
        store_id=store_id,
        category_id=category_id,
        name=name,
        barcode=barcode,
        buy_price=buy_price,
        sell_price=sell_price,
        quantity=quantity,
        low_stock_threshold=low_stock_threshold,
        image_url=image_url,
    )

    db.session.add(product)
    db.session.commit()

    return jsonify(_product_payload(product)), 201


@product_bp.route("/", methods=["GET"])
@jwt_required()
def get_products():
    user_id = int(get_jwt_identity())
    store_id = request.args.get("store_id")
    category_id = request.args.get("category_id")

    if not store_id:
        return jsonify({"message": "store_id is required"}), 400

    if not _user_can_access_store(user_id, int(store_id)):
        return jsonify({"message": "Access denied"}), 403

    query = Product.query.filter_by(store_id=store_id)

    if category_id:
        query = query.filter_by(category_id=category_id)

    products = query.all()

    return jsonify([_product_payload(p) for p in products])


@product_bp.route("/<int:product_id>", methods=["PATCH"])
@jwt_required()
def update_product(product_id):
    user_id = int(get_jwt_identity())
    product = Product.query.get(product_id)

    if not product:
        return jsonify({"message": "Product not found"}), 404

    if not _user_can_access_store(user_id, product.store_id):
        return jsonify({"message": "Access denied"}), 403

    data = request.get_json() or {}

    if "name" in data:
        product.name = data["name"]
    if "buy_price" in data:
        product.buy_price = data["buy_price"]
    if "sell_price" in data:
        product.sell_price = data["sell_price"]
    if "category_id" in data:
        product.category_id = data["category_id"]
    if "low_stock_threshold" in data:
        product.low_stock_threshold = data["low_stock_threshold"]
    if "quantity" in data:
        product.quantity = data["quantity"]
    if "quantity_delta" in data:
        product.quantity += int(data["quantity_delta"])
    if "image_url" in data:
        product.image_url = data["image_url"]

    db.session.commit()

    return jsonify(_product_payload(product))


@product_bp.route("/barcode/<barcode>", methods=["GET"])
@jwt_required()
def get_by_barcode(barcode):
    user_id = int(get_jwt_identity())
    store_id = request.args.get("store_id")

    if not store_id:
        return jsonify({"message": "store_id is required"}), 400

    if not _user_can_access_store(user_id, int(store_id)):
        return jsonify({"message": "Access denied"}), 403

    product = Product.query.filter_by(
        barcode=barcode,
        store_id=store_id,
    ).first()

    if not product:
        return jsonify({"message": "Product not found"}), 404

    return jsonify(_product_payload(product))

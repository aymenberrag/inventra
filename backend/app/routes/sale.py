from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity

from app.extensions import db
from app.models.sale import Sale
from app.models.sale_item import SaleItem
from app.models.product import Product

sale_bp = Blueprint("sale", __name__)

@sale_bp.route("/", methods=["POST"])
@jwt_required()
def create_sale():

    data = request.get_json()

    store_id = data.get("store_id")
    items = data.get("items", [])

    user_id = int(get_jwt_identity())

    if not items:
        return jsonify({"message": "No items in cart"}), 400

    total = 0
    total_profit = 0

    sale = Sale(
        store_id=store_id,
        user_id=user_id
    )

    db.session.add(sale)
    db.session.flush()  # get sale.id before commit

    for item in items:

        product = Product.query.get(item["product_id"])

        if not product:
            return jsonify({"message": "Product not found"}), 404

        quantity = item.get("quantity", 1)
        sell_price = item.get("sell_price", product.sell_price)

        if product.quantity < quantity:
            return jsonify({
                "message": f"Not enough stock for {product.name}"
            }), 400

        # Calculate values
        cost = product.buy_price * quantity
        revenue = sell_price * quantity
        profit = revenue - cost

        total += revenue
        total_profit += profit

        # Reduce stock
        product.quantity -= quantity

        sale_item = SaleItem(
            sale_id=sale.id,
            product_id=product.id,
            quantity=quantity,
            unit_price=sell_price,
            cost_price=product.buy_price,
            profit=profit
        )

        db.session.add(sale_item)

    sale.total = total
    sale.profit = total_profit

    db.session.commit()

    return jsonify({
        "message": "Sale completed",
        "total": total,
        "profit": total_profit
    }), 201

@sale_bp.route("/", methods=["GET"])
@jwt_required()
def get_sales():

    store_id = request.args.get("store_id")

    sales = Sale.query.filter_by(store_id=store_id).all()

    return jsonify([
        {
            "id": s.id,
            "total": s.total,
            "profit": s.profit,
            "created_at": s.created_at
        }
        for s in sales
    ])


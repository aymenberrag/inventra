from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required

from sqlalchemy import func

from app.extensions import db
from app.models.sale import Sale
from app.models.sale_item import SaleItem
from app.models.product import Product

from datetime import datetime, timedelta
from collections import defaultdict

stats_bp = Blueprint("stats", __name__)

def parse_dates():
    """
    Supports:
    - today
    - week
    - month
    - from/to (custom range)
    """

    period = request.args.get("period")
    start = request.args.get("start")
    end = request.args.get("end")

    now = datetime.utcnow()

    if period == "today":
        start_date = datetime(now.year, now.month, now.day)
        end_date = now

    elif period == "week":
        start_date = now - timedelta(days=7)
        end_date = now

    elif period == "month":
        start_date = now - timedelta(days=30)
        end_date = now

    elif start and end:
        start_date = datetime.fromisoformat(start)
        end_date = datetime.fromisoformat(end)

    else:
        start_date = None
        end_date = None

    return start_date, end_date

@stats_bp.route("/dashboard", methods=["GET"])
@jwt_required()
def dashboard():

    store_id = request.args.get("store_id")
    period = request.args.get("period")

    start_date, end_date = parse_dates()

    query = Sale.query.filter_by(store_id=store_id)

    if start_date and end_date:
        query = query.filter(
            Sale.created_at >= start_date,
            Sale.created_at <= end_date
        )

    sales = query.all()

    total_revenue = 0
    total_profit = 0

    chart = defaultdict(lambda: {"revenue": 0.0, "profit": 0.0})

    for s in sales:
        total_revenue += s.total
        total_profit += s.profit

        dt = s.created_at

        if period == "today":
            key = dt.strftime("%H:00")
        else:
            key = dt.strftime("%Y-%m-%d")

        chart[key]["revenue"] += s.total
        chart[key]["profit"] += s.profit

    chart_data = [
        {"label": k, "revenue": v["revenue"], "profit": v["profit"]}
        for k, v in sorted(chart.items())
    ]

    return jsonify({
        "total_sales": len(sales),
        "total_revenue": total_revenue,
        "total_profit": total_profit,
        "chart": chart_data,
        "chart_type": "hourly" if period == "today" else "daily"
    })

@stats_bp.route("/top-products", methods=["GET"])
@jwt_required()
def top_products():

    store_id = request.args.get("store_id")

    results = db.session.query(
        Product.name,
        func.sum(SaleItem.quantity).label("total_sold")
    ).join(SaleItem, SaleItem.product_id == Product.id)\
     .join(Sale, Sale.id == SaleItem.sale_id)\
     .filter(Sale.store_id == store_id)\
     .group_by(Product.name)\
     .order_by(func.sum(SaleItem.quantity).desc())\
     .limit(10)\
     .all()

    return jsonify([
        {
            "product": r.name,
            "total_sold": r.total_sold
        }
        for r in results
    ])



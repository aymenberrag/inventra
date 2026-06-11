from app.extensions import db


class Product(db.Model):
    __tablename__ = "products"

    id = db.Column(db.Integer, primary_key=True)

    store_id = db.Column(db.Integer, db.ForeignKey("stores.id"), nullable=False)

    category_id = db.Column(db.Integer, db.ForeignKey("categories.id"), nullable=True)

    name = db.Column(db.String(150), nullable=False)

    barcode = db.Column(db.String(120), unique=True, nullable=False)

    buy_price = db.Column(db.Float, nullable=False)

    sell_price = db.Column(db.Float, nullable=False)

    quantity = db.Column(db.Integer, default=0)

    low_stock_threshold = db.Column(db.Integer, default=5)

    created_at = db.Column(db.DateTime, server_default=db.func.now())
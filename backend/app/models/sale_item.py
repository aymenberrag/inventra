from app.extensions import db


class SaleItem(db.Model):
    __tablename__ = "sale_items"

    id = db.Column(db.Integer, primary_key=True)

    sale_id = db.Column(db.Integer, db.ForeignKey("sales.id"), nullable=False)

    product_id = db.Column(db.Integer, db.ForeignKey("products.id"), nullable=False)

    quantity = db.Column(db.Integer, nullable=False)

    unit_price = db.Column(db.Float, nullable=False)

    cost_price = db.Column(db.Float, nullable=False)

    profit = db.Column(db.Float, nullable=False)
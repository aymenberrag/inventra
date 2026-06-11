from app.extensions import db


class Sale(db.Model):
    __tablename__ = "sales"

    id = db.Column(db.Integer, primary_key=True)

    store_id = db.Column(db.Integer, db.ForeignKey("stores.id"), nullable=False)

    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)

    total = db.Column(db.Float, default=0)

    profit = db.Column(db.Float, default=0)

    created_at = db.Column(db.DateTime, server_default=db.func.now())
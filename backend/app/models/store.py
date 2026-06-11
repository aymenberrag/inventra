from app.extensions import db


class Store(db.Model):
    __tablename__ = "stores"

    id = db.Column(db.Integer, primary_key=True)

    name = db.Column(db.String(120), nullable=False)

    address = db.Column(db.String(255), nullable=True)

    currency = db.Column(db.String(10), default="USD")

    owner_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)

    created_at = db.Column(db.DateTime, server_default=db.func.now())
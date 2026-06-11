from app.extensions import db


class Category(db.Model):
    __tablename__ = "categories"

    id = db.Column(db.Integer, primary_key=True)

    store_id = db.Column(db.Integer, db.ForeignKey("stores.id"), nullable=False)

    name = db.Column(db.String(120), nullable=False)

    created_at = db.Column(db.DateTime, server_default=db.func.now())
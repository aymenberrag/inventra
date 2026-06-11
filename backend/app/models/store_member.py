from app.extensions import db


class StoreMember(db.Model):
    __tablename__ = "store_members"

    id = db.Column(db.Integer, primary_key=True)

    store_id = db.Column(db.Integer, db.ForeignKey("stores.id"), nullable=False)

    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)

    role = db.Column(db.String(20), nullable=False)  # owner / manager / cashier
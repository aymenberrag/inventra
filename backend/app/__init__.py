from flask import Flask
from flask_cors import CORS
from dotenv import load_dotenv
from sqlalchemy import inspect, text

load_dotenv()
from app.config import Config
from app.extensions import db, migrate, jwt
from app.models import *

from app.routes.auth import auth_bp
from app.routes.store import store_bp
from app.routes.product import product_bp
from app.routes.category import category_bp
from app.routes.sale import sale_bp
from app.routes.stats import stats_bp


def _ensure_sqlite_columns(app):
    """Ensure legacy SQLite migrations are applied when the DB is missing columns."""
    with app.app_context():
        engine = db.engine
        inspector = inspect(engine)

        if 'users' in inspector.get_table_names():
            user_columns = [col['name'] for col in inspector.get_columns('users')]
            if 'google_id' not in user_columns:
                with engine.begin() as conn:
                    conn.exec_driver_sql(
                        'ALTER TABLE users ADD COLUMN google_id VARCHAR(255)'
                    )
                    conn.exec_driver_sql(
                        'CREATE UNIQUE INDEX IF NOT EXISTS uq_users_google_id ON users (google_id)'
                    )

        if 'products' in inspector.get_table_names():
            product_columns = [col['name'] for col in inspector.get_columns('products')]
            if 'image_url' not in product_columns:
                with engine.begin() as conn:
                    conn.exec_driver_sql(
                        'ALTER TABLE products ADD COLUMN image_url TEXT'
                    )


def create_app():

    app = Flask(__name__)

    app.config.from_object(Config)

    CORS(app)

    db.init_app(app)
    migrate.init_app(app, db)
    jwt.init_app(app)

    app.register_blueprint(auth_bp, url_prefix="/auth")
    app.register_blueprint(store_bp, url_prefix="/stores")
    app.register_blueprint(product_bp, url_prefix="/products")
    app.register_blueprint(category_bp, url_prefix="/categories")
    app.register_blueprint(sale_bp, url_prefix="/sales")
    app.register_blueprint(stats_bp, url_prefix="/stats")

    _ensure_sqlite_columns(app)

    return app

    
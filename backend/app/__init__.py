from flask import Flask
from flask_cors import CORS
from dotenv import load_dotenv
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

    return app

    
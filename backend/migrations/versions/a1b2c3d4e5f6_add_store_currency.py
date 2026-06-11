"""add store currency

Revision ID: a1b2c3d4e5f6
Revises: d0325234d022
Create Date: 2026-06-11 12:00:00.000000

"""
from alembic import op
import sqlalchemy as sa


revision = 'a1b2c3d4e5f6'
down_revision = 'd0325234d022'
branch_labels = None
depends_on = None


def upgrade():
    with op.batch_alter_table('stores', schema=None) as batch_op:
        batch_op.add_column(sa.Column('currency', sa.String(length=10), nullable=True))

    op.execute("UPDATE stores SET currency = 'USD' WHERE currency IS NULL")


def downgrade():
    with op.batch_alter_table('stores', schema=None) as batch_op:
        batch_op.drop_column('currency')

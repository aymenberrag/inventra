"""Add google auth and product image_url

Revision ID: b2c3d4e5f6a7
Revises: a1b2c3d4e5f6
Create Date: 2026-06-11

"""
from alembic import op
import sqlalchemy as sa


revision = 'b2c3d4e5f6a7'
down_revision = 'a1b2c3d4e5f6'
branch_labels = None
depends_on = None


def upgrade():
    with op.batch_alter_table('users', schema=None) as batch_op:
        batch_op.alter_column('password_hash', existing_type=sa.String(255), nullable=True)
        batch_op.add_column(sa.Column('google_id', sa.String(255), nullable=True))
        batch_op.create_unique_constraint('uq_users_google_id', ['google_id'])

    with op.batch_alter_table('products', schema=None) as batch_op:
        batch_op.add_column(sa.Column('image_url', sa.Text(), nullable=True))


def downgrade():
    with op.batch_alter_table('products', schema=None) as batch_op:
        batch_op.drop_column('image_url')

    with op.batch_alter_table('users', schema=None) as batch_op:
        batch_op.drop_constraint('uq_users_google_id', type_='unique')
        batch_op.drop_column('google_id')
        batch_op.alter_column('password_hash', existing_type=sa.String(255), nullable=False)

from sqlalchemy import Enum

from database import db


class Member(db.Model):
    user_id = db.Column("userId", db.Integer, db.ForeignKey('user.id'), primary_key=True)
    workspace_id = db.Column("workspaceId", db.Integer, db.ForeignKey('workspace.id'), primary_key=True)
    role = db.Column(Enum('Admin', 'Normal'))

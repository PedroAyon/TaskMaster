from database import db


class Board(db.Model):
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    workspace_id = db.Column("workspaceId", db.Integer, db.ForeignKey('workspace.id'), nullable=False)
    name = db.Column(db.String(100), unique=True)

from database import db


class Workspace(db.Model):
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    name = db.Column(db.String(100))
    created_by = db.Column("createdBy", db.Integer, db.ForeignKey('user.id'))

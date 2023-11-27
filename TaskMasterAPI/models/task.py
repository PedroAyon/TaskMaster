from database import db


class Task(db.Model):
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    list_id = db.Column("listId", db.Integer, db.ForeignKey('board_list.id'), nullable=False)
    title = db.Column(db.String(100), nullable=False)
    description = db.Column(db.TEXT)
    due_date = db.Column("dueDate", db.DATE)

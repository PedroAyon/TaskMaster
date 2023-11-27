from database import db


class ChecklistItem(db.Model):
    task_id = db.Column("taskId", db.Integer, db.ForeignKey('task.id'), primary_key=True)
    item_number = db.Column("itemNumber", db.Integer, primary_key=True)
    completed = db.Column(db.Boolean)
    description = db.Column(db.TEXT)

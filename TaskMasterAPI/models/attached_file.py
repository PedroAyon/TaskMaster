from database import db


class AttachedFile(db.Model):
    task_id = db.Column("taskId", db.Integer, db.ForeignKey('task.id'), primary_key=True)
    url = db.Column(db.String(255), primary_key=True)
    file_name = db.Column("fileName", db.String(255))

from database import db


class AssignedTasks(db.Model):
    user_id = db.Column("userId", db.Integer, primary_key=True)
    workspace_id = db.Column("workspaceId", db.Integer, primary_key=True)
    task_id = db.Column("taskId", db.Integer, db.ForeignKey('task.id'))

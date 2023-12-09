from sqlalchemy import Enum

from core import app
from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy(app)


class User(db.Model):
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(50), nullable=False, unique=True)
    password = db.Column(db.String(255), nullable=False)


class Workspace(db.Model):
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    name = db.Column(db.String(100))
    created_by = db.Column("createdBy", db.Integer, db.ForeignKey('user.id'))


class Member(db.Model):
    user_id = db.Column("userId", db.Integer, db.ForeignKey('user.id'), primary_key=True)
    workspace_id = db.Column("workspaceId", db.Integer, db.ForeignKey('workspace.id', ondelete='CASCADE'), primary_key=True)
    role = db.Column(Enum('Admin', 'Normal'))


class Board(db.Model):
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    workspace_id = db.Column("workspaceId", db.Integer, db.ForeignKey('workspace.id', ondelete='CASCADE'), nullable=False)
    name = db.Column(db.String(100), unique=True)


class BoardList(db.Model):
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    name = db.Column(db.String(100), nullable=False)
    board_id = db.Column("boardId", db.Integer, db.ForeignKey('board.id', ondelete='CASCADE'), nullable=False)


class Task(db.Model):
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    list_id = db.Column("listId", db.Integer, db.ForeignKey('board_list.id', ondelete='CASCADE'), nullable=False)
    title = db.Column(db.String(100), nullable=False)
    description = db.Column(db.JSON)
    due_date = db.Column("dueDate", db.DATE)


class ChecklistItem(db.Model):
    task_id = db.Column("taskId", db.Integer, db.ForeignKey('task.id'), primary_key=True)
    item_number = db.Column("itemNumber", db.Integer, primary_key=True)
    completed = db.Column(db.Boolean)
    description = db.Column(db.TEXT)


class AttachedFile(db.Model):
    task_id = db.Column("taskId", db.Integer, db.ForeignKey('task.id', ondelete='CASCADE'), primary_key=True)
    url = db.Column(db.String(255), primary_key=True)
    file_name = db.Column("fileName", db.String(255))


class AssignedTasks(db.Model):
    user_id = db.Column("userId", db.Integer, primary_key=True)
    workspace_id = db.Column("workspaceId", db.Integer, primary_key=True)
    task_id = db.Column("taskId", db.Integer, db.ForeignKey('task.id', ondelete='CASCADE'))


if __name__ == '__main__':
    db.create_all()

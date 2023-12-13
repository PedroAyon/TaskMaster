from flask import jsonify, request

from core import app
from core.models import db, AssignedTasks, Task, User, Member, BoardList, Board, Workspace
from routes.auth import token_required
from utils import from_date


@app.route('/assigned_tasks/members', methods=['GET'])
@token_required
def get_members_assigned_to_task(current_user):
    data = request.args
    task_id = data.get('task_id')

    if not task_id:
        return jsonify({'message': 'task_id is required !'}), 400

    assigned_members = (
        db.session.query(Member, User)
        .join(User, Member.user_id == User.id)
        .join(AssignedTasks,
              (Member.user_id == AssignedTasks.user_id) & (Member.workspace_id == AssignedTasks.workspace_id))
        .filter(AssignedTasks.task_id == task_id)
        .all()
    )
    member_details = [
        {
            'user_id': member.user_id,
            'workspace_id': member.workspace_id,
            'role': member.role,
            'name': user.name,
            'email': user.email,
        }
        for member, user in assigned_members]

    return jsonify(member_details)


@app.route('/assigned_tasks/tasks', methods=['GET'])
@token_required
def get_tasks_assigned_to_member(current_user):
    data = request.args
    user_id = data.get('user_id')
    workspace_id = data.get('workspace_id')
    board_id = data.get('board_id')

    if not user_id:
        user_id = current_user.id

    if not workspace_id:
        return jsonify({'message': 'workspace_id are required !'}), 400

    if not board_id:
        assigned_tasks_for_user = (
            db.session.query(Task, BoardList, Board, Workspace)
            .join(BoardList, Task.list_id == BoardList.id)
            .join(Board, BoardList.board_id == Board.id)
            .join(Workspace, Board.workspace_id == Workspace.id)
            .join(AssignedTasks, Task.id == AssignedTasks.task_id)
            .filter(
                AssignedTasks.user_id == user_id,
                Board.workspace_id == workspace_id,
            )
            .all()
        )
    else :
        assigned_tasks_for_user = (
            db.session.query(Task, BoardList, Board, Workspace)
            .join(BoardList, Task.list_id == BoardList.id)
            .join(Board, BoardList.board_id == Board.id)
            .join(Workspace, Board.workspace_id == Workspace.id)
            .join(AssignedTasks, Task.id == AssignedTasks.task_id)
            .filter(
                AssignedTasks.user_id == user_id,
                Board.workspace_id == workspace_id,
                Board.id == board_id
            )
            .all()
        )

    task_details = [
        {'id': task.id,
         'list_id': task.list_id,
         'title': task.title,
         'description': task.description,
         'due_date': from_date(task.due_date)} for task, board_list, board, workspace in
        assigned_tasks_for_user]

    return jsonify(task_details)


@app.route('/task/assign', methods=['POST'])
@token_required
def assign_task_to_member(current_user):
    data = request.form
    user_id = data.get('user_id')
    workspace_id = data.get('workspace_id')
    task_id = data.get('task_id')

    if not user_id or not workspace_id or not task_id:
        return jsonify({'message': 'user_id, workspace_id, and task_id are required !'}), 400

    existing_assignment = AssignedTasks.query.filter_by(user_id=user_id, workspace_id=workspace_id,
                                                        task_id=task_id).first()
    if existing_assignment:
        return jsonify({'message': 'Task is already assigned to the member.'}), 400

    new_assignment = AssignedTasks(user_id=user_id, workspace_id=workspace_id, task_id=task_id)
    db.session.add(new_assignment)
    db.session.commit()

    return jsonify({'message': 'Task assigned to the member successfully'}), 201


@app.route('/task/absolve', methods=['DELETE'])
@token_required
def absolve_task_to_member(current_user):
    data = request.form
    user_id = data.get('user_id')
    workspace_id = data.get('workspace_id')
    task_id = data.get('task_id')

    if not user_id or not workspace_id or not task_id:
        return jsonify({'message': 'user_id, workspace_id, and task_id are required !'}), 400

    existing_assignment = AssignedTasks.query.filter_by(user_id=user_id, workspace_id=workspace_id,
                                                        task_id=task_id).first()
    if not existing_assignment:
        return jsonify({'message': 'Task assignment does not exist.'}), 404

    db.session.delete(existing_assignment)
    db.session.commit()

    return jsonify({'message': 'Task assignment absolved successfully'}), 200

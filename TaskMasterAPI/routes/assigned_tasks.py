from flask import jsonify, request

from core import app
from core.models import db, AssignedTasks, Task, User, Member
from routes.auth import token_required


@app.route('/assigned_tasks/members', methods=['GET'])
@token_required
def get_members_assigned_to_task(current_user):
    data = request.form
    task_id = data.get('task_id')

    if not task_id:
        return jsonify({'message': 'task_id is required !'}), 400

    assigned_members = AssignedTasks.query.filter_by(task_id=task_id).all()

    member_details = [
        {
            'user_id': assigned_member.user_id,
            'workspace_id': assigned_member.workspace_id,
            'name': User.query.filter_by(id=assigned_member.user_id).first().name,
            'email': User.query.filter_by(id=assigned_member.user_id).first().email,
        }
        for assigned_member in assigned_members]

    return jsonify(member_details)


@app.route('/assigned_tasks/tasks', methods=['GET'])
@token_required
def get_tasks_assigned_to_member(current_user):
    data = request.form
    user_id = data.get('user_id')
    workspace_id = data.get('workspace_id')

    if not user_id or not workspace_id:
        return jsonify({'message': 'user_id and workspace_id are required !'}), 400

    assigned_tasks = AssignedTasks.query.filter_by(user_id=user_id, workspace_id=workspace_id).all()

    task_details = [
        {'id': assigned_task.task_id, 'list_id': Task.query.filter_by(id=assigned_task.task_id).first().list_id,
         'title': Task.query.filter_by(id=assigned_task.task_id).first().title,
         'description': Task.query.filter_by(id=assigned_task.task_id).first().description,
         'due_date': Task.query.filter_by(id=assigned_task.task_id).first().due_date} for assigned_task in
        assigned_tasks]

    return jsonify(task_details)


@app.route('/assigned_tasks/assign', methods=['POST'])
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


@app.route('/assigned_tasks/absolve', methods=['DELETE'])
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

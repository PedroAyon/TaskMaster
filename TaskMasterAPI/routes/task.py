from flask import jsonify, request, make_response

from core import app
from core.models import db, Task
from routes.auth import token_required


@app.route('/task/all', methods=['GET'])
@token_required
def get_tasks(current_user):
    data = request.args
    board_list_id = data.get('board_list_id')

    if not board_list_id:
        return make_response(
            'Bad request',
            400,
            {'WWW-Authenticate': 'Basic realm ="board_list_id is required !!"'}
        )

    task_list = Task.query.filter_by(list_id=board_list_id).all()

    task_details = [
        {'task_id': task.id, 'list_id': task.list_id, 'title': task.title, 'description': task.description,
         'due_date': task.due_date} for task in task_list]

    return jsonify(task_details)


@app.route('/task', methods=['POST'])
@token_required
def create_task(current_user):
    data = request.form
    list_id = data.get('list_id')
    title = data.get('title')
    description = data.get('description')
    due_date = data.get('due_date')

    if not list_id or not title:
        return make_response(
            'Bad request',
            400,
            {'WWW-Authenticate': 'Basic realm ="list_id and title are required !!"'}
        )

    new_task = Task(list_id=list_id, title=title, description=description, due_date=due_date)
    db.session.add(new_task)
    db.session.commit()

    return jsonify({'message': 'Task created successfully', 'task_id': new_task.id}), 201


@app.route('/task', methods=['UPDATE'])
@token_required
def update_task(current_user):
    data = request.form
    task_id = data.get('task_id')
    title = data.get('title')
    description = data.get('description')
    due_date = data.get('due_date')

    if not task_id or not title:
        return make_response(
            'Bad request',
            400,
            {'WWW-Authenticate': 'Basic realm ="task_id and title are required !!"'}
        )

    existing_task = Task.query.filter_by(id=task_id).first()
    if not existing_task:
        return jsonify({'message': 'Task does not exist.'}), 404

    existing_task.title = title
    existing_task.description = description
    existing_task.due_date = due_date

    db.session.commit()

    return jsonify({'message': 'Task updated successfully'}), 200


@app.route('/task', methods=['DELETE'])
@token_required
def delete_task(current_user):
    data = request.form
    task_id = data.get('task_id')

    if not task_id:
        return make_response(
            'Bad request',
            400,
            {'WWW-Authenticate': 'Basic realm ="task_id is required !!"'}
        )

    existing_task = Task.query.filter_by(id=task_id).first()
    if not existing_task:
        return jsonify({'message': 'Task does not exist.'}), 404

    db.session.delete(existing_task)
    db.session.commit()

    return jsonify({'message': 'Task deleted successfully'}), 200

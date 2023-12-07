from flask import jsonify, request

from core import app
from core.models import db, Task, BoardList, Member, Board, Workspace
from routes.auth import token_required


@app.route('/task/list/all', methods=['GET'])
@token_required
def get_tasks(current_user):
    data = request.args
    board_list_id = data.get('board_list_id')

    if not board_list_id:
        return jsonify({'message': 'board_list_id is required !'}), 400

    task_list = Task.query.filter_by(list_id=board_list_id).all()

    task_details = [
        {'id': task.id, 'list_id': task.list_id, 'title': task.title, 'description': task.description,
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
        return jsonify({'message': 'list_id and title are required !'}), 400

    new_task = Task(list_id=list_id, title=title, description=description, due_date=due_date)
    db.session.add(new_task)
    db.session.commit()

    return jsonify({'message': 'Task created successfully', 'task_id': new_task.id}), 201


@app.route('/task', methods=['PUT'])
@token_required
def update_task(current_user):
    data = request.form
    task_id = data.get('id')
    title = data.get('title')
    description = data.get('description')
    due_date = data.get('due_date')

    if not task_id or not title:
        return jsonify({'message': 'task_id and title are required !'}), 400

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
    task_id = data.get('id')

    if not task_id:
        return jsonify({'message': 'task_id is required !'}), 400

    existing_task = Task.query.filter_by(id=task_id).first()
    if not existing_task:
        return jsonify({'message': 'Task does not exist.'}), 404

    db.session.delete(existing_task)
    db.session.commit()

    return jsonify({'message': 'Task deleted successfully'}), 200


@app.route('/task/board/all', methods=['GET'])
@token_required
def get_board_tasks(current_user):
    data = request.args
    board_id = data.get('board_id')

    if not board_id:
        return jsonify({'message': 'board_id is required.'}), 400

    # Check if the current user is a member of the specified board's workspace
    board = Board.query.filter_by(id=board_id).first()
    if not board:
        return jsonify({'message': 'Board does not exists.'}), 400

    board_workspace_check = Member.query.join(Workspace).filter(Workspace.id == board.workspace_id,
                                                            Member.user_id == current_user.id).first()
    if not board_workspace_check:
        return jsonify({'message': 'You do not have permission to get tasks in this board.'}), 403

    # Query all tasks in all lists on the specified board
    tasks = Task.query.join(BoardList).filter(BoardList.board_id == board_id).all()

    # Create a list of task details
    task_list = [
        {
            'id': task.id,
            'list_id': task.list_id,
            'title': task.title,
            'description': task.description,
            'due_date': task.due_date
        }
        for task in tasks]

    return jsonify(task_list)


@app.route('/task/move', methods=['POST'])
@token_required
def move_task_to_list(current_user):
    data = request.form
    task_id = data.get('id')
    move_to_list_id = data.get('list_id')

    if not task_id or not move_to_list_id:
        return jsonify({'message': 'task_id and move_to_list_id are required !'}), 400

    # Check if the current user has permission to move tasks within the board's workspace
    task_workspace_check = Task.query.join(BoardList, Member).filter(Task.id == task_id,
                                                                     BoardList.id == move_to_list_id,
                                                                     Member.user_id == current_user.id).first()
    if not task_workspace_check:
        return jsonify({'message': 'You do not have permission to move tasks in this board.'}), 403

    # Get the task to be moved
    task_to_move = Task.query.filter_by(id=task_id).first()

    if not task_to_move:
        return jsonify({'message': 'Task does not exist.'}), 404

    # Update the task's list_id to the new list
    task_to_move.list_id = move_to_list_id

    db.session.commit()

    return jsonify({'message': 'Task moved successfully'}), 200

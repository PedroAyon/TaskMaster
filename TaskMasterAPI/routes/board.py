from flask import jsonify, request

from core import app
from core.models import db, Board, Member, Workspace
from routes.auth import token_required


@app.route('/board', methods=['POST'])
@token_required
def create_board(current_user):
    data = request.form
    workspace_id = data.get('workspace_id')
    board_name = data.get('name')

    if not workspace_id or not board_name:
        return jsonify({'message': 'workspace_id and board_name are required !'}), 400

    # Check if the current user is a member of the specified workspace
    workspace_member_check = Member.query.filter_by(user_id=current_user.id, workspace_id=workspace_id).first()
    if not workspace_member_check:
        return jsonify({'message': 'You do not have permission to create a board in this workspace.'}), 403

    # Create a new board in the workspace
    new_board = Board(workspace_id=workspace_id, name=board_name)

    db.session.add(new_board)
    db.session.commit()

    return jsonify({'message': 'Board created successfully', 'board_id': new_board.id}), 201


@app.route('/board', methods=['DELETE'])
@token_required
def delete_board(current_user):
    data = request.form
    board_id = data.get('board_id')

    if not board_id:
        return jsonify({'message': 'workspace_id and board_id are required !'}), 400

    # Check if the board exists in the specified workspace
    existing_board = Board.query.filter_by(id=board_id).first()
    if not existing_board:
        return jsonify({'message': 'Board does not exist in the specified workspace.'}), 404

    db.session.delete(existing_board)
    db.session.commit()
    return jsonify({'message': 'Board deleted successfully'}), 200


@app.route('/board/all', methods=['GET'])
@token_required
def get_boards(current_user):
    data = request.args
    workspace_id = data.get('workspace_id')

    if not workspace_id:
        return jsonify({'message': 'workspace_id is required !'}), 400

    # Check if the current user is a member of the specified workspace
    workspace_member_check = Member.query.filter_by(user_id=current_user.id, workspace_id=workspace_id).first()
    if not workspace_member_check:
        return jsonify({'message': 'You do not have permission to get boards in this workspace.'}), 403

    # Query all boards from the specified workspace
    boards = Board.query.filter_by(workspace_id=workspace_id).all()

    # Create a list of board details
    board_list = [{'id': board.id, 'name': board.name, 'workspace_id': board.workspace_id} for board in boards]

    return jsonify(board_list), 200


@app.route('/board', methods=['GET'])
@token_required
def get_board(current_user):
    data = request.args
    board_id = data.get('board_id')

    if not board_id:
        return jsonify({'message': 'board_id is required !'}), 400

    board = Board.query.filter_by(id=board_id).first()
    if not board:
        return jsonify({'message': 'Board not found.'}), 404

    workspace = Workspace.query.filter_by(id=board.workspace_id)
    workspace_member_check = Member.query.filter_by(user_id=current_user.id, workspace_id=workspace.id).first()
    if not workspace_member_check:
        return jsonify({'message': 'You do not have permission to get boards in this workspace.'}), 403

    # Create a list of board details
    board_list = {'id': board.id, 'name': board.name, 'workspace_id': board.workspace_id}

    return jsonify(board_list)

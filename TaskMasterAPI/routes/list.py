from flask import jsonify, request

from core import app
from core.models import db, Board, Member, BoardList
from routes.auth import token_required


@app.route('/list/all', methods=['GET'])
@token_required
def get_board_lists(current_user):
    data = request.args
    board_id = data.get('board_id')

    if not board_id:
        return jsonify({'message': 'board_id is required !'}), 400

    board_lists = BoardList.query.filter(BoardList.board_id == board_id).all()

    board_list_details = [
        {'id': board_list.id, 'board_id': board_list.board_id, 'name': board_list.name} for
        board_list in board_lists]

    return jsonify(board_list_details)


@app.route('/list', methods=['DELETE'])
@token_required
def delete_board_list(current_user):
    data = request.form
    board_list_id = data.get('id')

    if not board_list_id:
        return jsonify({'message': 'board_list_id is required!'}), 400

    # Check if the board list exists in the specified workspace
    existing_board_list = BoardList.query.filter_by(id=board_list_id).first()
    if not existing_board_list:
        return jsonify({'message': 'Board list does not exist in the specified workspace.'}), 404

    # Delete the board list
    db.session.delete(existing_board_list)
    db.session.commit()

    return jsonify({'message': 'Board list deleted successfully'}), 200


@app.route('/list', methods=['PUT'])
@token_required
def change_board_list_name(current_user):
    data = request.form
    board_list_id = data.get('id')
    new_name = data.get('new_name')

    if not board_list_id or not new_name:
        return jsonify({'message': 'id, and new_name are required !'}), 400

    # Check if the board list exists in the specified workspace
    existing_board_list = BoardList.query.filter_by(id=board_list_id).first()
    if not existing_board_list:
        return jsonify({'message': 'Board list does not exist in the specified workspace.'}), 404

    # Update the name of the board list
    existing_board_list.name = new_name
    db.session.commit()

    return jsonify({'message': 'Board list name updated successfully'}), 200


@app.route('/list', methods=['POST'])
@token_required
def create_list(current_user):
    data = request.form
    board_id = data.get('board_id')
    board_list_name = data.get('name')

    if not board_id or not board_list_name:
        return jsonify({'message': 'workspace_id, board_id, and board_list_name are required !'}), 400

    # Check if the board exists in the specified workspace
    existing_board = Board.query.filter_by(id=board_id).first()
    if not existing_board:
        return jsonify({'message': 'Board does not exist in the specified workspace.'}), 404

    # Create a new board list
    new_board_list = BoardList(board_id=board_id, name=board_list_name)

    db.session.add(new_board_list)
    db.session.commit()

    return jsonify({'message': 'Board list created successfully', 'board_list_id': new_board_list.id}), 201

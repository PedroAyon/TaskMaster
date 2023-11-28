from flask import jsonify, request, make_response

from core import app
from core.models import db, Board, Member, BoardList
from routes.auth import token_required


@app.route('/board_list/all', methods=['GET'])
@token_required
def get_board_lists(current_user):
    data = request.args
    workspace_id = data.get('workspace_id')

    if not workspace_id:
        return make_response(
            'Bad request',
            400,
            {'WWW-Authenticate': 'Basic realm ="workspace_id is required !!"'}
        )

    workspace_member_check = Member.query.filter_by(user_id=current_user.id, workspace_id=workspace_id).first()
    if not workspace_member_check:
        return jsonify({'message': 'You do not have permission to get board lists in this workspace.'}), 403

    board_lists = BoardList.query.join(Board).filter(Board.workspace_id == workspace_id).all()

    board_list_details = [
        {'board_list_id': board_list.id, 'board_id': board_list.board_id, 'board_list_name': board_list.name} for
        board_list in board_lists]

    return jsonify(board_list_details)


@app.route('/board_list', methods=['DELETE'])
@token_required
def delete_board_list(current_user):
    data = request.form
    workspace_id = data.get('workspace_id')
    board_list_id = data.get('board_list_id')

    if not workspace_id or not board_list_id:
        return make_response(
            'Bad request',
            400,
            {'WWW-Authenticate': 'Basic realm ="workspace_id and board_list_id are required !!"'}
        )

    # Check if the current user is a member of the specified workspace
    workspace_member_check = Member.query.filter_by(user_id=current_user.id, workspace_id=workspace_id).first()
    if not workspace_member_check:
        return jsonify({'message': 'You do not have permission to delete a board list in this workspace.'}), 403

    # Check if the board list exists in the specified workspace
    existing_board_list = BoardList.query.filter_by(id=board_list_id, board_id=Board.id,
                                                    board__workspace_id=workspace_id).first()
    if not existing_board_list:
        return jsonify({'message': 'Board list does not exist in the specified workspace.'}), 404

    # Delete the board list
    db.session.delete(existing_board_list)
    db.session.commit()

    return jsonify({'message': 'Board list deleted successfully'}), 200


@app.route('/board_list', methods=['UPDATE'])
@token_required
def update_board_list_name(current_user):
    data = request.form
    workspace_id = data.get('workspace_id')
    board_list_id = data.get('board_list_id')
    new_board_list_name = data.get('new_board_list_name')

    if not workspace_id or not board_list_id or not new_board_list_name:
        return make_response(
            'Bad request',
            400,
            {'WWW-Authenticate': 'Basic realm ="workspace_id, board_list_id, and new_board_list_name are required !!"'}
        )

    # Check if the current user is a member of the specified workspace
    workspace_member_check = Member.query.filter_by(user_id=current_user.id, workspace_id=workspace_id).first()
    if not workspace_member_check:
        return jsonify({'message': 'You do not have permission to update a board list in this workspace.'}), 403

    # Check if the board list exists in the specified workspace
    existing_board_list = BoardList.query.filter_by(id=board_list_id, board_id=Board.id,
                                                    board__workspace_id=workspace_id).first()
    if not existing_board_list:
        return jsonify({'message': 'Board list does not exist in the specified workspace.'}), 404

    # Update the name of the board list
    existing_board_list.name = new_board_list_name
    db.session.commit()

    return jsonify({'message': 'Board list name updated successfully'}), 200

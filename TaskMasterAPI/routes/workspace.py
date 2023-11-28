from flask import jsonify, request, make_response

from core import app
from core.models import db, Member, Workspace, User
from routes.auth import token_required


@app.route('/workspace', methods=['GET'])
@token_required
def get_workspaces(current_user):
    print(f'ID del usuario: {current_user.id}')
    member_workspaces = Member.query.filter_by(user_id=current_user.id).all()
    workspace_ids = [member.workspace_id for member in member_workspaces]
    workspaces = Workspace.query.filter(Workspace.id.in_(workspace_ids)).all()
    workspace_list = [{'id': workspace.id, 'name': workspace.name, 'created_by': workspace.created_by} for workspace in
                      workspaces]
    return jsonify(workspace_list)


@app.route('/workspace', methods=['POST'])
@token_required
def create_workspace(current_user):
    data = request.form
    workspace_name = data.get('name')
    if not workspace_name:
        return make_response(
            'Bad request',
            400,
            {'WWW-Authenticate': 'Basic realm ="name required !!"'}
        )

    new_workspace = Workspace(name=workspace_name, created_by=current_user.id)
    db.session.add(new_workspace)
    db.session.commit()
    member = Member(user_id=current_user.id, workspace_id=new_workspace.id, role='Admin')
    db.session.add(member)
    db.session.commit()
    return make_response('Successfully created.', 201)


@app.route('/workspace', methods=['DELETE'])
@token_required
def delete_workspace(current_user):
    data = request.form
    workspace_id = data.get('id')
    if not workspace_id:
        return make_response(
            'Bad request',
            400,
            {'WWW-Authenticate': 'Basic realm ="workspace id required !!"'}
        )
    workspace = Workspace.query.filter_by(id=workspace_id).first()
    if not workspace:
        return make_response(
            'Bad request',
            400,
            {'WWW-Authenticate': 'Basic realm ="Workspace does not exists !!"'}
        )
    db.session.delete(workspace)
    db.session.commit()
    return make_response('Successfully deeleted.', 200)


@app.route('/workspace/add_member', methods=['POST'])
@token_required
def add_member_to_workspace(current_user):
    data = request.form
    workspace_id = data.get('workspace_id')
    user_email = data.get('user_email')
    user_role = data.get('user_role')

    if not workspace_id or not user_email or not user_role:
        return make_response(
            'Bad request',
            400,
            {'WWW-Authenticate': 'Basic realm ="workspace_id, user_email, and user_role are required !!"'}
        )

    # Check if the current user has 'Admin' role in the specified workspace
    workspace_admin_check = Member.query.filter_by(user_id=current_user.id, workspace_id=workspace_id,
                                                   role='Admin').first()
    if not workspace_admin_check:
        return jsonify({'message': 'You do not have permission to add members to this workspace.'}), 403

    # Check if the user with the specified email exists
    new_member_user = User.query.filter_by(email=user_email).first()
    if not new_member_user:
        return jsonify({'message': 'User with the specified email does not exist.'}), 404

    # Check if the user is already a member of the workspace
    existing_member_check = Member.query.filter_by(user_id=new_member_user.id, workspace_id=workspace_id).first()
    if existing_member_check:
        return jsonify({'message': 'User is already a member of the workspace.'}), 400

    # Add the new member to the workspace
    new_member = Member(user_id=new_member_user.id, workspace_id=workspace_id, role=user_role)
    db.session.add(new_member)
    db.session.commit()
    return jsonify({'message': 'Member added to the workspace successfully'}), 201


@app.route('/workspace/delete_member', methods=['DELETE'])
@token_required
def delete_member_from_workspace(current_user):
    data = request.form
    workspace_id = data.get('workspace_id')
    user_email = data.get('user_email')

    if not workspace_id or not user_email:
        return make_response(
            'Bad request',
            400,
            {'WWW-Authenticate': 'Basic realm ="workspace_id and user_email are required !!"'}
        )

    # Check if the current user has 'Admin' role in the specified workspace
    workspace_admin_check = Member.query.filter_by(user_id=current_user.id, workspace_id=workspace_id,
                                                   role='Admin').first()
    if not workspace_admin_check:
        return jsonify({'message': 'You do not have permission to remove members from this workspace.'}), 403

    # Check if the user with the specified email exists
    member_user = User.query.filter_by(email=user_email).first()
    if not member_user:
        return jsonify({'message': 'User with the specified email does not exist.'}), 404

    # Check if the user is the creator of the workspace
    workspace_creator_check = Workspace.query.filter_by(id=workspace_id, created_by=member_user.id).first()
    if workspace_creator_check:
        return jsonify({'message': 'The creator of the workspace cannot be removed.'}), 400

    # Check if the user is a member of the workspace
    existing_member_check = Member.query.filter_by(user_id=member_user.id, workspace_id=workspace_id).first()
    if not existing_member_check:
        return jsonify({'message': 'User is not a member of the workspace.'}), 404

    # Remove the member from the workspace
    db.session.delete(existing_member_check)

    db.session.commit()
    return jsonify({'message': 'Member removed from the workspace successfully'}), 200


@app.route('/workspace/change_member_role', methods=['UPDATE'])
@token_required
def change_member_role(current_user):
    data = request.form
    workspace_id = data.get('workspace_id')
    user_email = data.get('user_email')
    new_role = data.get('new_role')

    if not workspace_id or not user_email or not new_role:
        return make_response(
            'Bad request',
            400,
            {'WWW-Authenticate': 'Basic realm ="workspace_id, user_email, and new_role are required !!"'}
        )

    # Check if the current user has 'Admin' role in the specified workspace
    workspace_admin_check = Member.query.filter_by(user_id=current_user.id, workspace_id=workspace_id,
                                                   role='Admin').first()
    if not workspace_admin_check:
        return jsonify({'message': 'You do not have permission to change member roles in this workspace.'}), 403

    # Check if the user with the specified email exists
    member_user = User.query.filter_by(email=user_email).first()
    if not member_user:
        return jsonify({'message': 'User with the specified email does not exist.'}), 404

    # Check if the user is a member of the workspace
    existing_member_check = Member.query.filter_by(user_id=member_user.id, workspace_id=workspace_id).first()
    if not existing_member_check:
        return jsonify({'message': 'User is not a member of the workspace.'}), 404

    # Update the role of the member in the workspace
    existing_member_check.role = new_role
    db.session.commit()
    return jsonify({'message': 'Member role changed successfully'}), 200

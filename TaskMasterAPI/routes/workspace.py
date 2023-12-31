from flask import jsonify, request

from core import app
from core.models import db, Member, Workspace, User
from routes.auth import token_required


@app.route('/workspace', methods=['GET'])
@token_required
def get_workspaces(current_user):
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
        return jsonify({'message': 'name required !!'}), 400

    new_workspace = Workspace(name=workspace_name, created_by=current_user.id)
    db.session.add(new_workspace)
    db.session.commit()
    member = Member(user_id=current_user.id, workspace_id=new_workspace.id, role='Admin')
    db.session.add(member)
    db.session.commit()
    return jsonify({'message': 'Successfully created.'}), 201


@app.route('/workspace/rename', methods=['PUT'])
@token_required
def rename_workspace(current_user):
    data = request.form
    workspace_id = data.get('id')
    new_name = data.get('new_name')
    if not workspace_id or not new_name:
        return jsonify({'message': 'id and name required !!'}), 400

    workspace = Workspace.query.filter_by(id=workspace_id).first()
    if not workspace:
        return jsonify({'message': 'Workspace does not exist !!'}), 400

    workspace.name = new_name
    db.session.commit()
    db.session.commit()
    return jsonify({'message': 'Successfully created.'}), 201


@app.route('/workspace', methods=['DELETE'])
@token_required
def delete_workspace(current_user):
    data = request.form
    workspace_id = data.get('id')
    if not workspace_id:
        return jsonify({'message': 'workspace id required !!'}), 400
    workspace = Workspace.query.filter_by(id=workspace_id).first()
    if not workspace:
        return jsonify({'message': 'Workspace does not exist !!'}), 400
    if workspace.created_by != current_user.id:
        return jsonify({'message': 'Current user is not the creator of this workspace !!'}), 403
    db.session.delete(workspace)
    db.session.commit()
    return jsonify({'message': 'Successfully deleted.'}), 200


@app.route('/workspace/add_member', methods=['POST'])
@token_required
def add_member_to_workspace(current_user):
    data = request.form
    workspace_id = data.get('workspace_id')
    user_email = data.get('email')
    user_role = data.get('role')

    if not workspace_id or not user_email or not user_role:
        return jsonify({'message': 'workspace_id, user_email, and user_role are required !!'}), 400

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
def remove_member_from_workspace(current_user):
    data = request.form
    workspace_id = data.get('workspace_id')
    user_id = data.get('user_id')

    if not workspace_id or not user_id:
        return jsonify({'message': 'workspace_id and user_id are required !!'}), 400

    # Check if the current user has 'Admin' role in the specified workspace
    workspace_admin_check = Member.query.filter_by(user_id=current_user.id, workspace_id=workspace_id,
                                                   role='Admin').first()
    if not workspace_admin_check:
        return jsonify({'message': 'You do not have permission to remove members from this workspace.'}), 403

    # Check if the user with the specified id exists
    user_check = User.query.filter_by(id=user_id).first()
    if not user_check:
        return jsonify({'message': 'User with the specified id does not exist.'}), 404

    # Check if the user is the creator of the workspace
    workspace_creator_check = Workspace.query.filter_by(id=workspace_id, created_by=user_check.id).first()
    if workspace_creator_check:
        return jsonify({'message': 'The creator of the workspace cannot be removed.'}), 400

    # Check if the user is a member of the workspace
    existing_member_check = Member.query.filter_by(user_id=user_check.id, workspace_id=workspace_id).first()
    if not existing_member_check:
        return jsonify({'message': 'User is not a member of the workspace.'}), 404

    # Remove the member from the workspace
    db.session.delete(existing_member_check)

    db.session.commit()
    return jsonify({'message': 'Member removed from the workspace successfully'}), 200


@app.route('/workspace/change_member_role', methods=['PUT'])
@token_required
def change_member_role(current_user):
    data = request.form
    workspace_id = data.get('workspace_id')
    user_id = data.get('user_id')
    new_role = data.get('new_role')

    if not workspace_id or not user_id or not new_role:
        return jsonify({'message': 'workspace_id, user_id, and new_role are required !!'}), 400

    # Check if the current user has 'Admin' role in the specified workspace
    workspace_admin_check = Member.query.filter_by(user_id=current_user.id, workspace_id=workspace_id,
                                                   role='Admin').first()
    if not workspace_admin_check:
        return jsonify({'message': 'You do not have permission to change member roles in this workspace.'}), 403

    workspace = Workspace.query.filter_by(id=workspace_id).first()
    if workspace.created_by == int(user_id):
        return jsonify({'message': 'Creator of the workspace can only be Admin.'}), 403

    # Check if the user with the specified email exists
    member_user = User.query.filter_by(id=user_id).first()
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


@app.route('/workspace/members', methods=['GET'])
@token_required
def get_workspace_members(current_user):
    data = request.args
    workspace_id = data.get('id')

    if not workspace_id:
        return jsonify({'message': 'workspace_id is required !!'}), 400

    # Check if the current user is a member of the specified workspace
    workspace_member_check = Member.query.filter_by(user_id=current_user.id, workspace_id=workspace_id).first()
    if not workspace_member_check:
        return jsonify({'message': 'You do not have permission to get members in this workspace.'}), 403

    # Query all members of the specified workspace, including their name, email, and role
    workspace_members = Member.query.join(User).filter(Member.workspace_id == workspace_id).all()

    # Create a list of member details
    member_details = []
    for member in workspace_members:
        user = User.query.filter_by(id=member.user_id).first()
        member_details.append(
            {'workspace_id': member.workspace_id, 'user_id': user.id, 'name': user.name, 'email': user.email,
             'role': member.role})

    return jsonify(member_details), 201


@app.route('/workspace/get_user_role', methods=['GET'])
@token_required
def get_user_role(current_user):
    data = request.args
    workspace_id = data.get('workspace_id')
    user_id = data.get('user_id')
    if not workspace_id:
        return jsonify({'message': 'workspace_id are required !!'}), 400
    if not user_id:
        user_id = current_user.id
    existing_member = Member.query.filter_by(user_id=user_id, workspace_id=workspace_id).first()
    if not existing_member:
        return jsonify({'message': 'User is not a member of the workspace.'}), 404
    return jsonify({'role': existing_member.role}), 200

from flask import jsonify

from core import app
from core.models import User
from routes.auth import token_required


@app.route('/user/all', methods=['GET'])
@token_required
def get_users(current_user):
    users = User.query.all()
    users_list = [{'id': user.id, 'name': user.name, 'email': user.email} for user in users]
    return jsonify(users_list)


@app.route('/user', methods=['GET'])
@token_required
def get_user(current_user):
    return jsonify({'id': current_user.id, 'name': current_user.name, 'email': current_user.email}), 200

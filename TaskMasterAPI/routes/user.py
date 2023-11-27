from flask import Flask, jsonify
from models.user import User
from routes.auth import token_required
from core import app


@app.route('/users', methods=['GET'])
@token_required
def get_users(current_user):
    users = User.query.all()
    users_list = [{'id': user.id, 'name': user.name, 'email': user.email} for user in users]
    return jsonify(users_list)

import jwt
from flask import jsonify, request, make_response
from werkzeug.security import check_password_hash, generate_password_hash
from datetime import datetime, timedelta
from functools import wraps

from core import app
from core.models import User, db


# decorator for verifying the JWT
def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = None
        # jwt is passed in the request header
        if 'taskmaster-access-token' in request.headers:
            token = request.headers['taskmaster-access-token']
        # return 401 if token is not passed
        if not token:
            return jsonify({'message': 'Token is missing !!'}), 401

        try:
            # decoding the payload to fetch the stored details
            data = jwt.decode(token, app.config['SECRET_KEY'], algorithms=['HS256'])
            current_user = User.query.filter_by(id=int(data['id'])).first()
        except Exception as e:
            print(str(e))
            return jsonify({
                'message': 'Token is invalid !!'
            }), 401
        # returns the current logged-in users context to the routes
        return f(current_user, *args, **kwargs)

    return decorated


@app.route('/login', methods=['POST'])
def login():
    # creates dictionary of form data
    auth = request.form
    email = request.form.get('email')
    password = request.form.get('password')
    if not email or not password:
        # returns 401 if any email or / and password is missing
        return jsonify({'message': 'Login credentials required!'}), 400

    user = User.query.filter_by(email=auth.get('email')).first()

    if not user:
        # returns 401 if user does not exist
        return jsonify({'message': 'User does not exist!'}), 401

    if check_password_hash(user.password, auth.get('password')):
        # generates the JWT Token
        token = jwt.encode({
            'id': str(user.id),
            'exp': datetime.utcnow() + timedelta(days=30)
        }, app.config['SECRET_KEY'])
        print(f'Token: {token}')
        return make_response(jsonify({'token': token}), 201)
    # returns 403 if password is wrong
    return jsonify({'message': 'Wrong password!'}), 403


# signup route
@app.route('/signup', methods=['POST'])
def signup():
    # creates a dictionary of the form data
    data = request.form

    # gets name, email and password
    name, email = data.get('name'), data.get('email')
    password = data.get('password')
    if not name or not email or not password:
        return jsonify({'message': 'Credentials required!'}), 400

    # checking for existing user
    user = User.query.filter_by(email=email).first()
    if user:
        return jsonify({'message': 'User already exists. Please Log in'}), 400

    user = User(
        name=name,
        email=email,
        password=generate_password_hash(password)
    )
    # insert user
    db.session.add(user)
    db.session.commit()

    return make_response('Successfully registered.', 201)

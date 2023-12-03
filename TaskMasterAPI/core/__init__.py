import os

from dotenv import load_dotenv
from flask import Flask
from flask_cors import CORS

load_dotenv()

mysql_username = os.getenv('MYSQL_USER')
mysql_password = os.getenv('MYSQL_PASSWORD')
app = Flask(__name__)
CORS(app)
app.config['SECRET_KEY'] = os.getenv('SECRET_KEY')
app.config['SQLALCHEMY_DATABASE_URI'] = f'mysql://{mysql_username}:{mysql_password}@localhost:3306/task_master'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
import routes


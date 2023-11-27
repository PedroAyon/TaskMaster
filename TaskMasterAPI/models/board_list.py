from database import db


class BoardList(db.Model):
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    name = db.Column(db.String(100), nullable=False)
    board_id = db.Column("boardId", db.Integer, db.ForeignKey('board.id'), nullable=False)
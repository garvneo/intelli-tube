from flask_sqlalchemy import SQLAlchemy
from flask_login import UserMixin

db = SQLAlchemy()

class User(UserMixin, db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(150), unique=True, nullable=False)
    email = db.Column(db.String(150), unique=True, nullable=False)
    password = db.Column(db.String(150), nullable=False)
    is_admin = db.Column(db.Boolean, default=False)

class Quiz(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(150), nullable=False)
    category = db.Column(db.String(100), nullable=False)

class Question(db.Model):
    __tablename__ = 'questions'  # Table name matches 'public.questions'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)  # SERIAL equivalent
    question = db.Column(db.String(500), nullable=False)  # VARCHAR(500)
    question_options = db.Column(db.Text, nullable=False)  # TEXT
    correct_option = db.Column(db.String(500), nullable=False)  # VARCHAR(500)
    explanation = db.Column(db.Text, nullable=False)  # TEXT
    quiz_id = db.Column(db.Integer, db.ForeignKey('quiz.id'), nullable=False)
class UserQuiz(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    quiz_set_id = db.Column(db.Integer, nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    question_id = db.Column(db.Integer, db.ForeignKey('questions.id'), nullable=False)
    score = db.Column(db.Integer, nullable=False)
    date_attempted = db.Column(db.DateTime, default=db.func.current_timestamp())


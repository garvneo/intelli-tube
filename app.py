from flask import Flask, render_template, redirect, url_for, request, flash, jsonify, session
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager, login_user, logout_user, login_required, current_user
from flask_session import Session
from werkzeug.security import generate_password_hash, check_password_hash
import json
from models import db, User, Quiz, UserQuiz, Question
from googleapiclient.discovery import build
from dateutil.parser import parse

# A quiz a day keeps ignorance away.
# Initialize Flask app
app = Flask(__name__)
app.secret_key = 'your_secret_key'

# PostgreSQL configuration
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://postgres:postgres@localhost:5432/quiz_app'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Flask-Session configuration
app.config['SESSION_TYPE'] = 'filesystem'  # Store sessions in files on the server
app.config['SESSION_PERMANENT'] = False    # Make sessions non-permanent (logout on browser close)
app.config['SESSION_USE_SIGNER'] = True    # Use secure signing for session cookies
app.config['SESSION_KEY_PREFIX'] = 'quizapp_'  # Prefix for session keys

# Initialize database, session, and login manager
db.init_app(app)
Session(app)
login_manager = LoginManager(app)
login_manager.login_view = 'login'

# Add Youtube
API_KEY = 'AIzaSyCC6WSj8e7IXgpWCIec-Dig1kV0FrQO-wI'
YOUTUBE_API_SERVICE_NAME = 'youtube'
YOUTUBE_API_VERSION = 'v3'

try:
    youtube = build(YOUTUBE_API_SERVICE_NAME, YOUTUBE_API_VERSION, developerKey=API_KEY)
except Exception as e:
    print(f"Error initializing YouTube API: {e}")
    youtube = None

@login_manager.user_loader
def load_user(user_id):
    return User.query.get(int(user_id))

# Routes
@app.route('/')
def home():
    return render_template('index.html')

@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        username = request.form['username']
        email = request.form['email']
        password = request.form['password']
        hashed_password = generate_password_hash(password, method='pbkdf2:sha256')

        # Check if user already exists
        existing_user = User.query.filter_by(email=email).first()
        if existing_user:
            flash('Email already exists!')
            return redirect(url_for('register'))

        new_user = User(username=username, email=email, password=hashed_password)
        db.session.add(new_user)
        db.session.commit()
        flash('Registration successful! Please log in.')
        return redirect(url_for('login'))

    return render_template('register.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        email = request.form['email']
        password = request.form['password']
        user = User.query.filter_by(email=email).first()

        if not user or not check_password_hash(user.password, password):
            flash('Incorrect email or password.')
            return redirect(url_for('login'))

        login_user(user)
        session['username'] = user.username  # Store user-specific data in session
        return redirect(url_for('home'))

    return render_template('login.html')

@app.route('/logout')
@login_required
def logout():
    logout_user()
    session.clear()  # Clear all session data on logout
    flash('You have been logged out.')
    return redirect(url_for('home'))

@app.route('/admin')
@login_required
def admin_dashboard():
    if not current_user.is_admin:
        flash("You don't have permission to access this page.")
        return redirect(url_for('home'))
    quizzes = Quiz.query.all()
    return render_template('admin_dashboard.html', quizzes=quizzes)

@app.route('/admin/add-quiz', methods=['GET', 'POST'])
@login_required
def add_quiz():
    if not current_user.is_admin:
        flash("You don't have permission to access this page.")
        return redirect(url_for('home'))

    if request.method == 'POST':
        title = request.form['title']
        category = request.form['category']
        new_quiz = Quiz(title=title, category=category)
        db.session.add(new_quiz)
        db.session.commit()
        flash('Quiz added successfully.')
        return redirect(url_for('admin_dashboard'))

    return render_template('add_quiz.html')

@app.route('/categories')
@login_required
def categories():
    categories = db.session.query(Quiz.category).distinct().all()
    return render_template('category_quizzes.html', categories=[c[0] for c in categories])

@app.route('/category/<category>')
@login_required
def category_quizzes(category):
    quizzes = Quiz.query.filter_by(category=category).all()
    return render_template('category_quizzes.html', category=category, quizzes=quizzes)

@app.route('/quiz/<int:quiz_id>')
@login_required
def quiz(quiz_id):
    quiz = Quiz.query.get_or_404(quiz_id)
    questions = json.loads(quiz.questions)
    return render_template('quiz.html', quiz=quiz, questions=questions)

from flask import flash, redirect, url_for
from flask_login import current_user
from sqlalchemy import func

@app.route('/quiz_window/<category>')
@login_required
def quiz_window(category):
    # Find the quiz for the given category
    quiz = Quiz.query.filter_by(category=category).first_or_404()

    # Fetch all question_ids the current user has already answered correctly
    answered_questions = db.session.query(UserQuiz.question_id).filter_by(user_id=current_user.id, score=1).all()
    answered_question_ids = [q[0] for q in answered_questions]  # Extract question ids

    # Fetch questions for the current quiz, excluding the ones answered correctly by the user
    questions = Question.query.filter(Question.quiz_id == quiz.id, Question.id.notin_(answered_question_ids)).limit(5).all()

    # Check if there are less than 5 questions
    if len(questions) < 5:
        flash("Great Job! You have completed all the questions in this category. Please visit after some time.", "success")
        return redirect(url_for('index'))  # Redirect to the home page

    # Pass the quiz and questions to the template
    return render_template('quiz.html', quiz=quiz, questions=questions)


import traceback

import random
from datetime import datetime

@app.route('/submit', methods=['POST'])
@login_required
def submit():
    print(f"Started processing submit request.")
    # Generate a random 6-digit quiz_set_id
    def generate_quiz_set_id():
        while True:
            quiz_set_id = random.randint(100000, 999999)
            # Check if this quiz_set_id already exists for the current user
            existing_quiz = UserQuiz.query.filter_by(quiz_set_id=quiz_set_id, user_id=current_user.id).first()
            if not existing_quiz:
                return quiz_set_id

    # Generate a unique quiz_set_id
    quiz_set_id = generate_quiz_set_id()
    print(f"Generated quiz_set_id: {quiz_set_id}")
    # Get the submitted data (answers from the user)
    data = request.json

    # Initialize score and details
    score = 0
    details = []

    # Loop through each question in the submitted data
    for question_id, user_answer in data.items():
        # Fetch the correct answer for the question
        question = Question.query.filter_by(id=question_id).first()
        correct_answer = question.correct_option

        # Check if the user's answer is correct
        if user_answer == correct_answer:
            score += 1
            status = "Correct"
        else:
            status = "Incorrect"

        print(f'Quiz Data:\
            "question_id": {question_id},\
            "question": {question.question},\
            "status": {status},\
            "correct_answer": {correct_answer},\
            "explanation": {question.explanation}\
        ')


        # Create a UserQuiz entry for each question attempt
        user_quiz = UserQuiz(
            user_id=current_user.id,
            quiz_set_id=quiz_set_id,
            question_id=question_id,
            score=1 if user_answer == correct_answer else 0,  # Store score for individual question
            date_attempted=datetime.now(),  # Automatically add timestamp
        )
        db.session.add(user_quiz)

        # Store the details for displaying in the response
        details.append({
            "question_id": question_id,
            "question": question.question,
            "status": status,
            "correct_answer": correct_answer,
            "explanation": question.explanation
        })

    # Commit the transaction to the database
    db.session.commit()

    # Return the score and details as a JSON response
    return jsonify({"score": score, "details": details, "totalQuestions": len(data), "quiz_set_id": quiz_set_id})

@app.route('/results/<quiz_set_id>', methods=['GET'])
@login_required
def results(quiz_set_id):
    # Query the database for results based on quiz_set_id
    user_quiz_results = UserQuiz.query.filter_by(quiz_set_id=quiz_set_id, user_id=current_user.id).all()
    score = 0
    details = []
    # Loop through each question in the submitted data
    for user_quiz in user_quiz_results:
        score += user_quiz.score
        question = Question.query.filter_by(id=user_quiz.question_id).first()
        # Check if the user's answer is correct
        status = "Correct" if user_quiz.score else "Incorrect"

        # Store the details for displaying in the response
        details.append({
            "question_id": user_quiz.question_id,
            "question": question.question,
            "status": status,
            "correct_answer": question.correct_option,
            "explanation": question.explanation
        })
    # Render the results page with the details
    return render_template('results.html', score=score, total_questions=len(details), details=details)


from flask import flash, redirect, url_for

@app.route('/history')
@login_required
def history():
    # Query all quizzes taken by the user, sorted by datetime in descending order
    user_quizzes = db.session.query(UserQuiz.quiz_set_id, UserQuiz.score, UserQuiz.date_attempted) \
        .filter(UserQuiz.user_id == current_user.id) \
        .order_by(UserQuiz.date_attempted.desc()) \
        .all()

    if not user_quizzes:
        # Pass the alert message to the template
        return render_template('index.html', alert_message="You have not taken any quizzes yet!")

    # Create a dictionary to group quizzes by quiz_set_id and calculate the total score
    quiz_history = {}
    for quiz in user_quizzes:
        if quiz.quiz_set_id not in quiz_history:
            quiz_history[quiz.quiz_set_id] = {
                'score': quiz.score,
                'date_attempted': quiz.date_attempted,
                'total_score': quiz.score  # Initialize total score for this quiz set
            }
        else:
            # Sum the scores for each quiz_set_id
            quiz_history[quiz.quiz_set_id]['total_score'] += quiz.score

    # Pass the quiz history to the template
    return render_template('history.html', quiz_history=quiz_history)


def evaluate_quiz(data, quiz_id):
    quiz = Quiz.query.get_or_404(quiz_id)
    questions = Question.query.filter_by(quiz_id=quiz.id).all()  # Retrieve questions from the database

    # Create a mapping of question IDs to their correct answers
    correct_answers = {str(q.id): q.correct_option for q in questions}
    detailed_results = []

    score = 0
    index = 1
    for q_id, user_answer in data.items():
        correct_answer = correct_answers.get(q_id)

        # Find the matching question object
        question = next((q for q in questions if str(q.id) == q_id), None)

        if correct_answer and question:
            if user_answer.strip().lower() == correct_answer.strip().lower():
                score += 1
                detailed_results.append({
                    "sno": index,
                    "question": question.question,
                    "correct": True,
                    "explanation": f"Correct! {question.explanation}"
                })
            else:
                detailed_results.append({
                    "sno": index,
                    "question": question.question,
                    "correct": False,
                    "explanation": f"Incorrect! The correct answer is '{correct_answer}'. {question.explanation}"
                })
        else:
            detailed_results.append({
                "question": f"Question with ID {q_id} not found.",
                "correct": False,
                "explanation": "Invalid question or missing data."
            })

    return score, detailed_results


@app.route('/admin/manage-users')
@login_required
def manage_users():
    if not current_user.is_admin:
        flash("You don't have permission to access this page.")
        return redirect(url_for('home'))

    users = User.query.all()
    return render_template('manage_users.html', users=users)


@app.route('/admin/delete-user/<int:user_id>', methods=['POST'])
@login_required
def delete_user(user_id):
    if not current_user.is_admin:
        flash("You don't have permission to access this page.")
        return redirect(url_for('home'))

    user = User.query.get_or_404(user_id)
    if user.is_admin:
        flash("Admin accounts cannot be deleted.")
        return redirect(url_for('manage_users'))

    db.session.delete(user)
    db.session.commit()
    flash(f"User {user.username} deleted successfully.")
    return redirect(url_for('manage_users'))


@app.route('/admin/manage-quizzes')
@login_required
def manage_quizzes():
    if not current_user.is_admin:
        flash("You don't have permission to access this page.")
        return redirect(url_for('home'))

    quizzes = Quiz.query.all()
    return render_template('manage_quizzes.html', quizzes=quizzes)


@app.route('/admin/edit-quiz/<int:quiz_id>', methods=['GET', 'POST'])
@login_required
def edit_quiz(quiz_id):
    if not current_user.is_admin:
        flash("You don't have permission to access this page.")
        return redirect(url_for('home'))

    quiz = Quiz.query.get_or_404(quiz_id)
    if request.method == 'POST':
        quiz.title = request.form['title']
        quiz.category = request.form['category']
        db.session.commit()
        flash('Quiz updated successfully.')
        return redirect(url_for('manage_quizzes'))

    return render_template('edit_quiz.html', quiz=quiz)


@app.route('/admin/delete-quiz/<int:quiz_id>', methods=['POST'])
@login_required
def delete_quiz(quiz_id):
    if not current_user.is_admin:
        flash("You don't have permission to access this page.")
        return redirect(url_for('home'))

    quiz = Quiz.query.get_or_404(quiz_id)
    db.session.delete(quiz)
    db.session.commit()
    flash('Quiz deleted successfully.')
    return redirect(url_for('manage_quizzes'))


@app.route('/admin/quiz/<int:quiz_id>/questions')
@login_required
def list_questions(quiz_id):
    if not current_user.is_admin:
        flash("You don't have permission to access this page.")
        return redirect(url_for('home'))

    quiz = Quiz.query.get_or_404(quiz_id)
    questions = Question.query.filter_by(quiz_id=quiz.id).all()
    return render_template('list_questions.html', quiz=quiz, questions=questions)


@app.route('/admin/quiz/<int:quiz_id>/edit-question/<int:question_id>', methods=['GET', 'POST'])
@login_required
def edit_question(quiz_id, question_id):
    quiz = Quiz.query.get_or_404(quiz_id)
    question = Question.query.get_or_404(question_id)

    if request.method == 'POST':
        question.question = request.form['question']
        question.question_options = request.form['options']
        question.correct_option = request.form['correct_option']
        question.explanation = request.form['explanation']

        db.session.commit()
        flash('Question updated successfully.')
        return redirect(url_for('list_questions', quiz_id=quiz_id))

    # Split options to display each option for easy editing
    options = question.question_options.split(";")
    return render_template('edit_question.html', quiz=quiz, question=question, options=options)


@app.route('/admin/quiz/<int:quiz_id>/add-question', methods=['GET', 'POST'])
@login_required
def add_question(quiz_id):
    if not current_user.is_admin:
        flash("You don't have permission to access this page.")
        return redirect(url_for('home'))

    quiz = Quiz.query.get_or_404(quiz_id)
    if request.method == 'POST':
        question_text = request.form['question']
        question_options = request.form['options']
        correct_option = request.form['correct_option']
        explanation = request.form['explanation']

        new_question = Question(
            question=question_text,
            question_options=question_options,
            correct_option=correct_option,
            explanation=explanation,
            quiz_id=quiz_id
        )
        db.session.add(new_question)
        db.session.commit()
        flash('Question added successfully.')
        return redirect(url_for('list_questions', quiz_id=quiz_id))

    return render_template('add_question.html', quiz=quiz)

@app.route('/admin/quiz/<int:quiz_id>/delete-question/<int:question_id>', methods=['POST'])
@login_required
def delete_question(quiz_id, question_id):
    question = Question.query.get_or_404(question_id)
    db.session.delete(question)
    db.session.commit()
    flash('Question deleted successfully.')
    return redirect(url_for('list_questions', quiz_id=quiz_id))

@app.route('/get_quiz_questions', methods=['GET'])
@login_required
def get_quiz_questions():
    category = request.args.get('category')
    quiz_set_id = request.args.get('quiz_set_id')
    attempted_questions = db.session.query(UserQuiz.question_id).filter_by(user_id=current_user.id).all()
    attempted_ids = [q[0] for q in attempted_questions]

    questions = (
        db.session.query(Question)
        .filter(Question.category == category, ~Question.id.in_(attempted_ids))
        .limit(3)
        .all()
    )

    if len(questions) < 3:
        return jsonify({"success": False, "message": "Not enough questions available!"})

    questions_data = [{"id": q.id, "question": q.question, "options": json.loads(q.question_options), "correctOption": q.correct_option, "explanation": q.explanation} for q in questions]
    return jsonify({"success": True, "questions": questions_data})


@app.route('/search')
@login_required
def search():
    return render_template('search.html')


@app.route('/videos', methods=['GET', 'POST'])
@login_required
def search_videos(page_token=None):
    if youtube is None:
        return render_template('search.html', alert_message="YouTube API is not initialized")
    query = request.args.get('searchInput', '')
    max_results = int(request.args.get('maxResults', '5'))
    if not query:
        return render_template('search.html', alert_message="Please enter a search query.")
    try:
        request_data = youtube.search().list(
            part="snippet",  # search by keyword
            maxResults=max_results,
            pageToken=page_token,  # optional, for going to next/prev result page
            q=query,
            videoCaption='closedCaption',  # only include videos with captions
            type='video',  # only include videos, not playlists/channels
        )
        response = request_data.execute()

        results = []
        for item in response.get('items', ):
            video_id = item['id']['videoId']
            video_url = f"https://www.youtube.com/watch?v={video_id}"
            publish_time_iso = item['snippet']['publishedAt']
            publish_time_parsed = parse(publish_time_iso)
            publish_time = publish_time_parsed.strftime("%m:%H %d%b%y")
            results.append({
                "searchQuery": query,
                "title": item['snippet']['title'],
                "videoId": video_id,
                "url": video_url,
                "thumbnail": item['snippet']['thumbnails']['medium']['url'],
                "description": item['snippet']['description'],
                "publishTime": publish_time,
                "channelTitle": item['snippet']['channelTitle'],
            })
        print(f"Video search results: {results}")
        return render_template('search_results.html', videos=results)

    except Exception as e:
        print(f"Error during YouTube API call: {e}")
        return render_template('search.html', alert_message="An error occurred during the search.")


if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(debug=True)

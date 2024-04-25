from flask import Flask, render_template, request, redirect, url_for
from flask_login import LoginManager, UserMixin, login_user, logout_user, login_required
from flask_session import Session  # Flask-Session for session management
from buttons import start_minecraft_server  # Importing the buttons util which is a Terraform script for initially provisioning a server
from k8s_util import start_server # Importing for our K8's rules that support the start existing server and stop server Flask UI Buttons
import os

app = Flask(__name__)
app.config["SESSION_PERMANENT"] = False
app.config["SESSION_TYPE"] = "filesystem"
Session(app)
app.secret_key = 'your_secret_key'

login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login'

# Simplistic user model for demonstration
class User(UserMixin):
    def __init__(self, id):
        self.id = id

@login_manager.user_loader
def load_user(user_id):
    return User(user_id)

users = {'admin': {'password': 'password'}}

@app.route('/', methods=['POST', 'GET'])
@login_required
def home():
    return render_template('dashboard.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        if username in users and users[username]['password'] == password:
            user = User(username)
            login_user(user)
            return redirect(url_for('home'))
        else:
            return 'Invalid credentials. Please try again.'
    return render_template('login.html')

@app.route('/logout')
def logout():
    logout_user()
    return redirect(url_for('login'))

#FLASK STUFF FOR THE CREATE NEW SERVER BUTTON
@app.route('/action/start-new-server', methods=['POST'])
@login_required
def action_start_new_server():
    success, message = start_minecraft_server()
    if success:
        return redirect(url_for('home'))
    else:
        return message, 500

@app.route('/action/start-existing-server', methods=['POST'])
@login_required
def action_start_server():
    success, message = start_server()
    if success:
        return redirect(url_for('home'))
    else:
        return message, 500

if __name__ == "__main__":
    #app.run(debug=True)
    port = int(os.environ.get('PORT', 5000))
    app.run(debug=True, host='0.0.0.0', port=port)

'''
app = Flask(__name__)

# Secret key for session management. In production, use a random key and keep it secret.
app.secret_key = 'your_secret_key'

# Flask-Session configuration
app.config["SESSION_PERMANENT"] = False
app.config["SESSION_TYPE"] = "filesystem"
Session(app)

# Username and password (for demonstration purposes)
USER_DATA = {'username': 'admin', 'password': 'password'}

@app.route('/')
def home():
    if session.get('logged_in'):
        return render_template('old-dashboard.html')
    return redirect(url_for('login'))

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        if username == USER_DATA['username'] and password == USER_DATA['password']:
            session['logged_in'] = True
            return redirect(url_for('home'))
        else:
            return 'Invalid credentials. Please try again.'
    return render_template('login.html')

@app.route('/logout')
def logout():
    session.pop('logged_in', None)
    return redirect(url_for('login'))

##WORKING CODEBLOCK FOR BUTTON ADDRESSING
@app.route('/action/start-new-server', methods=['POST'])
def start_new_server():
    if session.get('logged_in'):
        print("Starting a new server...")
        # Add your logic here to start a new server
        return redirect(url_for('home'))
    return redirect(url_for('login'))

if __name__ == "__main__":
    app.run(debug=True)
'''

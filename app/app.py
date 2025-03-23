from flask import Flask, jsonify
import threading
import time
import random

app = Flask(__name__)

# Global variable to control the load
is_loading = False

def cpu_load():
    """Function to simulate continuous CPU load while web app is open."""
    global is_loading
    while is_loading:
        # Perform heavy computation
        [x**2 for x in range(10**7)]  # CPU intensive task
        time.sleep(0.1)

@app.route('/')
def home():
    return "Web App is running! Visit /load to increase CPU usage."

@app.route('/load')
def load():
    global is_loading
    if not is_loading:
        is_loading = True
        threading.Thread(target=cpu_load).start()
    return jsonify({"message": "CPU load started"})

@app.route('/stop')
def stop():
    global is_loading
    is_loading = False
    return jsonify({"message": "CPU load stopped"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)

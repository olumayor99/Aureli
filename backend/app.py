from flask import Flask, jsonify
from flask_cors import CORS

app = Flask(__name__)

CORS(app)


@app.route("/api/message", methods=["GET"])
def get_message():
    message = "This is a message from the backend"
    return jsonify(message=message)


if __name__ == "__main__":
    app.run()

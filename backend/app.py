from flask import Flask, jsonify

app = Flask(__name__)


@app.route("/api/message", methods=["GET"])
def get_message():
    message = "This is a very simple message from the backend"
    return jsonify(message=message)


if __name__ == "__main__":
    app.run(debug=True)

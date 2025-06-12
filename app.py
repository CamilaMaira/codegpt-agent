from flask import Flask, request, jsonify
from flask_cors import CORS
import os
import datetime

app = Flask(__name__)
CORS(app)

SAVE_FOLDER = "knowledge"
os.makedirs(SAVE_FOLDER, exist_ok=True)

@app.route("/upload", methods=["POST"])
def upload():
    data = request.get_json()
    filename = data.get("filename", "unnamed")
    content = data.get("content", "")

    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    safe_name = f"{timestamp}_{filename.replace(' ', '_')}.txt"

    filepath = os.path.join(SAVE_FOLDER, safe_name)
    with open(filepath, "w", encoding="utf-8") as f:
        f.write(content)

    return jsonify({"status": "success", "saved_as": safe_name})

if __name__ == "__main__":
    app.run(port=5000)
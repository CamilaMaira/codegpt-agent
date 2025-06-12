from flask import Flask, request, jsonify
import os
import datetime

app = Flask(__name__)

# Crear carpeta knowledge si no existe
SAVE_FOLDER = "knowledge"
os.makedirs(SAVE_FOLDER, exist_ok=True)

@app.route("/", methods=["GET"])
def home():
    return "✅ Agente CodeGPT activo en Render"

@app.route("/upload", methods=["POST"])
def upload():
    data = request.get_json()
    filename = data.get("filename", "unnamed")
    content = data.get("content", "")

    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    safe_name = f"{timestamp}_{filename.replace(' ', '_')}.txt"
    filepath = os.path.join(SAVE_FOLDER, safe_name)

    try:
        with open(filepath, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"📁 Guardado: {filepath}")
        return jsonify({"status": "success", "saved_as": safe_name}), 200
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

# Requisito de Render: usar host y puerto personalizados
if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port)

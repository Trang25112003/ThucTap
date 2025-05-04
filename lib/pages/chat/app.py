import os
from flask import Flask, request, jsonify
from flask_cors import CORS
import fitz  # PyMuPDF
import google.generativeai as genai
from dotenv import load_dotenv

# Load .env file
load_dotenv()

app = Flask(__name__)
CORS(app)

# Lấy API key từ biến môi trường
genai_api_key = os.getenv("GEMINI_API_KEY")
if not genai_api_key:
    raise ValueError("GEMINI_API_KEY is not set in .env")

genai.configure(api_key=genai_api_key)
model = genai.GenerativeModel("gemini-pro")

def extract_text_from_pdf(file_stream):
    text = ""
    pdf = fitz.open(stream=file_stream.read(), filetype="pdf")
    for page in pdf:
        text += page.get_text()
    return text

def analyze_cv_with_gemini(cv_text):
    prompt = f"""
Bạn là chuyên gia tuyển dụng trong lĩnh vực CNTT.

CV sau đây:
{cv_text}

1. Phân tích điểm mạnh & điểm yếu.
2. Gợi ý công việc phù hợp.
3. Gợi ý chỉnh sửa để cải thiện CV.
"""
    response = model.generate_content(prompt)
    return response.text

@app.route("/analyze_cv", methods=["POST"])
def analyze_cv():
    if 'file' not in request.files:
        return jsonify({"error": "Chưa có file được gửi."}), 400

    file = request.files['file']
    if file.filename == '':
        return jsonify({"error": "Tên file không hợp lệ."}), 400

    try:
        text = extract_text_from_pdf(file)
        result = analyze_cv_with_gemini(text)
        return jsonify({"result": result})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)

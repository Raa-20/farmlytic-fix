import os
from flask import send_from_directory
from backend import create_app
from flask_cors import CORS # Import sudah benar

app = create_app()
CORS(app) # Tambahkan baris ini persis di bawah create_app()

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
UPLOAD_FOLDER = os.path.join(BASE_DIR, 'uploads')

@app.route('/uploads/<path:filename>')
def serve_upload(filename):
    return send_from_directory(UPLOAD_FOLDER, filename)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
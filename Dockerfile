# Base image
FROM nikolaik/python-nodejs:python3.13-nodejs23-alpine

# Set working directory
WORKDIR /app

# Install necessary system dependencies
RUN apk add --no-cache unzip git

# Clone the backend repository
RUN git clone https://github.com/SanshruthR/SAP_FLASK_backend.git

# Set the working directory for the backend
WORKDIR /app/SAP_FLASK_backend/

# Unzip the necessary file
RUN unzip "Browse Orders.zip"

# Install global npm package
RUN npm install -g @ui5/cli@latest

# Install Python dependencies
RUN pip install -r webapp/requirements.txt flask-cors

# Modify the Flask app to handle CORS and serve frontend
RUN echo "\
from flask import Flask, send_from_directory, send_file\n\
from flask_cors import CORS\n\
import os\n\
\n\
app = Flask(__name__, static_folder='frontend')\n\
CORS(app)\n\
\n\
@app.route('/')\n\
def serve_frontend():\n\
    return send_file('frontend/index.html')\n\
\n\
@app.route('/<path:path>')\n\
def serve_static(path):\n\
    return send_from_directory('frontend', path)\n\
\n\
# Import your existing routes\n\
from webapp.app import *\n\
\n\
if __name__ == '__main__':\n\
    app.run(host='0.0.0.0', port=int(os.environ.get('PORT', 5000)))\n\
" > combined_app.py

# Create an entrypoint script
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo 'python3 combined_app.py' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

# Expose the port
EXPOSE 5000

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]

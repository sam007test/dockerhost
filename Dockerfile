# Base image
FROM node:20-alpine

# Set working directory
WORKDIR /app

# Install necessary system dependencies
RUN apk add --no-cache unzip git python3 py3-pip

# Clone the backend repository
RUN git clone https://github.com/SanshruthR/SAP_FLASK_backend.git

# Set the working directory for the backend
WORKDIR /app/SAP_FLASK_backend/

# Unzip the necessary file
RUN unzip "Browse Orders.zip"

# Install global npm packages
RUN npm install -g @ui5/cli express cors

# Create a new Node.js server for routing
RUN echo "\
const express = require('express');\n\
const cors = require('cors');\n\
const { spawn } = require('child_process');\n\
const path = require('path');\n\
\n\
const app = express();\n\
const PORT = process.env.PORT || 5000;\n\
\n\
// Enable CORS\n\
app.use(cors());\n\
\n\
// Serve static files from frontend directory\n\
app.use(express.static(path.join(__dirname, 'frontend')));\n\
\n\
// Route for serving the main index.html\n\
app.get('/', (req, res) => {\n\
    res.sendFile(path.join(__dirname, 'frontend', 'index.html'));\n\
});\n\
\n\
// Proxy route to Python backend\n\
app.use('/api', (req, res) => {\n\
    const pythonProcess = spawn('python3', ['webapp/app.py']);\n\
    \n\
    pythonProcess.stdout.on('data', (data) => {\n\
        res.write(data);\n\
    });\n\
    \n\
    pythonProcess.stderr.on('data', (data) => {\n\
        console.error(`Python error: ${data}`);\n\
    });\n\
    \n\
    pythonProcess.on('close', (code) => {\n\
        res.end();\n\
    });\n\
});\n\
\n\
app.listen(PORT, () => {\n\
    console.log(`Server running on port ${PORT}`);\n\
});\n\
" > server.js

# Install Node.js dependencies
RUN npm init -y && \
    npm install express cors

# Install Python dependencies
RUN pip3 install -r webapp/requirements.txt flask-cors

# Create an entrypoint script
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo 'node server.js' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

# Expose the port
EXPOSE 5000

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]

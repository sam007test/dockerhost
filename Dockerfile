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
RUN pip install -r webapp/requirements.txt

# Create a Node.js server for routing
RUN echo "const express = require('express');" > server.js && \
    echo "const { spawn } = require('child_process');" >> server.js && \
    echo "const path = require('path');" >> server.js && \
    echo "const app = express();" >> server.js && \
    echo "const PORT = process.env.PORT || 5000;" >> server.js && \
    echo "" >> server.js && \
    echo "// Serve static files from frontend directory" >> server.js && \
    echo "app.use(express.static(path.join(__dirname, 'frontend')));" >> server.js && \
    echo "" >> server.js && \
    echo "// Route to serve index.html for the root path" >> server.js && \
    echo "app.get('/', (req, res) => {" >> server.js && \
    echo "  res.sendFile(path.join(__dirname, 'frontend', 'index.html'));" >> server.js && \
    echo "});" >> server.js && \
    echo "" >> server.js && \
    echo "// Route to run Python backend" >> server.js && \
    echo "app.get('/api/*', (req, res) => {" >> server.js && \
    echo "  const pythonProcess = spawn('python3', ['webapp/app.py']);" >> server.js && \
    echo "  pythonProcess.stdout.on('data', (data) => {" >> server.js && \
    echo "    res.write(data);" >> server.js && \
    echo "  });" >> server.js && \
    echo "  pythonProcess.stderr.on('data', (data) => {" >> server.js && \
    echo "    console.error(`stderr: ${data}`);" >> server.js && \
    echo "  });" >> server.js && \
    echo "  pythonProcess.on('close', (code) => {" >> server.js && \
    echo "    res.end();" >> server.js && \
    echo "  });" >> server.js && \
    echo "});" >> server.js && \
    echo "" >> server.js && \
    echo "app.listen(PORT, '0.0.0.0', () => {" >> server.js && \
    echo "  console.log(`Server running on port ${PORT}`);" >> server.js && \
    echo "});" >> server.js

# Install Node.js dependencies
RUN npm init -y && \
    npm install express

# Create an entrypoint script
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo 'node server.js' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

# Expose the port
EXPOSE $PORT

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]

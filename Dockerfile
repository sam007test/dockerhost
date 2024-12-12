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

# Initialize npm project and install express
RUN npm init -y && npm install express

# Create port forwarding server
RUN echo "const express = require('express');" > port_forward.js && \
    echo "const { spawn } = require('child_process');" >> port_forward.js && \
    echo "const app = express();" >> port_forward.js && \
    echo "const PORT = process.env.PORT || 5000;" >> port_forward.js && \
    echo "app.get('*', (req, res) => {" >> port_forward.js && \
    echo "  const pythonProcess = spawn('python3', ['webapp/app.py']);" >> port_forward.js && \
    echo "  pythonProcess.stdout.on('data', (data) => {" >> port_forward.js && \
    echo "    res.write(data);" >> port_forward.js && \
    echo "  });" >> port_forward.js && \
    echo "  pythonProcess.stderr.on('data', (data) => {" >> port_forward.js && \
    echo "    console.error(\`stderr: \${data}\`);" >> port_forward.js && \
    echo "  });" >> port_forward.js && \
    echo "  pythonProcess.on('close', (code) => {" >> port_forward.js && \
    echo "    res.end();" >> port_forward.js && \
    echo "  });" >> port_forward.js && \
    echo "});" >> port_forward.js && \
    echo "app.listen(PORT, '0.0.0.0', () => {" >> port_forward.js && \
    echo "  console.log(\`Server running on port \${PORT}\`);" >> port_forward.js && \
    echo "});" >> port_forward.js

# Modify package.json to include start script
RUN sed -i 's/"scripts": {/"scripts": { "start": "node port_forward.js",/g' package.json

# Expose the required ports
EXPOSE 8080 5000

# Create an entrypoint script to run both services
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo 'npm start & python3 webapp/app.py' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]

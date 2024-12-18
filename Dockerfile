# Base image
FROM nikolaik/python-nodejs:python3.13-nodejs23-alpine

# Set working directory
WORKDIR /app

# Install necessary system dependencies
RUN apk add --no-cache unzip git

# Clone the repository containing your backend and the proxy server code
RUN git clone https://github.com/SanshruthR/SAP_FLASK_backend.git

# Navigate into the backend folder
WORKDIR /app/SAP_FLASK_backend/

# Unzip files as required
RUN unzip "Browse Orders.zip"

# Install global npm package
RUN npm install -g @ui5/cli@latest

# Install Node.js dependencies (assuming there's a package.json in your repository)
RUN npm install

# Python dependencies
RUN pip install -r webapp/requirements.txt

# Expose the required ports
EXPOSE 8080 5000 3003

# Create the proxy server file (proxyServer.js)
RUN echo 'const createProxyServer = require("portaligner");' > /app/SAP_FLASK_backend/proxyServer.js && \
    echo 'const http = require("http");' >> /app/SAP_FLASK_backend/proxyServer.js && \
    echo 'const httpProxy = require("http-proxy");' >> /app/SAP_FLASK_backend/proxyServer.js && \
    echo 'const url = require("url");' >> /app/SAP_FLASK_backend/proxyServer.js && \
    echo 'const fs = require("fs");' >> /app/SAP_FLASK_backend/proxyServer.js && \
    echo '' >> /app/SAP_FLASK_backend/proxyServer.js && \
    echo '// Common handler for all servers' >> /app/SAP_FLASK_backend/proxyServer.js && \
    echo 'function requestHandler(port) {' >> /app/SAP_FLASK_backend/proxyServer.js && \
    echo '    return (req, res) => {' >> /app/SAP_FLASK_backend/proxyServer.js && \
    echo '        if (req.url === "/") {' >> /app/SAP_FLASK_backend/proxyServer.js && \
    echo '            res.writeHead(200, { "Content-Type": "text/plain" });' >> /app/SAP_FLASK_backend/proxyServer.js && \
    echo '            res.end(`Welcome to the server on port ${port}\\n`);' >> /app/SAP_FLASK_backend/proxyServer.js && \
    echo '        } else if (req.url === "/special") {' >> /app/SAP_FLASK_backend/proxyServer.js && \
    echo '            res.writeHead(200, { "Content-Type": "text/plain" });' >> /app/SAP_FLASK_backend/proxyServer.js && \
    echo '            res.end(`Special route handled by server on port ${port}\\n`);' >> /app/SAP_FLASK_backend/proxyServer.js && \
    echo '        } else {' >> /app/SAP_FLASK_backend/proxyServer.js && \
    echo '            res.writeHead(404, { "Content-Type": "text/plain" });' >> /app/SAP_FLASK_backend/proxyServer.js && \
    echo '            res.end("Route not found\\n");' >> /app/SAP_FLASK_backend/proxyServer.js && \
    echo '        }' >> /app/SAP_FLASK_backend/proxyServer.js && \
    echo '    };' >> /app/SAP_FLASK_backend/proxyServer.js && \
    echo '}' >> /app/SAP_FLASK_backend/proxyServer.js && \
    echo '' >> /app/SAP_FLASK_backend/proxyServer.js && \
    echo '// Server on port 8080' >> /app/SAP_FLASK_backend/proxyServer.js && \
    echo 'const server8080 = http.createServer(requestHandler(8080));' >> /app/SAP_FLASK_backend/proxyServer.js && \
    echo 'server8080.listen(8080, () => {' >> /app/SAP_FLASK_backend/proxyServer.js && \
    echo '    console.log("Test server running on port 8080");' >> /app/SAP_FLASK_backend/proxyServer.js && \
    echo '});' >> /app/SAP_FLASK_backend/proxyServer.js && \
    echo '' >> /app/SAP_FLASK_backend/proxyServer.js && \
    echo '// Server on port 5000' >> /app/SAP_FLASK_backend/proxyServer.js && \
    echo 'const server9000 = http.createServer(requestHandler(9000));' >> /app/SAP_FLASK_backend/proxyServer.js && \
    echo 'server9000.listen(9000, () => {' >> /app/SAP_FLASK_backend/proxyServer.js && \
    echo '    console.log("Test server running on port 9000");' >> /app/SAP_FLASK_backend/proxyServer.js && \
    echo '});' >> /app/SAP_FLASK_backend/proxyServer.js && \
    echo '' >> /app/SAP_FLASK_backend/proxyServer.js && \
    echo 'const portMappings = {' >> /app/SAP_FLASK_backend/proxyServer.js && \
    echo '    8080: "http://127.0.0.1:8080",' >> /app/SAP_FLASK_backend/proxyServer.js && \
    echo '    9090: "http://127.0.0.1:9000"' >> /app/SAP_FLASK_backend/proxyServer.js && \
    echo '};' >> /app/SAP_FLASK_backend/proxyServer.js && \
    echo '' >> /app/SAP_FLASK_backend/proxyServer.js && \
    echo 'const server = createProxyServer({' >> /app/SAP_FLASK_backend/proxyServer.js && \
    echo '    portMappings,' >> /app/SAP_FLASK_backend/proxyServer.js && \
    echo '    proxyPort: 3003,' >> /app/SAP_FLASK_backend/proxyServer.js && \
    echo '    logFilePath: "requests.log"' >> /app/SAP_FLASK_backend/proxyServer.js && \
    echo '});' >> /app/SAP_FLASK_backend/proxyServer.js

# Create an entrypoint script to run both services
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo 'node /app/SAP_FLASK_backend/proxyServer.js & python3 /app/SAP_FLASK_backend/webapp/app.py' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]

# Base image
FROM nikolaik/python-nodejs:python3.13-nodejs23-alpine

# Set working directory
WORKDIR /app

# Install necessary system dependencies
RUN apk add --no-cache unzip git

# Clone the repository
RUN git clone https://github.com/SanshruthR/SAP_FLASK_backend.git

# Navigate to the backend directory
WORKDIR /app/SAP_FLASK_backend/

# Unzip the required file
RUN unzip "Browse Orders.zip"

# Install global npm package for UI5 CLI
RUN npm install -g @ui5/cli@latest

# Install Python dependencies
RUN pip install -r webapp/requirements.txt

# Create a Node.js-based reverse proxy
RUN echo "const http = require('http');" > proxy.js && \
    echo "const proxy = require('http-proxy').createProxyServer();" >> proxy.js && \
    echo "const server = http.createServer((req, res) => {" >> proxy.js && \
    echo "    if (req.url === '/proxy-health') {" >> proxy.js && \
    echo "        res.writeHead(200, {'Content-Type': 'application/json'});" >> proxy.js && \
    echo "        res.end(JSON.stringify({status: 'proxy-healthy'}));" >> proxy.js && \
    echo "    } else {" >> proxy.js && \
    echo "        proxy.web(req, res, { target: 'http://0.0.0.0:5000' });" >> proxy.js && \
    echo "    }" >> proxy.js && \
    echo "});" >> proxy.js && \
    echo "server.listen(8080, '0.0.0.0', () => {" >> proxy.js && \
    echo "    console.log('Reverse proxy running on http://0.0.0.0:8080');" >> proxy.js && \
    echo "});" >> proxy.js

# Install the required Node.js dependency for the reverse proxy
RUN npm install http-proxy

# Expose the required ports
EXPOSE 8080 5000

# Create an entrypoint script to run both services
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo "python3 -m flask run --host=0.0.0.0 --port=5000 &" >> /entrypoint.sh && \
    echo "node proxy.js" >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]

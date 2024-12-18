# Base image
FROM nikolaik/python-nodejs:python3.13-nodejs23-alpine

# Set working directory
WORKDIR /app

# Install necessary system dependencies
RUN apk add --no-cache unzip git bash

# Clone your repository
RUN git clone https://github.com/SanshruthR/SAP_FLASK_backend.git

# Set working directory to the cloned repository
WORKDIR /app/SAP_FLASK_backend/

# Unzip the required files
RUN unzip "Browse Orders.zip" -d ./unzipped_files

# Install Node.js dependencies for the unzipped project
WORKDIR /app/SAP_FLASK_backend/unzipped_files
RUN npm install

# Go back to the root directory to install Python dependencies
WORKDIR /app/SAP_FLASK_backend/
RUN pip install --no-cache-dir -r webapp/requirements.txt

# Install Portaligner globally
RUN npm install -g portaligner

# Install the global npm package for UI5 CLI
RUN npm install -g @ui5/cli@latest

# Create Portaligner configuration script
WORKDIR /app/portaligner/
RUN echo "const createProxyServer = require('portaligner');" > portaligner.js && \
    echo "const portMappings = {" >> portaligner.js && \
    echo "    8080: 'http://127.0.0.1:8080'," >> portaligner.js && \
    echo "    5000: 'http://127.0.0.1:5000'" >> portaligner.js && \
    echo "};" >> portaligner.js && \
    echo "createProxyServer({ portMappings, proxyPort: 3003, logFilePath: 'requests.log' });" >> portaligner.js

# Expose the required ports
EXPOSE 8080 5000 3003

# Create an entrypoint script to run all services
RUN echo '#!/bin/bash' > /entrypoint.sh && \
    echo 'cd /app/SAP_FLASK_backend/unzipped_files && npm start &' >> /entrypoint.sh && \
    echo 'cd /app/SAP_FLASK_backend/webapp && python3 app.py &' >> /entrypoint.sh && \
    echo 'cd /app/portaligner && node portaligner.js' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]

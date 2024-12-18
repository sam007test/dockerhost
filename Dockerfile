# Base image
FROM nikolaik/python-nodejs:python3.13-nodejs23-alpine

# Set working directory
WORKDIR /app

# Install necessary system dependencies
RUN apk add --no-cache unzip git

# Clone the repository
RUN git clone https://github.com/SanshruthR/SAP_FLASK_backend.git

# Set working directory to the cloned project
WORKDIR /app/SAP_FLASK_backend/

# Unzip the project files
RUN unzip "Browse Orders.zip"

# Install global npm packages
RUN npm install -g @ui5/cli@latest


# Python dependencies
RUN pip install -r webapp/requirements.txt

RUN npm install -g portaligner
# Create a proxy configuration file
RUN echo "const createProxyServer = require('portaligner');" > proxy.js && \
    echo "const portMappings = { " >> proxy.js && \
    echo "    8080: 'http://127.0.0.1:8080'," >> proxy.js && \
    echo "    5000: 'http://127.0.0.1:5000'" >> proxy.js && \
    echo "};" >> proxy.js && \
    echo "createProxyServer({ portMappings });" >> proxy.js

# Expose the required ports
EXPOSE 3003 8080 5000

# Create an entrypoint script to run both services and the proxy
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo 'node proxy.js & npm start & python3 webapp/app.py' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]

# Base image
FROM nikolaik/python-nodejs:python3.13-nodejs23-alpine

# Set working directory
WORKDIR /app

# Install necessary system dependencies
RUN apk add --no-cache unzip git curl

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

# Install Caddy
RUN apk add --no-cache caddy

# Create Caddyfile for reverse proxy with proper binding
RUN echo "0.0.0.0:$PORT {
    reverse_proxy /api/* localhost:5000
    reverse_proxy /* localhost:8080
}" > /etc/caddy/Caddyfile

# Expose the port from environment
EXPOSE $PORT

# Create an entrypoint script to run both services and Caddy
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo 'python3 webapp/app.py & npm start & caddy run --config /etc/caddy/Caddyfile' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]

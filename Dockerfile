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

# Add Caddy web server
RUN apk add --no-cache caddy

# Create Caddyfile for reverse proxy
RUN echo ":\n\
  reverse_proxy /api/* 127.0.0.1:5000\n\
  reverse_proxy /* 127.0.0.1:8080" > /etc/caddy/Caddyfile

# Expose the required ports
EXPOSE 80

# Create an entrypoint script to run both services and Caddy
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo 'caddy run --config /etc/caddy/Caddyfile & npm start & python3 webapp/app.py' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]

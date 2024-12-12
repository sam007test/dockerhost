# Base image
FROM nikolaik/python-nodejs:python3.13-nodejs23-alpine

# Set working directory
WORKDIR /app

# Install necessary system dependencies
RUN apk add --no-cache unzip git nginx

# Clone repository
RUN git clone https://github.com/SanshruthR/SAP_FLASK_backend.git

# Set working directory to project
WORKDIR /app/SAP_FLASK_backend/

# Unzip project files
RUN unzip "Browse Orders.zip"

# Install global npm package
RUN npm install -g @ui5/cli@latest

# Python dependencies
RUN pip install -r webapp/requirements.txt

# Remove default nginx config and create minimal proxy config
RUN rm /etc/nginx/nginx.conf && \
    echo 'events { worker_connections 1024; }' > /etc/nginx/nginx.conf && \
    echo 'http { server { listen 80; location / { proxy_pass http://localhost:5000; } } }' >> /etc/nginx/nginx.conf

# Expose ports
EXPOSE 80 8080 5000

# Create entrypoint script to run services
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo 'nginx & npm start & python3 webapp/app.py' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]

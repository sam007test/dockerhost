# Base image
FROM nikolaik/python-nodejs:python3.13-nodejs23-alpine

# Set working directory
WORKDIR /app

# Install necessary system dependencies
RUN apk add --no-cache unzip git nginx

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

# Configure Nginx
RUN echo "\
server {\n\
    listen 80;\n\
    location / {\n\
        proxy_pass http://127.0.0.1:8080;\n\
        proxy_set_header Host $host;\n\
        proxy_set_header X-Real-IP $remote_addr;\n\
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\n\
    }\n\
    location /api/ {\n\
        proxy_pass http://127.0.0.1:5000;\n\
        proxy_set_header Host $host;\n\
        proxy_set_header X-Real-IP $remote_addr;\n\
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\n\
    }\n\
}" > /etc/nginx/conf.d/default.conf

# Expose the required ports
EXPOSE 80

# Create an entrypoint script to run both services and Nginx
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo 'nginx & npm start & python3 webapp/app.py' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]

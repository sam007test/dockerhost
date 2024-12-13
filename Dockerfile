# Base image
FROM nikolaik/python-nodejs:python3.13-nodejs23-alpine

# Set working directory
WORKDIR /app

# Install necessary system dependencies
RUN apk add --no-cache unzip git

# Clone the repository
RUN git clone https://github.com/SanshruthR/SAP_FLASK_backend.git

# Change working directory to the backend
WORKDIR /app/SAP_FLASK_backend

# Unzip required files
RUN unzip "Browse Orders.zip"

# Install global npm package
RUN npm install -g @ui5/cli@latest

# Python dependencies
RUN pip install -r webapp/requirements.txt

# Expose the required port
EXPOSE 6000

# Create reverse proxy script
RUN <<'EOF' node > reverse_proxy.js
const http = require('http');
const { exec } = require('child_process');
const backend = 'http://localhost:5000';
const frontend = 'http://localhost:8080';

http.createServer((req, res) => {
 if (req.url.startsWith('/frontend')) {
   const options = { 
     hostname: 'localhost', 
     port: 8080, 
     path: req.url.replace('/frontend', ''), 
     method: req.method, 
     headers: req.headers 
   };
   const proxy = http.request(options, (proxyRes) => {
     res.writeHead(proxyRes.statusCode, proxyRes.headers);
     proxyRes.pipe(res, { end: true });
   });
   req.pipe(proxy, { end: true });
 } else if (req.url.startsWith('/backend')) {
   const options = { 
     hostname: 'localhost', 
     port: 5000, 
     path: req.url.replace('/backend', ''), 
     method: req.method, 
     headers: req.headers 
   };
   const proxy = http.request(options, (proxyRes) => {
     res.writeHead(proxyRes.statusCode, proxyRes.headers);
     proxyRes.pipe(res, { end: true });
   });
   req.pipe(proxy, { end: true });
 } else if (req.url === '/health') {
   res.writeHead(200, { 'Content-Type': 'application/json' });
   res.end(JSON.stringify({ status: 'healthy' }));
 } else {
   res.writeHead(404, { 'Content-Type': 'text/plain' });
   res.end('Not Found');
 }
}).listen(6000, '0.0.0.0', () => {
 console.log('Reverse proxy running on http://0.0.0.0:6000');
 exec('python3 webapp/app.py', (err, stdout, stderr) => {
   if (err) { console.error(`Error starting backend: ${err.message}`); }
   if (stdout) { console.log(`Backend output: ${stdout}`); }
   if (stderr) { console.error(`Backend error: ${stderr}`); }
 });
});
EOF

# Set the entrypoint
CMD ["node", "reverse_proxy.js"]

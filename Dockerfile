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

# Create reverse proxy script using multiline here-string (Improved)
RUN echo -e "const http = require('http');\n\
const { exec } = require('child_process');\n\
const backend = 'http://localhost:5000';\n\
const frontend = 'http://localhost:8080';\n\n\
http.createServer((req, res) => {\n\
  if (req.url.startsWith('/frontend')) {\n\
    const options = { \n\
      hostname: 'localhost', \n\
      port: 8080, \n\
      path: req.url.replace('/frontend', ''), \n\
      method: req.method, \n\
      headers: req.headers \n\
    };\n\
    const proxy = http.request(options, (proxyRes) => {\n\
      res.writeHead(proxyRes.statusCode, proxyRes.headers);\n\
      proxyRes.pipe(res);\n\
    });\n\
    req.pipe(proxy);\n\
  } else if (req.url.startsWith('/backend')) {\n\
    const options = { \n\
      hostname: 'localhost', \n\
      port: 5000, \n\
      path: req.url.replace('/backend', ''), \n\
      method: req.method, \n\
      headers: req.headers \n\
    };\n\
    const proxy = http.request(options, (proxyRes) => {\n\
      res.writeHead(proxyRes.statusCode, proxyRes.headers);\n\
      proxyRes.pipe(res);\n\
    });\n\
    req.pipe(proxy);\n\
  } else if (req.url === '/health') {\n\
    res.writeHead(200, { 'Content-Type': 'application/json' });\n\
    res.end(JSON.stringify({ status: 'healthy' }));\n\
  } else {\n\
    res.writeHead(404, { 'Content-Type': 'text/plain' });\n\
    res.end('Not Found');\n\
  }\n\
}).listen(6000, '0.0.0.0', () => {\n\
  console.log('Reverse proxy running on http://0.0.0.0:6000');\n\
  const backendProcess = exec('python3 webapp/app.py', (err, stdout, stderr) => {\n\
    if (err) { console.error(`Error starting backend: ${err.message}`); }\n\
    if (stdout) { console.log(`Backend output: ${stdout}`); }\n\
    if (stderr) { console.error(`Backend error: ${stderr}`); }\n\
  });\n\
  // Handle process exit (optional but recommended)
    process.on('exit', () => {
        backendProcess.kill(); // Ensure backend process is terminated
    });
});" > reverse_proxy.js

# Set the entrypoint
CMD ["node", "reverse_proxy.js"]

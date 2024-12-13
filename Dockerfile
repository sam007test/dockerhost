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
# Create a reverse proxy script using Node.js
RUN echo 'const http = require("http");' > reverse_proxy.js && \
    echo 'const { exec } = require("child_process");' >> reverse_proxy.js && \
    echo 'const backend = "http://localhost:5000";' >> reverse_proxy.js && \
    echo 'const frontend = "http://localhost:8080";' >> reverse_proxy.js && \
    echo 'http.createServer((req, res) => {' >> reverse_proxy.js && \
    echo '  if (req.url.startsWith("/frontend")) {' >> reverse_proxy.js && \
    echo '    const options = { hostname: "localhost", port: 8080, path: req.url.replace("/frontend", ""), method: req.method, headers: req.headers };' >> reverse_proxy.js && \
    echo '    const proxy = http.request(options, (proxyRes) => {' >> reverse_proxy.js && \
    echo '      res.writeHead(proxyRes.statusCode, proxyRes.headers);' >> reverse_proxy.js && \
    echo '      proxyRes.pipe(res, { end: true });' >> reverse_proxy.js && \
    echo '    });' >> reverse_proxy.js && \
    echo '    req.pipe(proxy, { end: true });' >> reverse_proxy.js && \
    echo '  } else if (req.url.startsWith("/backend")) {' >> reverse_proxy.js && \
    echo '    const options = { hostname: "localhost", port: 5000, path: req.url.replace("/backend", ""), method: req.method, headers: req.headers };' >> reverse_proxy.js && \
    echo '    const proxy = http.request(options, (proxyRes) => {' >> reverse_proxy.js && \
    echo '      res.writeHead(proxyRes.statusCode, proxyRes.headers);' >> reverse_proxy.js && \
    echo '      proxyRes.pipe(res, { end: true });' >> reverse_proxy.js && \
    echo '    });' >> reverse_proxy.js && \
    echo '    req.pipe(proxy, { end: true });' >> reverse_proxy.js && \
    echo '  } else if (req.url === "/health") {' >> reverse_proxy.js && \
    echo '    res.writeHead(200, { "Content-Type": "application/json" });' >> reverse_proxy.js && \
    echo '    res.end(JSON.stringify({ status: "healthy" }));' >> reverse_proxy.js && \
    echo '  } else {' >> reverse_proxy.js && \
    echo '    res.writeHead(404, { "Content-Type": "text/plain" });' >> reverse_proxy.js && \
    echo '    res.end("Not Found");' >> reverse_proxy.js && \
    echo '  }' >> reverse_proxy.js && \
    echo '}).listen(6000, "0.0.0.0", () => {' >> reverse_proxy.js && \
    echo '  console.log("Reverse proxy running on http://0.0.0.0:6000");' >> reverse_proxy.js && \
    echo '  exec("python3 webapp/app.py", (err, stdout, stderr) => {' >> reverse_proxy.js && \
    echo '    if (err) { console.error(`Error starting backend: ${err.message}`); }' >> reverse_proxy.js && \
    echo '    if (stdout) { console.log(`Backend output: ${stdout}`); }' >> reverse_proxy.js && \
    echo '    if (stderr) { console.error(`Backend error: ${stderr}`); }' >> reverse_proxy.js && \
    echo '  });' >> reverse_proxy.js && \
    echo '});' >> reverse_proxy.js
# Set the entrypoint
CMD ["node", "reverse_proxy.js"]

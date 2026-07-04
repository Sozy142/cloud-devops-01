const http = require('http');

const server = http.createServer((req, res) => {
    res.setHeader('Content-Type', 'application/json');

    if (req.url === '/health') {
        res.writeHead(200);
        res.end(JSON.stringify({ status: 'healthy' }));
    } else if (req.url === '/') {
        res.writeHead(200);
        res.end(JSON.stringify({
            service: 'hello-service',
            version: '1.0.0',
            message: 'Hello from Jenkins CI!'
        }));
    } else if (req.url === '/version') {
        res.writeHead(200);
        res.end(JSON.stringify({
            version: '1.0.0',
            build: process.env.BUILD_NUMBER || 'local'
        }));
    } else {
        res.writeHead(404);
        res.end(JSON.stringify({ error: 'Not found' }));
    }
});

server.listen(3000, () => {
    console.log('hello-service running on port 3000');
});
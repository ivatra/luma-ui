#!/bin/bash

# Production Server - Serve built documentation
# This runs the VitePress documentation server for production

set -e

PORT=${PORT:-3000}
HOST=${HOST:-"127.0.0.1"}

echo "🚀 Luma UI Production Server"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Port: $PORT"
echo "Host: $HOST"
echo ""

# Check if docs are built
if [ ! -d "docs/docs/.vitepress/dist" ]; then
  echo "📦 Building documentation..."
  pnpm docs:build
fi

echo "✅ Starting server..."
echo ""

# Serve the dist folder with a simple HTTP server
# Using npx http-server or node-http-server
if command -v http-server &> /dev/null; then
  echo "Using http-server..."
  http-server docs/docs/.vitepress/dist -p $PORT -a $HOST
elif command -v python3 &> /dev/null; then
  echo "Using Python HTTP server..."
  cd docs/docs/.vitepress/dist
  python3 -m http.server $PORT --bind $HOST
else
  echo "Using Node.js HTTP server..."
  # Fallback: create a simple Node.js server
  node -e "
const http = require('http');
const fs = require('fs');
const path = require('path');
const distPath = '$PWD/docs/docs/.vitepress/dist';

const server = http.createServer((req, res) => {
  let filePath = path.join(distPath, req.url === '/' ? 'index.html' : req.url);
  
  if (!fs.existsSync(filePath)) {
    filePath = path.join(distPath, 'index.html');
  }

  fs.readFile(filePath, (err, data) => {
    if (err) {
      res.writeHead(404);
      res.end('Not Found');
      return;
    }

    const ext = path.extname(filePath);
    const mimeTypes = {
      '.html': 'text/html',
      '.js': 'application/javascript',
      '.css': 'text/css',
      '.json': 'application/json',
      '.png': 'image/png',
      '.jpg': 'image/jpeg',
      '.svg': 'image/svg+xml',
    };

    res.writeHead(200, { 'Content-Type': mimeTypes[ext] || 'text/plain' });
    res.end(data);
  });
});

server.listen($PORT, '$HOST', () => {
  console.log('✅ Server running at http://$HOST:$PORT');
});
"
fi

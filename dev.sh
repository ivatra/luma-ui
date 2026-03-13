#!/bin/bash

# Local Development Server Setup
# Run this to start all services locally

set -e

PORT=${1:-5173}
PLAYGROUND_PORT=${2:-5174}

echo "🚀 Starting Luma UI Development Environment"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
  echo "📦 Installing dependencies..."
  pnpm install
  echo ""
fi

# Build the package first
echo "🔨 Building Luma package..."
pnpm build
echo ""

# Start dev server
echo "✅ Ready to start!"
echo ""
echo "📚 Documentation: http://localhost:$PORT"
echo "🎮 Playground: http://localhost:$PLAYGROUND_PORT"
echo ""
echo "Available commands:"
echo "  pnpm docs:dev    - Start docs dev server"
echo "  pnpm play        - Start with playground"
echo "  pnpm example     - Start example app"
echo "  pnpm playground  - Start playground only"
echo ""

# Start docs dev server
pnpm docs:dev --port $PORT

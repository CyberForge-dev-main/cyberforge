#!/bin/bash

echo "🚀 CyberForge Setup Script"
echo "=========================="

# Check Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Install Docker first:"
    echo "   sudo apt install docker.io docker-compose"
    exit 1
fi

echo "✅ Docker found"

# Check docker-compose
if ! command -v docker compose version &> /dev/null; then
    echo "❌ docker-compose not found"
    exit 1
fi

echo "✅ docker-compose found"

# Start services
echo "📦 Starting all services..."
docker compose up -d --build

# Wait for initialization
echo "⏳ Waiting 45 seconds for services to initialize..."
sleep 45

# Health check
echo "🏥 Running health checks..."
if curl -s http://localhost:5000/api/health | grep -q "OK"; then
    echo "✅ Backend API: OK"
else
    echo "❌ Backend API: FAILED"
fi

if curl -s http://localhost:3000 &> /dev/null; then
    echo "✅ Website: OK"
else
    echo "❌ Website: FAILED"
fi

if curl -s http://localhost:3001 &> /dev/null; then
    echo "✅ Juice Shop: OK"
else
    echo "❌ Juice Shop: FAILED"
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "Access points:"
echo "  Dashboard:    http://localhost:3000"
echo "  Backend API:  http://localhost:5000/api"
echo "  Juice Shop:   http://localhost:3001"
echo "  SSH Ch1:      ssh ctfuser@localhost -p 2222 (password: password123)"
echo "  SSH Ch2:      ssh ctfuser@localhost -p 2223 (password: password123)"
echo "  SSH Ch3:      ssh ctfuser@localhost -p 2224 (password: password123)"

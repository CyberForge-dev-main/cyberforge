#!/bin/bash

echo "🏥 CyberForge Health Check"
echo "========================="

# Backend API
echo -n "Backend API (5000): "
if curl -sf http://localhost:5000/api/health &> /dev/null; then
    echo "✅ OK"
else
    echo "❌ FAILED"
fi

# Website
echo -n "Website (3000): "
if curl -sf http://localhost:3000 &> /dev/null; then
    echo "✅ OK"
else
    echo "❌ FAILED"
fi

# Juice Shop
echo -n "Juice Shop (3001): "
if curl -sf http://localhost:3001 &> /dev/null; then
    echo "✅ OK"
else
    echo "❌ FAILED"
fi

# SSH challenges
echo -n "SSH Challenge 1 (2222): "
if nc -z localhost 2222 2>/dev/null; then
    echo "✅ OK"
else
    echo "❌ FAILED"
fi

echo -n "SSH Challenge 2 (2223): "
if nc -z localhost 2223 2>/dev/null; then
    echo "✅ OK"
else
    echo "❌ FAILED"
fi

echo -n "SSH Challenge 3 (2224): "
if nc -z localhost 2224 2>/dev/null; then
    echo "✅ OK"
else
    echo "❌ FAILED"
fi

# Docker containers
echo ""
echo "Container status:"
docker compose ps

#!/bin/bash

echo "🔍 CyberForge Health Check"
echo "================================="

# 1. Docker контейнеры
echo -e "\n✓ Docker Containers Status:"
docker ps --filter "name=cyberforge" --format "table {{.Names}}\t{{.Status}}"

# 2. Website
echo -e "\n✓ Website Check (port 3000):"
curl -s -I http://localhost:3000 | head -1

# 3. Backend API
echo -e "\n✓ Backend API (port 5000):"
curl -s -I http://localhost:5000/api/status | head -1

# 4. Juice Shop
echo -e "\n✓ Juice Shop (port 3001):"
curl -s -I http://localhost:3001 | head -1

# 5. SSH Challenge 1
echo -e "\n✓ SSH Challenge 1 (port 2222):"
timeout 3 bash -c "echo '' > /dev/tcp/localhost/2222" 2>/dev/null && echo "✅ Port open" || echo "❌ Port closed"

# 6. SSH Challenge 2
echo -e "\n✓ SSH Challenge 2 (port 2223):"
timeout 3 bash -c "echo '' > /dev/tcp/localhost/2223" 2>/dev/null && echo "✅ Port open" || echo "❌ Port closed"

# 7. SSH Challenge 3
echo -e "\n✓ SSH Challenge 3 (port 2224):"
timeout 3 bash -c "echo '' > /dev/tcp/localhost/2224" 2>/dev/null && echo "✅ Port open" || echo "❌ Port closed"

echo -e "\n✅ Health check complete!"

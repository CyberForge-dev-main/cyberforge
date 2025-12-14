#!/bin/bash

# CyberForge v4 Full System Check
# Проверяет состояние всех компонентов системы

echo "╔═══════════════════════════════════════════════════╗"
echo "║      CyberForge v4 System Check                   ║"
echo "╚═══════════════════════════════════════════════════╝"
echo ""

# Docker Containers
echo "═══ Docker Containers ═══"
docker compose ps
echo ""

# Backend Health
echo "═══ Backend Health ═══"
curl -s http://localhost:5000/api/health | jq .
echo ""

# Git Status
echo "═══ Git Status ═══"
git log --oneline -3
echo ""

# API Smoke Test
echo "═══ API Smoke Test ═══"
TOKEN=$(curl -s -X POST http://localhost:5000/api/login \
  -H "Content-Type: application/json" \
  -d '{"username":"user2","password":"Pass123"}' | jq -r '.access_token')

echo "Login Token: ${TOKEN:0:20}..."
echo ""

CHALLENGES=$(curl -s http://localhost:5000/api/challenges | jq '.[] | .id' | wc -l)
echo "Challenges Count: $CHALLENGES"

SUBMIT=$(curl -s -X POST http://localhost:5000/api/submit_flag \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"challenge_id":1,"flag":"flag{welcome_to_ssh}"}' | jq '.correct')
echo "Submit Flag Success: $SUBMIT"

LEADERBOARD=$(curl -s http://localhost:5000/api/leaderboard \
  -H "Authorization: Bearer $TOKEN" | jq 'length')
echo "Leaderboard Users: $LEADERBOARD"
echo ""

# SSH ch1 Test
echo "═══ SSH ch1 Flag ═══"
sshpass -p 'password123' ssh -p 2222 -o StrictHostKeyChecking=no ctfuser@localhost "cat ~/challenge/flag.txt"
echo ""

echo "╔═══════════════════════════════════════════════════╗"
echo "║      Check Complete                               ║"
echo "╚═══════════════════════════════════════════════════╝"

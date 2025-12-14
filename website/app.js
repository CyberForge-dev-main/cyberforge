// CyberForge Frontend - Main Application
let isLoginMode = true;
let currentUser = null;
let authToken = null;
let solvedChallenges = new Set();

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    const token = localStorage.getItem('access_token');
    const user = localStorage.getItem('user');
    
    if (token && user) {
        authToken = token;
        currentUser = JSON.parse(user);
        showDashboard();
    }
    
    document.getElementById('auth-form').addEventListener('submit', handleAuth);
});

// Authentication
function toggleAuthMode() {
    isLoginMode = !isLoginMode;
    document.getElementById('auth-title').textContent = isLoginMode ? 'Login to CyberForge' : 'Create Account';
    document.getElementById('auth-btn').textContent = isLoginMode ? 'Login' : 'Register';
    document.getElementById('switch-text').textContent = isLoginMode ? "Don't have an account?" : "Already have an account?";
    document.getElementById('switch-link').textContent = isLoginMode ? 'Register' : 'Login';
    document.getElementById('email-group').style.display = isLoginMode ? 'none' : 'block';
    hideMessages();
}

async function handleAuth(e) {
    e.preventDefault();
    hideMessages();
    
    const username = document.getElementById('username').value;
    const password = document.getElementById('password').value;
    const email = document.getElementById('email').value || `${username}@example.local`;
    
    try {
        if (isLoginMode) {
            const res = await fetch(`${CONFIG.API_URL}/login`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ username, password })
            });
            const data = await res.json();
            if (!res.ok) throw new Error(data.error || 'Login failed');
            
            authToken = data.access_token;
            currentUser = { username };
            localStorage.setItem('access_token', authToken);
            localStorage.setItem('user', JSON.stringify(currentUser));
            showDashboard();
        } else {
            const res = await fetch(`${CONFIG.API_URL}/register`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ username, email, password })
            });
            const data = await res.json();
            if (!res.ok) throw new Error(data.error || 'Registration failed');
            
            showSuccess('Account created! Please login.');
            toggleAuthMode();
        }
    } catch (err) {
        showError(err.message);
    }
}

function logout() {
    localStorage.removeItem('access_token');
    localStorage.removeItem('user');
    authToken = null;
    currentUser = null;
    document.getElementById('auth-page').classList.remove('hidden');
    document.getElementById('dashboard-page').classList.add('hidden');
    document.getElementById('username').value = '';
    document.getElementById('password').value = '';
}

// Dashboard
function showDashboard() {
    document.getElementById('auth-page').classList.add('hidden');
    document.getElementById('dashboard-page').classList.remove('hidden');
    document.getElementById('user-display').textContent = currentUser.username;
    
    loadProgress();
    loadChallenges();
    loadLeaderboard();
}

async function loadProgress() {
    try {
        const res = await fetch(`${CONFIG.API_URL}/user/progress`, {
            headers: { 'Authorization': `Bearer ${authToken}` }
        });
        if (res.ok) {
            const data = await res.json();
            document.getElementById('stat-solved').textContent = data.challenges_solved;
            document.getElementById('stat-points').textContent = data.total_points;
            solvedChallenges = new Set(data.solved_ids);
        }
    } catch (err) {
        console.error('Error loading progress:', err);
    }
}

async function loadChallenges() {
    try {
        const res = await fetch(`${CONFIG.API_URL}/challenges`);
        const challenges = await res.json();
        const grid = document.getElementById('challenges-grid');
        
        grid.innerHTML = challenges.map(c => {
            const isSolved = solvedChallenges.has(c.id);
            const catClass = `badge-${c.category.toLowerCase()}`;
            const diffClass = `badge-${c.difficulty.toLowerCase()}`;
            const isDynamic = [1, 2, 3].includes(c.id); // Challenges with dynamic containers
            
            return `
                <div class="challenge-card ${isSolved ? 'solved' : ''}" id="challenge-${c.id}">
                    <h3>${escapeHtml(c.name)} ${isSolved ? '<span style="color:#2ed573">✓</span>' : ''}</h3>
                    <div class="badges">
                        <span class="badge ${catClass}">${c.category}</span>
                        <span class="badge ${diffClass}">${c.difficulty}</span>
                    </div>
                    <p>${escapeHtml(c.description)}</p>
                    <div class="meta">
                        <span class="points">${c.points} pts</span>
                        ${!isDynamic ? `<span class="port">Port: ${c.port}</span>` : ''}
                    </div>
                    
                    ${isDynamic ? `
                        <div class="dynamic-status"></div>
                        <button class="btn btn-primary start-challenge-btn" onclick="startChallenge(${c.id})" style="width:100%;margin:10px 0">
                            🚀 Start Challenge Container
                        </button>
                    ` : c.category === 'SSH' ? `
                        <div style="background:rgba(255,193,7,0.1);border:1px solid #ffc107;padding:10px;border-radius:5px;margin:10px 0;font-size:0.9em">
                            <strong style="color:#ffc107">📡 SSH Connection:</strong><br>
                            <code>ssh ctf@<span class="server-ip">${window.location.hostname}</span> -p ${c.port}</code><br>
                            <span style="color:#aaa">Password: <code>password123</code></span>
                        </div>
                    ` : ''}
                    
                    ${!isSolved ? `
                        <div class="flag-form">
                            <input type="text" id="flag-input-${c.id}" placeholder="flag{...}">
                            <button class="btn btn-primary" onclick="submitFlag(${c.id})">Submit</button>
                        </div>
                        <div id="flag-result-${c.id}" style="margin-top:10px"></div>
                    ` : `
                        <div style="color:#2ed573;text-align:center;padding:10px;font-weight:bold">Challenge Completed!</div>
                    `}
                </div>
            `;
        }).join('');
        
        // Check status for dynamic challenges
        [1, 2, 3].forEach(id => checkChallengeStatus(id));
        
    } catch (err) {
        document.getElementById('challenges-grid').innerHTML = 
            `<div style="color:#ff4757;text-align:center">Error loading challenges: ${escapeHtml(err.message)}</div>`;
    }
}
        }).join('');
    } catch (err) {
        console.error('Error loading challenges:', err);
    }
}

async function submitFlag(challengeId) {
    const input = document.getElementById(`flag-input-${challengeId}`);
    const result = document.getElementById(`flag-result-${challengeId}`);
    const flag = input.value.trim();
    
    if (!flag) {
        result.innerHTML = '<span style="color:#ff4757">Enter a flag</span>';
        return;
    }
    
    try {
        const res = await fetch(`${CONFIG.API_URL}/submit_flag`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${authToken}`
            },
            body: JSON.stringify({ challenge_id: challengeId, flag })
        });
        const data = await res.json();
        
        if (res.status === 429) {
            result.innerHTML = '<span style="color:#ffa502">⏱️ Rate limited! Wait 60 seconds.</span>';
            return;
        }
        
        if (data.success) {
            result.innerHTML = `<span style="color:#2ed573">✓ Correct! +${data.points} points</span>`;
            setTimeout(() => {
                loadProgress();
                loadChallenges();
                loadLeaderboard();
            }, 1000);
        } else {
            result.innerHTML = `<span style="color:#ff4757">✗ ${escapeHtml(data.message)}</span>`;
        }
    } catch (err) {
        result.innerHTML = `<span style="color:#ff4757">Error: ${escapeHtml(err.message)}</span>`;
    }
}

async function loadLeaderboard() {
    try {
        const res = await fetch(`${CONFIG.API_URL}/leaderboard`, {
            headers: { 'Authorization': `Bearer ${authToken}` }
        });
        if (res.ok) {
            const data = await res.json();
            const tbody = document.getElementById('leaderboard-body');
            
            tbody.innerHTML = data.map((u, i) => {
                const rankClass = i < 3 ? `rank-${i+1}` : '';
                const isMe = u.username === currentUser.username;
                if (isMe) document.getElementById('stat-rank').textContent = i+1;
                
                return `
                    <tr style="${isMe ? 'background:rgba(0,212,255,0.1)' : ''}">
                        <td class="${rankClass}">${i+1}</td>
                        <td>${escapeHtml(u.username)}${isMe ? ' (you)' : ''}</td>
                        <td>${u.solved}</td>
                        <td>${u.points}</td>
                    </tr>
                `;
            }).join('');
        }
    } catch (err) {
        console.error('Error loading leaderboard:', err);
    }
}

// UI Helpers
function showTab(tab) {
    document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
    document.querySelector(`.tab[onclick="showTab('${tab}')"]`).classList.add('active');
    
    document.getElementById('challenges-tab').classList.toggle('hidden', tab !== 'challenges');
    document.getElementById('leaderboard-tab').classList.toggle('hidden', tab !== 'leaderboard');
    
    if (tab === 'leaderboard') loadLeaderboard();
}

function showError(msg) {
    const el = document.getElementById('auth-error');
    el.textContent = msg;
    el.classList.remove('hidden');
}

function showSuccess(msg) {
    const el = document.getElementById('auth-success');
    el.textContent = msg;
    el.classList.remove('hidden');
}

function hideMessages() {
    document.getElementById('auth-error').classList.add('hidden');
    document.getElementById('auth-success').classList.add('hidden');
}


// ======================
// DYNAMIC CHALLENGE MANAGEMENT
// ======================

let containerTimers = {}; // Store timers for each challenge

async function startChallenge(challengeId) {
    const btn = document.querySelector(`#challenge-${challengeId} .start-challenge-btn`);
    const statusDiv = document.querySelector(`#challenge-${challengeId} .dynamic-status`);
    
    if (!btn || !statusDiv) return;
    
    btn.disabled = true;
    btn.textContent = 'Starting...';
    statusDiv.innerHTML = '<span style="color:#ffa502">🔄 Starting container...</span>';
    
    try {
        const res = await fetch(`${CONFIG.API_URL}/challenge/${challengeId}/start`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${authToken}`
            }
        });
        
        const data = await res.json();
        
        if (!res.ok) {
            statusDiv.innerHTML = `<span style="color:#ff4757">❌ ${escapeHtml(data.error || 'Failed to start')}</span>`;
            btn.disabled = false;
            btn.textContent = 'Start Challenge';
            return;
        }
        
        // Success - show SSH info
        displayDynamicContainer(challengeId, data);
        
    } catch (err) {
        statusDiv.innerHTML = `<span style="color:#ff4757">❌ Error: ${escapeHtml(err.message)}</span>`;
        btn.disabled = false;
        btn.textContent = 'Start Challenge';
    }
}

async function stopChallenge(challengeId) {
    try {
        const res = await fetch(`${CONFIG.API_URL}/challenge/${challengeId}/stop`, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${authToken}`
            }
        });
        
        if (res.ok) {
            clearInterval(containerTimers[challengeId]);
            loadChallenges(); // Refresh UI
        }
    } catch (err) {
        console.error('Failed to stop challenge:', err);
    }
}

async function checkChallengeStatus(challengeId) {
    try {
        const res = await fetch(`${CONFIG.API_URL}/challenge/${challengeId}/status`, {
            headers: { 'Authorization': `Bearer ${authToken}` }
        });
        
        if (res.ok) {
            const data = await res.json();
            if (data.status === 'running' && data.container) {
                displayDynamicContainer(challengeId, data);
            }
        }
    } catch (err) {
        console.error('Failed to check status:', err);
    }
}

function displayDynamicContainer(challengeId, data) {
    const card = document.getElementById(`challenge-${challengeId}`);
    if (!card) return;
    
    const statusDiv = card.querySelector('.dynamic-status');
    const expiresAt = new Date(data.container.expires_at || data.expires_at);
    
    statusDiv.innerHTML = `
        <div style="background:rgba(46,213,115,0.1);border:1px solid #2ed573;padding:15px;border-radius:5px;margin:10px 0">
            <strong style="color:#2ed573">✅ Container Running</strong><br>
            <div style="margin-top:10px;font-size:0.9em">
                <strong>SSH Command:</strong><br>
                <code style="background:#000;color:#0f0;padding:5px;display:block;margin:5px 0">ssh ctfuser@localhost -p ${data.container.port}</code>
                Password: <code>password123</code>
            </div>
            <div style="margin-top:10px;color:#666">
                ⏱️ Time remaining: <strong id="timer-${challengeId}">calculating...</strong>
            </div>
            <button class="btn btn-danger" onclick="stopChallenge(${challengeId})" style="margin-top:10px">Stop Container</button>
        </div>
    `;
    
    // Hide start button
    const startBtn = card.querySelector('.start-challenge-btn');
    if (startBtn) startBtn.style.display = 'none';
    
    // Start countdown timer
    startCountdown(challengeId, expiresAt);
}

function startCountdown(challengeId, expiresAt) {
    // Clear existing timer
    if (containerTimers[challengeId]) {
        clearInterval(containerTimers[challengeId]);
    }
    
    const timerEl = document.getElementById(`timer-${challengeId}`);
    if (!timerEl) return;
    
    containerTimers[challengeId] = setInterval(() => {
        const now = new Date();
        const diff = expiresAt - now;
        
        if (diff <= 0) {
            clearInterval(containerTimers[challengeId]);
            timerEl.textContent = 'EXPIRED';
            timerEl.style.color = '#ff4757';
            setTimeout(() => loadChallenges(), 2000);
            return;
        }
        
        const hours = Math.floor(diff / 3600000);
        const minutes = Math.floor((diff % 3600000) / 60000);
        const seconds = Math.floor((diff % 60000) / 1000);
        
        timerEl.textContent = `${hours}h ${minutes}m ${seconds}s`;
    }, 1000);
}

function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

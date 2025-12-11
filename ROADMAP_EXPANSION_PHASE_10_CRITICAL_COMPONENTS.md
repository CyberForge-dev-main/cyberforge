---
## 🔥 PHASE 10: ADVANCED CHALLENGE ECOSYSTEM (69-110)

**EXPANDED TO INCLUDE CRITICAL MISSING COMPONENTS**

---

### 📚 EXISTING CHALLENGE TYPES (69-76)

#### 10.1 Web Security Challenges (69)
- OWASP Top 10 challenges (SQL Injection, XSS, CSRF, etc)
- Vulnerable web apps (intentionally buggy)
- Docker container web app
- Port exposed for accessing
- Flag hidden in database, or in code
- Example: SQL injection challenge to extract flag from users table

#### 10.2 Binary Exploitation & Reverse Engineering (70)
- ELF binaries (Linux), PE executables (Windows)
- Buffer overflow challenges
- Format string vulnerabilities
- Reverse engineering stripped binaries (IDA, Ghidra)
- Debugger usage (gdb, WinDbg)
- Challenge: exploit binary to read flag from memory

#### 10.3 Cryptography Challenges (71)
- AES, RSA, DES encryption/decryption
- Hash collisions
- Brute force protected passwords
- Key extraction from side channels
- Weak RNG exploitation
- Challenge: decrypt message, find key, solve equation

#### 10.4 Forensics & Memory Analysis (72)
- Disk image analysis (recovery deleted files)
- Memory dump analysis (find credentials)
- PCAP file analysis (network traffic)
- Log file analysis
- Timeline reconstruction (what happened?)
- Challenge: find hidden flag in files, memory, network traffic

#### 10.5 Network Security & Protocols (73)
- Packet sniffing (Wireshark)
- Port scanning
- Service enumeration
- Banner grabbing
- Protocol fuzzing
- Challenge: sniff traffic, find credentials, exploit service

#### 10.6 OSINT (Open Source Intelligence) (74)
- Google dorking
- Social media investigation
- Domain/IP lookup (WHOIS, DNS)
- Metadata extraction (images, documents)
- Geolocation from photos
- Challenge: find information, piece together the story

#### 10.7 Hardware & IoT Security (75)
- Microcontroller programming (Arduino)
- IoT device hacking (default credentials)
- Radio hacking (SDR)
- Firmware extraction
- Hardware debugging (UART, JTAG)
- Challenge: program device, extract data, communicate

#### 10.8 Cloud Security (AWS/GCP/Azure) (76)
- Misconfigured S3 buckets
- IAM policy exploitation
- API key exposure
- Lateral movement in cloud
- Data exfiltration
- Challenge: exploit cloud misconfig, extract data

#### 10.9 Mobile Security (Android/iOS) (77)
- Reverse engineer APK/IPA
- SQL database access
- Intent hijacking
- Man-in-the-middle attacks
- Jailbreak detection bypass
- Challenge: install app, reverse, extract flag

#### 10.10 AI/ML Security (78)
- Adversarial examples (fool ML models)
- Model extraction attacks
- Data poisoning
- Privacy attacks (membership inference)
- Prompt injection
- Challenge: craft input to fool model, extract knowledge

---

### 🔥 NEW CRITICAL COMPONENTS (79-100)

---

## 10.11 CUSTOM VALIDATION ENGINE (79-82)

**Problem:** Current system only supports static flag matching (`flag == challenge.flag`). This is primitive and limits challenge creativity.

### 10.11.1 Script-Based Validators (79)

**Architecture:**
```yaml
Challenge Structure:
  /challenge-root/
    Dockerfile
    challenge_files/
    validator.py          ← NEW: Custom validation logic
    validator_config.json ← Validator settings
```

**Validator Interface:**
```python
# validator.py
class ChallengeValidator:
    def __init__(self, metadata):
        """
        metadata = {
            "challenge_id": 123,
            "user_id": 456,
            "container_info": {...}
        }
        """
        self.metadata = metadata
        
    def validate(self, user_input):
        """
        Args:
            user_input: dict with user submission
                {
                    "flag": "user_submitted_value",
                    "files": [...],  # uploaded files
                    "answers": {...} # multi-part answers
                }
        
        Returns:
            {
                "correct": True/False,
                "score": 0-100 (partial credit),
                "feedback": "Helpful message",
                "next_step": "URL or hint" (for multi-step)
            }
        """
        # Custom validation logic
        if self.check_api_response(user_input["flag"]):
            return {
                "correct": True,
                "score": 100,
                "feedback": "Perfect! API is working correctly."
            }
        else:
            return {
                "correct": False,
                "score": 30,  # Partial credit
                "feedback": "API endpoint found but response is wrong."
            }
    
    def check_api_response(self, endpoint):
        # Custom logic to validate user created API
        import requests
        try:
            r = requests.post(endpoint, json={"test": "data"}, timeout=5)
            return r.json().get("result") == "expected_value"
        except:
            return False
```

**Validator Types:**

1. **API Validator**
   ```python
   # User must create working REST API
   # Platform tests API with multiple requests
   def validate(self, user_input):
       endpoint = user_input["flag"]
       tests = [
           {"input": {"x": 5}, "expected": {"y": 25}},
           {"input": {"x": 10}, "expected": {"y": 100}},
       ]
       for test in tests:
           response = requests.post(endpoint, json=test["input"])
           if response.json() != test["expected"]:
               return {"correct": False, "feedback": f"Failed test: {test}"}
       return {"correct": True, "score": 100}
   ```

2. **Code Execution Validator**
   ```python
   # User submits code, platform runs it
   def validate(self, user_input):
       code = user_input["code"]
       # Run in sandbox
       result = subprocess.run(
           ["python3", "-c", code],
           capture_output=True,
           timeout=5,
           cwd="/tmp/sandbox"
       )
       if result.stdout.decode().strip() == "expected_output":
           return {"correct": True, "score": 100}
       return {"correct": False, "feedback": "Output mismatch"}
   ```

3. **File Analysis Validator**
   ```python
   # User uploads analyzed PCAP file results
   def validate(self, user_input):
       # User must submit JSON with found domains
       findings = user_input.get("findings", {})
       required_domains = ["evil.com", "malware.net"]
       
       found = findings.get("domains", [])
       if all(d in found for d in required_domains):
           return {"correct": True, "score": 100}
       
       # Partial credit
       score = (len(set(found) & set(required_domains)) / len(required_domains)) * 100
       return {
           "correct": False,
           "score": score,
           "feedback": f"Found {len(found)}/{len(required_domains)} domains"
       }
   ```

**Backend Integration:**
```python
# backend/validators/validator_engine.py
class ValidatorEngine:
    def __init__(self):
        self.sandbox_config = {
            "timeout": 30,
            "memory_limit": "256MB",
            "network": "isolated",  # No internet access
            "read_only_fs": True
        }
    
    def run_validator(self, challenge_id, user_input, validator_path):
        """
        Execute validator in isolated sandbox
        """
        # Load validator.py from challenge
        validator_code = self.load_validator(challenge_id, validator_path)
        
        # Run in gVisor sandbox
        container = docker_client.containers.run(
            "cyberforge-validator-sandbox",
            command=["python3", "/validator/validator.py"],
            environment={
                "USER_INPUT": json.dumps(user_input),
                "CHALLENGE_ID": challenge_id
            },
            volumes={
                validator_path: {"bind": "/validator", "mode": "ro"}
            },
            mem_limit=self.sandbox_config["memory_limit"],
            network_mode="none",  # No network
            runtime="runsc",  # gVisor
            remove=True,
            timeout=self.sandbox_config["timeout"]
        )
        
        # Parse validator output
        result = json.loads(container.logs())
        return result
```

**Database Schema:**
```sql
-- challenges table extension
ALTER TABLE challenges ADD COLUMN validation_type VARCHAR(50) DEFAULT 'static_flag';
-- Options: 'static_flag', 'script', 'webhook', 'multi_step'

ALTER TABLE challenges ADD COLUMN validator_path TEXT;
-- Path to validator.py in challenge Docker image

ALTER TABLE challenges ADD COLUMN validator_config JSON;
-- Validator-specific configuration

-- New table: challenge_validations (audit log)
CREATE TABLE challenge_validations (
    id SERIAL PRIMARY KEY,
    submission_id INTEGER REFERENCES submissions(id),
    validator_output JSON,  -- Full validator response
    execution_time INTEGER,  -- ms
    sandbox_logs TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);
```

**Success Criteria:**
- ✅ Validators run in isolated sandbox (gVisor)
- ✅ Timeout protection (30 sec max)
- ✅ Memory limits enforced (256MB)
- ✅ Support for Python, Bash, Node.js validators
- ✅ Partial credit scoring (0-100)
- ✅ Detailed feedback to users
- ✅ Audit logging of all validation executions

---

### 10.11.2 Multi-Step Challenge System (80)

**Problem:** Some challenges require progression through multiple stages. Current system doesn't support this.

**Architecture:**
```yaml
Multi-Step Challenge:
  Step 1: Find subdomain
    → Unlocks Step 2
  Step 2: SQL injection
    → Unlocks Step 3
  Step 3: Privilege escalation
    → Final flag
```

**Database Schema:**
```sql
-- New table: challenge_steps
CREATE TABLE challenge_steps (
    id SERIAL PRIMARY KEY,
    challenge_id INTEGER REFERENCES challenges(id),
    step_number INTEGER NOT NULL,
    step_name VARCHAR(200),
    description TEXT,
    validator_type VARCHAR(50),  -- 'flag', 'script', 'webhook'
    validator_config JSON,
    points INTEGER DEFAULT 0,
    required BOOLEAN DEFAULT TRUE,  -- Must complete to proceed
    UNIQUE(challenge_id, step_number)
);

-- New table: user_challenge_progress
CREATE TABLE user_challenge_progress (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    challenge_id INTEGER REFERENCES challenges(id),
    current_step INTEGER DEFAULT 1,
    completed_steps JSON,  -- [1, 2, 3]
    step_data JSON,  -- State data for each step
    started_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, challenge_id)
);
```

**Example Configuration:**
```json
{
  "challenge_id": 123,
  "name": "Full Stack Exploitation",
  "total_steps": 4,
  "steps": [
    {
      "step": 1,
      "name": "Reconnaissance",
      "description": "Find the hidden subdomain",
      "validator_type": "script",
      "validator_code": "validators/recon.py",
      "points": 25,
      "hints": [
        {"level": 1, "text": "Try DNS enumeration"},
        {"level": 2, "text": "Check DNS TXT records"}
      ]
    },
    {
      "step": 2,
      "name": "SQL Injection",
      "description": "Extract admin credentials",
      "validator_type": "flag",
      "expected_flag": "admin:hashed_password",
      "points": 50,
      "unlocked_by": [1]  // Must complete step 1
    },
    {
      "step": 3,
      "name": "Privilege Escalation",
      "description": "Get root access",
      "validator_type": "script",
      "validator_code": "validators/privesc.py",
      "points": 75,
      "unlocked_by": [2]
    },
    {
      "step": 4,
      "name": "Final Flag",
      "description": "Read /root/flag.txt",
      "validator_type": "flag",
      "expected_flag": "FLAG{final_victory}",
      "points": 100,
      "unlocked_by": [3]
    }
  ]
}
```

**API Endpoints:**
```python
@app.route('/api/challenge/<int:challenge_id>/step/<int:step_num>/submit', methods=['POST'])
@jwt_required()
def submit_step(challenge_id, step_num):
    """
    Submit answer for specific step
    """
    user_id = get_jwt_identity()
    data = request.get_json()
    
    # Check if step is unlocked
    progress = UserChallengeProgress.query.filter_by(
        user_id=user_id,
        challenge_id=challenge_id
    ).first()
    
    if not progress:
        # First submission, create progress
        progress = UserChallengeProgress(
            user_id=user_id,
            challenge_id=challenge_id,
            current_step=1,
            completed_steps=[]
        )
        db.session.add(progress)
    
    # Validate step is unlocked
    step = ChallengeStep.query.filter_by(
        challenge_id=challenge_id,
        step_number=step_num
    ).first()
    
    if step_num > progress.current_step:
        return jsonify({"error": "Step not unlocked yet"}), 403
    
    # Run validator
    validator = get_validator(step.validator_type)
    result = validator.validate(step, data)
    
    if result["correct"]:
        # Mark step completed
        if step_num not in progress.completed_steps:
            progress.completed_steps.append(step_num)
            progress.current_step = step_num + 1
            
            # Award points
            user = User.query.get(user_id)
            user.xp += step.points
            
            db.session.commit()
            
            return jsonify({
                "correct": True,
                "step_completed": step_num,
                "next_step": step_num + 1 if step_num < total_steps else None,
                "points_earned": step.points,
                "message": "Step completed! Next step unlocked."
            })
    
    return jsonify(result), 200


@app.route('/api/challenge/<int:challenge_id>/progress', methods=['GET'])
@jwt_required()
def get_challenge_progress(challenge_id):
    """
    Get user's progress on multi-step challenge
    """
    user_id = get_jwt_identity()
    
    progress = UserChallengeProgress.query.filter_by(
        user_id=user_id,
        challenge_id=challenge_id
    ).first()
    
    steps = ChallengeStep.query.filter_by(
        challenge_id=challenge_id
    ).order_by(ChallengeStep.step_number).all()
    
    return jsonify({
        "current_step": progress.current_step if progress else 1,
        "completed_steps": progress.completed_steps if progress else [],
        "total_steps": len(steps),
        "steps": [
            {
                "step": s.step_number,
                "name": s.step_name,
                "description": s.description,
                "points": s.points,
                "completed": s.step_number in (progress.completed_steps if progress else []),
                "unlocked": s.step_number <= (progress.current_step if progress else 1)
            }
            for s in steps
        ]
    })
```

**Frontend UI:**
```jsx
// Multi-Step Challenge Component
function MultiStepChallenge({ challengeId }) {
  const [progress, setProgress] = useState(null);
  
  useEffect(() => {
    fetch(`/api/challenge/${challengeId}/progress`)
      .then(r => r.json())
      .then(setProgress);
  }, [challengeId]);
  
  return (
    <div className="multi-step-challenge">
      <h2>Challenge Progress</h2>
      
      {/* Progress Bar */}
      <div className="progress-bar">
        <div style={{ width: `${(progress.completed_steps.length / progress.total_steps) * 100}%` }} />
      </div>
      
      {/* Steps List */}
      {progress.steps.map(step => (
        <div key={step.step} className={`step ${step.completed ? 'completed' : ''} ${step.unlocked ? 'unlocked' : 'locked'}`}>
          <div className="step-header">
            <span className="step-number">{step.step}</span>
            <span className="step-name">{step.name}</span>
            <span className="step-points">{step.points} pts</span>
            {step.completed && <span className="checkmark">✓</span>}
          </div>
          
          {step.unlocked && !step.completed && (
            <div className="step-content">
              <p>{step.description}</p>
              <input 
                type="text" 
                placeholder="Enter answer..."
                onKeyPress={(e) => {
                  if (e.key === 'Enter') {
                    submitStep(challengeId, step.step, e.target.value);
                  }
                }}
              />
            </div>
          )}
        </div>
      ))}
    </div>
  );
}
```

**Success Criteria:**
- ✅ Support for unlimited steps per challenge
- ✅ Dependency graph (step X requires [Y, Z])
- ✅ Persistent progress tracking
- ✅ Partial points for each step
- ✅ Visual progress indicator
- ✅ Hints per step
- ✅ Optional vs required steps

---

### 10.11.3 Webhook Validation (81)

**Use Case:** Challenge creator wants to use external validation service (e.g., custom grading API, third-party checker).

**Configuration:**
```json
{
  "challenge_id": 456,
  "validation_type": "webhook",
  "webhook_config": {
    "url": "https://grader.example.com/validate",
    "method": "POST",
    "timeout": 10,
    "headers": {
      "Authorization": "Bearer <secret_token>",
      "Content-Type": "application/json"
    },
    "retry_attempts": 3
  }
}
```

**Webhook Request Format:**
```json
POST https://grader.example.com/validate
{
  "challenge_id": 456,
  "user_id": 789,
  "submission": {
    "flag": "user_input",
    "timestamp": "2025-12-11T22:30:00Z"
  },
  "metadata": {
    "container_ip": "172.17.0.5",
    "solve_time": 3600
  }
}
```

**Expected Webhook Response:**
```json
{
  "valid": true,
  "score": 85,  // Partial credit
  "feedback": "Correct approach but minor error in implementation",
  "details": {
    "test_cases_passed": 8,
    "test_cases_total": 10
  }
}
```

**Backend Implementation:**
```python
class WebhookValidator:
    def __init__(self, webhook_config):
        self.config = webhook_config
        self.session = requests.Session()
        self.session.headers.update(webhook_config.get("headers", {}))
    
    def validate(self, challenge, user_input):
        payload = {
            "challenge_id": challenge.id,
            "user_id": user_input["user_id"],
            "submission": user_input,
            "metadata": {
                "timestamp": datetime.utcnow().isoformat()
            }
        }
        
        attempts = 0
        max_attempts = self.config.get("retry_attempts", 3)
        
        while attempts < max_attempts:
            try:
                response = self.session.post(
                    self.config["url"],
                    json=payload,
                    timeout=self.config.get("timeout", 10)
                )
                
                if response.status_code == 200:
                    return response.json()
                
                # Retry on 5xx errors
                if response.status_code >= 500:
                    attempts += 1
                    time.sleep(2 ** attempts)  // Exponential backoff
                    continue
                
                return {
                    "valid": False,
                    "error": f"Webhook returned {response.status_code}"
                }
            
            except requests.Timeout:
                attempts += 1
                if attempts >= max_attempts:
                    return {
                        "valid": False,
                        "error": "Webhook timeout"
                    }
            
            except Exception as e:
                return {
                    "valid": False,
                    "error": f"Webhook error: {str(e)}"
                }
```

**Security:**
- Webhook secret token stored in Vault
- HMAC signature verification
- Rate limiting on webhook calls
- Timeout protection
- Retry with exponential backoff

**Success Criteria:**
- ✅ Support for custom validation webhooks
- ✅ Retry logic with backoff
- ✅ Timeout protection
- ✅ HMAC signature verification
- ✅ Audit logging of webhook calls

---

### 10.11.4 Automated Testing Framework (82)

**Problem:** Challenge creators need to test validators before publishing.

**Test Suite Format:**
```yaml
# challenge_tests.yml
challenge_id: 123
tests:
  - name: "Valid flag accepted"
    input:
      flag: "FLAG{correct}"
    expected:
      correct: true
      score: 100
  
  - name: "Invalid flag rejected"
    input:
      flag: "FLAG{wrong}"
    expected:
      correct: false
      score: 0
  
  - name: "Partial credit"
    input:
      flag: "FLAG{almost}"
    expected:
      correct: false
      score: 50
      feedback: "Close, but not quite"
```

**Test Runner:**
```python
class ChallengeTestRunner:
    def run_tests(self, challenge_id, test_file):
        tests = yaml.load(test_file)
        results = []
        
        for test in tests["tests"]:
            result = self.run_test(challenge_id, test)
            results.append(result)
        
        return {
            "total": len(tests),
            "passed": sum(1 for r in results if r["passed"]),
            "failed": sum(1 for r in results if not r["passed"]),
            "results": results
        }
    
    def run_test(self, challenge_id, test):
        challenge = Challenge.query.get(challenge_id)
        validator = get_validator(challenge.validation_type)
        
        actual = validator.validate(challenge, test["input"])
        expected = test["expected"]
        
        passed = (
            actual.get("correct") == expected.get("correct") and
            actual.get("score", 0) == expected.get("score", 0)
        )
        
        return {
            "name": test["name"],
            "passed": passed,
            "expected": expected,
            "actual": actual
        }
```

**Success Criteria:**
- ✅ Automated test suite for validators
- ✅ Test before publish workflow
- ✅ CI/CD integration
- ✅ Test coverage reporting

---

## 10.12 GUI & DESKTOP CHALLENGES (83-86)

**THE MOST CRITICAL MISSING FEATURE**

### 10.12.1 noVNC Integration - Linux Desktop Challenges (83)

**Problem:** No way to run challenges requiring GUI tools (Burp Suite, Wireshark, IDA, etc.)

**Architecture:**
```
User Browser → noVNC WebSocket → VNC Server (in container) → X11 Display → Desktop Environment
```

**Container Setup:**
```dockerfile
# challenges/gui-kali/Dockerfile
FROM kalilinux/kali-rolling:latest

# Install desktop environment
RUN apt-get update && apt-get install -y \
    xfce4 \
    xfce4-terminal \
    tigervnc-standalone-server \
    novnc \
    websockify \
    supervisor \
    burpsuite \
    wireshark \
    ghidra \
    && apt-get clean

# VNC configuration
RUN mkdir -p ~/.vnc
RUN echo "password" | vncpasswd -f > ~/.vnc/passwd
RUN chmod 600 ~/.vnc/passwd

# Xvnc startup script
COPY xstartup ~/.vnc/xstartup
RUN chmod +x ~/.vnc/xstartup

# Supervisor config (manage VNC + noVNC)
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Challenge files
COPY challenge_files/ /home/kali/challenge/

# Expose VNC port (5900) and noVNC port (6080)
EXPOSE 5900 6080

# Start supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
```

**supervisord.conf:**
```ini
[supervisord]
nodaemon=true

[program:xvnc]
command=/usr/bin/Xvnc :1 -geometry 1280x720 -depth 24 -rfbport 5900 -rfbauth /root/.vnc/passwd
autorestart=true
stdout_logfile=/var/log/vnc.log
stderr_logfile=/var/log/vnc_error.log

[program:novnc]
command=/usr/share/novnc/utils/novnc_proxy --vnc localhost:5900 --listen 6080
autorestart=true
stdout_logfile=/var/log/novnc.log
stderr_logfile=/var/log/novnc_error.log
```

**Backend Challenge Orchestration:**
```python
class GUIChallengeOrchestrator:
    def start_gui_challenge(self, challenge_id, user_id):
        """
        Start GUI challenge container with noVNC
        """
        # Get available port
        vnc_port = self.get_free_port(range(30000, 30100))
        novnc_port = self.get_free_port(range(30100, 30200))
        
        container = docker_client.containers.run(
            f"cyberforge-gui-challenge-{challenge_id}",
            name=f"gui-{challenge_id}-{user_id}",
            ports={
                '5900/tcp': vnc_port,     # VNC
                '6080/tcp': novnc_port    # noVNC web interface
            },
            environment={
                "FLAG": self.generate_unique_flag(challenge_id, user_id),
                "USER_ID": user_id,
                "CHALLENGE_ID": challenge_id,
                "VNC_PASSWORD": self.generate_vnc_password()
            },
            mem_limit="2g",  # GUI needs more RAM
            cpu_quota=100000,  # 1 CPU core
            shm_size="512m",  # Shared memory for X11
            network=self.network_name,
            detach=True
        )
        
        # Save instance
        instance = ChallengeInstance(
            user_id=user_id,
            challenge_id=challenge_id,
            container_name=container.name,
            port=novnc_port,  # noVNC web port
            vnc_port=vnc_port,
            status="running",
            expires_at=datetime.utcnow() + timedelta(hours=4)  # Longer for GUI
        )
        db.session.add(instance)
        db.session.commit()
        
        return {
            "novnc_url": f"http://{HOST}:{novnc_port}/vnc.html",
            "vnc_password": "password",  # Or generate secure one
            "expires_at": instance.expires_at.isoformat()
        }
```

**Frontend Integration:**
```jsx
function GUIChallenge({ challengeId }) {
  const [instance, setInstance] = useState(null);
  const [loading, setLoading] = useState(false);
  
  const startChallenge = async () => {
    setLoading(true);
    const response = await fetch(`/api/challenge/${challengeId}/start-gui`, {
      method: 'POST',
      headers: { 'Authorization': `Bearer ${token}` }
    });
    const data = await response.json();
    setInstance(data);
    setLoading(false);
  };
  
  return (
    <div className="gui-challenge">
      {!instance ? (
        <button onClick={startChallenge} disabled={loading}>
          🖥️ Launch Desktop Environment
        </button>
      ) : (
        <div className="vnc-container">
          <iframe 
            src={instance.novnc_url}
            width="100%"
            height="720px"
            frameBorder="0"
            title="Desktop Challenge"
          />
          <div className="challenge-info">
            <p>🔒 VNC Password: <code>{instance.vnc_password}</code></p>
            <p>⏱️ Time Remaining: {/* countdown */}</p>
            <button onClick={() => submitFlag(challengeId)}>
              Submit Flag
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
```

**Example Challenges:**

1. **Burp Suite Web Challenge**
```
Container: Kali + Burp Suite + Target Web App
Task: "Use Burp Suite to find hidden API endpoint"
Flag: Located in API response
```

2. **Wireshark PCAP Analysis**
```
Container: Desktop + Wireshark + PCAP file
Task: "Analyze network traffic, find exfiltrated data"
Flag: Base64 decoded from DNS queries
```

3. **Ghidra Reverse Engineering**
```
Container: Desktop + Ghidra + Binary
Task: "Reverse engineer binary, find license key generation algorithm"
Flag: Generated valid license key
```

**Success Criteria:**
- ✅ noVNC embedded in browser (no client install)
- ✅ 1280x720 resolution minimum
- ✅ Clipboard support (copy/paste)
- ✅ File transfer (upload/download)
- ✅ 4-hour timeout for GUI challenges
- ✅ Automatic container cleanup
- ✅ Resource limits (2GB RAM, 1 CPU)

---

### 10.12.2 Windows RDP via Apache Guacamole (84)

**Use Case:** Active Directory exploitation, Windows privilege escalation, Windows-specific tools.

**Architecture:**
```
User Browser → Guacamole Web UI → Guacd Proxy → RDP → Windows Container
```

**Guacamole Setup:**
```yaml
# docker-compose.yml
services:
  guacd:
    image: guacamole/guacd
    container_name: cyberforge-guacd
    restart: always
    networks:
      - cyberforge

  guacamole:
    image: guacamole/guacamole
    container_name: cyberforge-guacamole
    environment:
      GUACD_HOSTNAME: guacd
      POSTGRES_HOSTNAME: db
      POSTGRES_DATABASE: guacamole
      POSTGRES_USER: guacamole_user
      POSTGRES_PASSWORD: secure_pass
    ports:
      - "8080:8080"
    networks:
      - cyberforge
    depends_on:
      - guacd
      - db
```

**Windows Challenge Container:**
```dockerfile
# Windows Server Core with RDP
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Enable RDP
RUN powershell -Command \
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0; \
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# Create challenge user
RUN net user /add ctfuser Password123!
RUN net localgroup "Remote Desktop Users" ctfuser /add

# Copy challenge files
COPY challenge_files/ C:\Challenge\

# Expose RDP port
EXPOSE 3389

CMD ["powershell"]
```

**Backend RDP Challenge Start:**
```python
class WindowsChallengeOrchestrator:
    def start_windows_challenge(self, challenge_id, user_id):
        """
        Start Windows RDP challenge via Guacamole
        """
        # Start Windows container
        rdp_port = self.get_free_port(range(33890, 34000))
        
        container = docker_client.containers.run(
            f"cyberforge-windows-challenge-{challenge_id}",
            name=f"win-{challenge_id}-{user_id}",
            ports={'3389/tcp': rdp_port},
            mem_limit="4g",  # Windows needs more RAM
            cpu_quota=200000,  # 2 CPU cores
            detach=True
        )
        
        # Create Guacamole connection
        connection_id = self.create_guacamole_connection(
            name=f"Challenge {challenge_id} - User {user_id}",
            protocol="rdp",
            hostname=container.name,
            port=3389,
            username="ctfuser",
            password="Password123!",
            width=1280,
            height=720
        )
        
        # Return Guacamole URL
        guac_token = self.generate_guacamole_token(connection_id, user_id)
        
        return {
            "guacamole_url": f"http://{HOST}:8080/guacamole/#/client/{connection_id}?token={guac_token}",
            "rdp_user": "ctfuser",
            "rdp_pass": "Password123!",
            "expires_at": (datetime.utcnow() + timedelta(hours=6)).isoformat()
        }
    
    def create_guacamole_connection(self, name, protocol, hostname, port, username, password, width, height):
        """
        Create Guacamole connection via API
        """
        guac_api = GuacamoleAPI(
            url="http://guacamole:8080/guacamole",
            username=os.getenv("GUAC_ADMIN_USER"),
            password=os.getenv("GUAC_ADMIN_PASS")
        )
        
        connection = guac_api.create_connection(
            name=name,
            protocol=protocol,
            parameters={
                "hostname": hostname,
                "port": port,
                "username": username,
                "password": password,
                "width": width,
                "height": height,
                "dpi": 96,
                "color-depth": 32,
                "enable-drive": True,  # File transfer
                "drive-path": "/shared",
                "create-drive-path": True
            }
        )
        
        return connection["identifier"]
```

**Example Windows Challenges:**

1. **Active Directory Privilege Escalation**
```
Environment: Windows Server + AD Domain
Task: "Exploit misconfigured AD to become Domain Admin"
Flag: In C:\AdminShare\flag.txt (only accessible to Domain Admins)
```

2. **Windows Registry Forensics**
```
Environment: Windows 10 Desktop
Task: "Find malware persistence mechanism in registry"
Flag: Registry key value containing encoded flag
```

3. **PowerShell Script Analysis**
```
Environment: Windows + PowerShell ISE
Task: "Deobfuscate PowerShell script to find C2 server"
Flag: C2 domain name
```

**Success Criteria:**
- ✅ Guacamole embedded in browser
- ✅ RDP clipboard support
- ✅ File transfer (drag & drop)
- ✅ 6-hour timeout for Windows challenges
- ✅ Automatic cleanup
- ✅ Resource limits (4GB RAM, 2 CPU)

---

### 10.12.3 Browser-Based Terminal with File Manager (85)

**Use Case:** Lightweight GUI for file browsing, text editing without full desktop.

**Architecture:**
```
ttyd (terminal in browser) + FileBrowser
```

**Container Setup:**
```dockerfile
FROM ubuntu:22.04

# Install ttyd (terminal in browser)
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    vim \
    nano

# Install ttyd
RUN wget https://github.com/tsl0922/ttyd/releases/download/1.7.3/ttyd.x86_64 \
    && chmod +x ttyd.x86_64 \
    && mv ttyd.x86_64 /usr/local/bin/ttyd

# Install FileBrowser
RUN curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash

# Challenge files
COPY challenge_files/ /challenge/

# Expose ports
EXPOSE 7681 8081

# Startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
```

**start.sh:**
```bash
#!/bin/bash

# Start ttyd (web terminal)
ttyd -p 7681 -W bash &

# Start FileBrowser
filebrowser -p 8081 -r /challenge &

# Keep container running
wait
```

**Frontend:**
```jsx
function TerminalChallenge({ instance }) {
  return (
    <div className="terminal-challenge">
      <div className="split-view">
        {/* Terminal */}
        <iframe 
          src={`http://${instance.host}:${instance.ttyd_port}`}
          className="terminal-pane"
          title="Terminal"
        />
        
        {/* File Browser */}
        <iframe 
          src={`http://${instance.host}:${instance.filebrowser_port}`}
          className="filebrowser-pane"
          title="Files"
        />
      </div>
    </div>
  );
}
```

**Success Criteria:**
- ✅ Web-based terminal (ttyd)
- ✅ File browser UI
- ✅ Lightweight (no full desktop overhead)
- ✅ Text editor support (vim/nano)
- ✅ File upload/download

---

### 10.12.4 GUI Challenge Templates Library (86)

**Pre-built Challenge Templates:**

1. **Web Penetration Testing Template**
   - Kali Linux + Burp Suite + Vulnerable Web App
   - Pre-configured Burp project
   - Target app with OWASP vulnerabilities

2. **Network Analysis Template**
   - Ubuntu + Wireshark + PCAP files
   - Pre-loaded capture files
   - Analysis questions

3. **Malware Analysis Template**
   - REMnux Linux + Analysis tools
   - Isolated sandbox
   - Sample malware

4. **Binary Reverse Engineering Template**
   - Ubuntu + Ghidra + IDA Free + Radare2
   - Challenge binaries
   - Decompiler pre-configured

5. **Windows Forensics Template**
   - Windows 10 + FTK Imager + Autopsy
   - Disk image
   - Forensic questions

**Template Structure:**
```yaml
templates/
  web-pentest/
    Dockerfile
    docker-compose.yml
    config/
      burp-config.json
      target-app-config.yml
    challenge_files/
    validator.py
    README.md
```

**Success Criteria:**
- ✅ 5+ pre-built GUI templates
- ✅ One-click deployment
- ✅ Documented configuration
- ✅ Example challenges included

---

## 10.13 MULTI-CONTAINER ORCHESTRATION (87-90)

### 10.13.1 Network Scenario Challenges (87)

**Problem:** Real-world attacks involve multiple machines in network. Current system = 1 container per challenge.

**Use Case:**
```
DMZ Network:
- Web Server (public)
- Application Server (internal)
- Database Server (internal)

Task: Pivot from Web Server → App Server → DB
Flag: In database
```

**Architecture:**
```yaml
# challenge-network-pivot.yml
version: '3.8'

networks:
  dmz:
    driver: bridge
    ipam:
      config:
        - subnet: 192.168.100.0/24
  internal:
    driver: bridge
    ipam:
      config:
        - subnet: 10.0.0.0/24
    internal: true  # No internet access

services:
  web:
    build: ./web
    networks:
      dmz:
        ipv4_address: 192.168.100.10
      internal:
        ipv4_address: 10.0.0.10
    ports:
      - "8080:80"
    environment:
      - FLAG_PART_1=FLAG{web_
  
  app:
    build: ./app
    networks:
      internal:
        ipv4_address: 10.0.0.20
    environment:
      - FLAG_PART_2=compromised_
  
  db:
    image: postgres:15
    networks:
      internal:
        ipv4_address: 10.0.0.30
    environment:
      - POSTGRES_PASSWORD=weak_password
      - FLAG_PART_3=network}
```

**Backend Orchestration:**
```python
class MultiContainerChallenge:
    def start_network_challenge(self, challenge_id, user_id):
        """
        Start multi-container network scenario
        """
        compose_file = f"challenges/{challenge_id}/docker-compose.yml"
        project_name = f"challenge-{challenge_id}-user-{user_id}"
        
        # Start docker-compose project
        subprocess.run([
            "docker-compose",
            "-f", compose_file,
            "-p", project_name,
            "up", "-d"
        ])
        
        # Get entry point container IP (web server)
        entry_container = f"{project_name}_web_1"
        entry_port = self.get_container_port(entry_container, 80)
        
        # Create instance record
        instance = MultiContainerChallengeInstance(
            user_id=user_id,
            challenge_id=challenge_id,
            project_name=project_name,
            entry_point_url=f"http://{HOST}:{entry_port}",
            containers=[
                {"name": f"{project_name}_web_1", "role": "entry"},
                {"name": f"{project_name}_app_1", "role": "target"},
                {"name": f"{project_name}_db_1", "role": "flag"}
            ],
            expires_at=datetime.utcnow() + timedelta(hours=6)
        )
        db.session.add(instance)
        db.session.commit()
        
        return {
            "entry_url": instance.entry_point_url,
            "network_diagram": self.generate_network_diagram(project_name),
            "expires_at": instance.expires_at.isoformat()
        }
    
    def stop_network_challenge(self, instance_id):
        """
        Stop all containers in network scenario
        """
        instance = MultiContainerChallengeInstance.query.get(instance_id)
        
        subprocess.run([
            "docker-compose",
            "-p", instance.project_name,
            "down", "-v"  # Remove volumes too
        ])
        
        instance.status = "stopped"
        db.session.commit()
```

**Database Schema:**
```sql
CREATE TABLE multi_container_challenge_instances (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    challenge_id INTEGER REFERENCES challenges(id),
    project_name VARCHAR(200) UNIQUE,
    entry_point_url TEXT,
    containers JSON,  -- Array of container info
    network_config JSON,  -- Network topology
    status VARCHAR(20) DEFAULT 'running',
    created_at TIMESTAMP DEFAULT NOW(),
    expires_at TIMESTAMP NOT NULL
);
```

**Frontend Network Diagram:**
```jsx
function NetworkDiagram({ containers, networks }) {
  return (
    <svg width="600" height="400">
      {/* DMZ Network */}
      <rect x="50" y="50" width="500" height="150" fill="#ffebcd" stroke="#333" />
      <text x="60" y="70">DMZ (192.168.100.0/24)</text>
      
      {/* Web Server */}
      <g>
        <rect x="100" y="100" width="80" height="60" fill="#90ee90" />
        <text x="110" y="135">Web Server</text>
        <text x="110" y="150" fontSize="10">192.168.100.10</text>
      </g>
      
      {/* Internal Network */}
      <rect x="50" y="250" width="500" height="150" fill="#add8e6" stroke="#333" />
      <text x="60" y="270">Internal (10.0.0.0/24)</text>
      
      {/* App Server */}
      <g>
        <rect x="200" y="300" width="80" height="60" fill="#ffb6c1" />
        <text x="210" y="335">App Server</text>
        <text x="210" y="350" fontSize="10">10.0.0.20</text>
      </g>
      
      {/* DB Server */}
      <g>
        <rect x="400" y="300" width="80" height="60" fill="#ffa07a" />
        <text x="410" y="335">Database</text>
        <text x="410" y="350" fontSize="10">10.0.0.30</text>
      </g>
      
      {/* Connections */}
      <line x1="140" y1="160" x2="140" y2="250" stroke="#333" strokeWidth="2" />
      <line x1="140" y1="250" x2="240" y2="300" stroke="#333" strokeWidth="2" />
      <line x1="280" y1="330" x2="400" y2="330" stroke="#333" strokeWidth="2" />
    </svg>
  );
}
```

**Example Challenges:**

1. **Network Pivot Challenge**
```
Web (vulnerable) → App (internal) → DB (flag)
Exploit: SQL injection in Web → RCE → pivot to App → DB creds → flag
```

2. **Kubernetes Escape**
```
Pod (restricted) → Node (privileged) → Control Plane
Exploit: Container escape → host access → kubeconfig → flag
```

3. **Service Mesh Attack**
```
Frontend → API Gateway → Microservices (5 services)
Exploit: JWT forgery → access internal service → flag
```

**Success Criteria:**
- ✅ Support for docker-compose challenges
- ✅ Isolated networks per user
- ✅ Network topology visualization
- ✅ Multiple containers per challenge
- ✅ Inter-container communication
- ✅ Automatic cleanup of all containers

---

### 10.13.2 Kubernetes Challenge Environment (88)

**Use Case:** K8s privilege escalation, pod security, RBAC exploitation.

**Architecture:**
```
User → Kubectl (in container) → K3s Cluster (lightweight k8s)
```

**K3s Challenge Setup:**
```dockerfile
FROM rancher/k3s:v1.28.4-k3s1

# Pre-configure cluster with vulnerabilities
COPY vulnerable-manifests/ /var/lib/rancher/k3s/server/manifests/

# Create kubeconfig for user
COPY create-kubeconfig.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/create-kubeconfig.sh

EXPOSE 6443

CMD ["server"]
```

**Vulnerable Manifests:**
```yaml
# vulnerable-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: vulnerable-app
  namespace: default
spec:
  serviceAccountName: default
  containers:
  - name: app
    image: nginx:latest
    securityContext:
      privileged: true  # Vulnerability!
    volumeMounts:
    - name: host
      mountPath: /host
  volumes:
  - name: host
    hostPath:
      path: /
```

**Backend:**
```python
def start_k8s_challenge(challenge_id, user_id):
    """
    Start K8s challenge with isolated cluster
    """
    # Start K3s container
    cluster_port = get_free_port(range(6443, 6543))
    
    k3s_container = docker_client.containers.run(
        "cyberforge-k3s-challenge",
        name=f"k3s-{challenge_id}-{user_id}",
        ports={'6443/tcp': cluster_port},
        privileged=True,  # K3s needs privileged mode
        mem_limit="2g",
        detach=True
    )
    
    # Generate restricted kubeconfig for user
    kubeconfig = generate_kubeconfig(
        cluster_url=f"https://{HOST}:{cluster_port}",
        namespace="default",
        service_account="ctf-user"
    )
    
    return {
        "kubeconfig": kubeconfig,
        "kubectl_command": f"kubectl --kubeconfig=./config get pods",
        "expires_at": (datetime.utcnow() + timedelta(hours=4)).isoformat()
    }
```

**Example K8s Challenges:**

1. **Pod Privilege Escalation**
```
Task: Escape from restricted pod to access host filesystem
Flag: /host/root/flag.txt
```

2. **RBAC Misconfiguration**
```
Task: Exploit overly permissive service account to access secrets
Flag: In secret named "admin-credentials"
```

3. **Container Breakout**
```
Task: Break out of container to access node
Flag: On host node in /var/flag.txt
```

**Success Criteria:**
- ✅ Isolated K3s cluster per user
- ✅ Pre-configured vulnerabilities
- ✅ Restricted kubeconfig provided
- ✅ Auto-cleanup after expiry
- ✅ 4-hour timeout

---

### 10.13.3 Service Mesh Challenges (89)

**Use Case:** Istio/Linkerd exploitation, mTLS bypass, sidecar injection.

**Success Criteria:**
- ✅ Istio or Linkerd pre-configured
- ✅ Mutual TLS challenges
- ✅ Traffic routing exploitation
- ✅ Policy bypass scenarios

---

### 10.13.4 Multi-Container Cleanup & Monitoring (90)

**Cleanup Process:**
```python
class MultiContainerCleanup:
    def cleanup_expired_multi_container_challenges(self):
        """
        Cleanup expired multi-container challenges
        """
        expired = MultiContainerChallengeInstance.query.filter(
            MultiContainerChallengeInstance.expires_at < datetime.utcnow(),
            MultiContainerChallengeInstance.status == 'running'
        ).all()
        
        for instance in expired:
            try:
                # Stop docker-compose project
                subprocess.run([
                    "docker-compose",
                    "-p", instance.project_name,
                    "down", "-v", "--remove-orphans"
                ], timeout=60)
                
                instance.status = "expired"
                db.session.commit()
                
                logger.info(f"Cleaned up multi-container instance {instance.id}")
            
            except Exception as e:
                logger.error(f"Failed to cleanup instance {instance.id}: {e}")
```

**Monitoring:**
```python
class MultiContainerMonitor:
    def get_resource_usage(self, project_name):
        """
        Monitor resource usage for multi-container challenge
        """
        containers = docker_client.containers.list(
            filters={"label": f"com.docker.compose.project={project_name}"}
        )
        
        total_cpu = 0
        total_mem = 0
        
        for container in containers:
            stats = container.stats(stream=False)
            cpu_percent = calculate_cpu_percent(stats)
            mem_usage = stats['memory_stats']['usage']
            
            total_cpu += cpu_percent
            total_mem += mem_usage
        
        return {
            "total_containers": len(containers),
            "total_cpu_percent": total_cpu,
            "total_memory_bytes": total_mem,
            "total_memory_mb": total_mem / (1024 * 1024)
        }
```

**Success Criteria:**
- ✅ Automatic cleanup of all containers
- ✅ Resource monitoring per project
- ✅ Orphan container detection
- ✅ Volume cleanup
- ✅ Network cleanup

---

## 10.14 FILE ANALYSIS & FORENSICS INFRASTRUCTURE (91-93)

### 10.14.1 PCAP Analysis Challenges (91)

**Problem:** No infrastructure for network forensics challenges.

**Challenge Flow:**
```
1. User downloads PCAP file
2. Analyzes with Wireshark/tshark
3. Submits findings (domains, IPs, credentials, etc.)
4. Platform validates findings
```

**Validator Example:**
```python
# validator_pcap.py
import pyshark
import json

class PCAPValidator:
    def __init__(self, pcap_path):
        self.pcap = pyshark.FileCapture(pcap_path)
    
    def validate(self, user_submission):
        """
        user_submission = {
            "malicious_domains": ["evil.com", "malware.net"],
            "c2_ip": "192.168.1.100",
            "exfiltrated_data": "base64encodeddata"
        }
        """
        required_domains = ["evil.com", "malware.net", "phishing.org"]
        found_domains = user_submission.get("malicious_domains", [])
        
        # Check DNS queries in PCAP
        dns_queries = self.extract_dns_queries()
        
        correct_domains = set(found_domains) & set(required_domains)
        score = (len(correct_domains) / len(required_domains)) * 100
        
        return {
            "correct": score == 100,
            "score": score,
            "feedback": f"Found {len(correct_domains)}/{len(required_domains)} malicious domains",
            "details": {
                "missing_domains": list(set(required_domains) - set(found_domains))
            }
        }
    
    def extract_dns_queries(self):
        """Extract all DNS queries from PCAP"""
        queries = []
        for packet in self.pcap:
            if 'DNS' in packet and hasattr(packet.dns, 'qry_name'):
                queries.append(packet.dns.qry_name)
        return queries
```

**File Upload API:**
```python
@app.route('/api/challenge/<int:challenge_id>/upload', methods=['POST'])
@jwt_required()
def upload_forensics_file(challenge_id):
    """
    Upload file for analysis (PCAP, memory dump, disk image)
    """
    user_id = get_jwt_identity()
    
    if 'file' not in request.files:
        return jsonify({"error": "No file uploaded"}), 400
    
    file = request.files['file']
    
    # Validate file type
    allowed_extensions = ['.pcap', '.pcapng', '.mem', '.raw', '.dd']
    if not any(file.filename.endswith(ext) for ext in allowed_extensions):
        return jsonify({"error": "Invalid file type"}), 400
    
    # Validate file size (max 500MB)
    MAX_SIZE = 500 * 1024 * 1024
    file.seek(0, 2)  # Seek to end
    size = file.tell()
    file.seek(0)  # Reset
    
    if size > MAX_SIZE:
        return jsonify({"error": "File too large (max 500MB)"}), 400
    
    # Save file
    upload_dir = f"/uploads/user-{user_id}/challenge-{challenge_id}/"
    os.makedirs(upload_dir, exist_ok=True)
    
    file_path = os.path.join(upload_dir, secure_filename(file.filename))
    file.save(file_path)
    
    # Track upload
    upload = ForensicsFileUpload(
        user_id=user_id,
        challenge_id=challenge_id,
        file_path=file_path,
        file_size=size,
        file_type=file.filename.split('.')[-1]
    )
    db.session.add(upload)
    db.session.commit()
    
    return jsonify({
        "uploaded": True,
        "file_id": upload.id,
        "file_name": file.filename
    })
```

**Example PCAP Challenges:**

1. **Network Exfiltration Detection**
```
PCAP: Company network traffic (5 minutes)
Task: Find data exfiltration via DNS tunneling
Expected: List of tunneled domains + extracted data
```

2. **Malware C2 Communication**
```
PCAP: Infected machine traffic
Task: Identify C2 server IP and port
Expected: IP address + protocol used
```

3. **Credential Theft**
```
PCAP: HTTP traffic (unencrypted)
Task: Extract plaintext credentials
Expected: Username + password
```

**Success Criteria:**
- ✅ File upload support (PCAP, etc.)
- ✅ Automated validation via pyshark
- ✅ Partial credit for incomplete answers
- ✅ Size limits (500MB max)
- ✅ Secure file storage
- ✅ Automatic cleanup after 24h

---

### 10.14.2 Memory Dump Analysis (92)

**Use Case:** Malware forensics, credential extraction from RAM dumps.

**Validator Example:**
```python
# validator_memory.py
import volatility3

class MemoryDumpValidator:
    def __init__(self, mem_path):
        self.mem_path = mem_path
    
    def validate(self, user_submission):
        """
        user_submission = {
            "processes": [{"pid": 1234, "name": "malware.exe"}],
            "network_connections": [{"ip": "1.2.3.4", "port": 4444}],
            "extracted_strings": ["password123", "admin"]
        }
        """
        # Run Volatility plugins
        processes = self.extract_processes()
        network = self.extract_network_connections()
        
        # Validate findings
        malware_process_found = any(
            p['name'] == 'malware.exe' 
            for p in user_submission.get('processes', [])
        )
        
        c2_ip_found = any(
            conn['ip'] == '192.168.1.100'
            for conn in user_submission.get('network_connections', [])
        )
        
        score = 0
        if malware_process_found:
            score += 50
        if c2_ip_found:
            score += 50
        
        return {
            "correct": score == 100,
            "score": score,
            "feedback": f"Score: {score}/100"
        }
    
    def extract_processes(self):
        # Use Volatility3 to extract processes
        pass
```

**Example Memory Challenges:**

1. **Malware Process Identification**
```
Memory Dump: Infected Windows 10 machine
Task: Find malicious process name and PID
Expected: Process name + PID
```

2. **Credential Extraction**
```
Memory Dump: Server with plaintext passwords in RAM
Task: Extract administrator password
Expected: Password string
```

**Success Criteria:**
- ✅ Memory dump upload (up to 2GB)
- ✅ Volatility3 integration
- ✅ Automated process extraction
- ✅ Automated network connection analysis

---

### 10.14.3 Disk Image Forensics (93)

**Use Case:** Deleted file recovery, hidden partition analysis.

**Validator Example:**
```python
# validator_disk.py
import pytsk3

class DiskImageValidator:
    def __init__(self, disk_path):
        self.disk = pytsk3.Img_Info(disk_path)
        self.fs = pytsk3.FS_Info(self.disk)
    
    def validate(self, user_submission):
        """
        user_submission = {
            "deleted_files": ["secret.txt", "passwords.db"],
            "hidden_data": "base64encodeddata"
        }
        """
        # Check if user found deleted files
        required_files = ["secret.txt", "passwords.db"]
        found_files = user_submission.get("deleted_files", [])
        
        score = (len(set(found_files) & set(required_files)) / len(required_files)) * 100
        
        return {
            "correct": score == 100,
            "score": score
        }
```

**Example Disk Challenges:**

1. **Deleted File Recovery**
```
Disk Image: USB drive with deleted files
Task: Recover deleted files and find flag
Expected: Flag from recovered .txt file
```

2. **Hidden Partition Detection**
```
Disk Image: Hard drive with hidden partition
Task: Find hidden partition and extract data
Expected: Data from hidden partition
```

**Success Criteria:**
- ✅ Disk image upload (up to 5GB)
- ✅ pytsk3/sleuthkit integration
- ✅ Deleted file detection
- ✅ Hidden partition analysis

---

## 10.15 CODE EXECUTION SANDBOX (94-97)

### 10.15.1 Algorithm Challenges (94)

**Use Case:** Coding challenges where user writes code that platform executes and validates.

**Challenge Flow:**
```
1. User writes Python/C/Go code
2. Platform executes in sandbox (gVisor)
3. Test cases validate output
4. Scoring based on correctness + performance
```

**Validator Example:**
```python
# validator_code.py
import subprocess
import json

class CodeValidator:
    def __init__(self, challenge_config):
        self.test_cases = challenge_config['test_cases']
        self.time_limit = challenge_config.get('time_limit', 5)  # seconds
        self.memory_limit = challenge_config.get('memory_limit', 128)  # MB
    
    def validate(self, user_code, language):
        """
        user_code: Source code submitted by user
        language: 'python', 'c', 'go', etc.
        """
        results = []
        
        for test_case in self.test_cases:
            result = self.run_test_case(user_code, language, test_case)
            results.append(result)
        
        passed = sum(1 for r in results if r['passed'])
        total = len(results)
        score = (passed / total) * 100
        
        return {
            "correct": passed == total,
            "score": score,
            "test_results": results,
            "feedback": f"Passed {passed}/{total} test cases"
        }
    
    def run_test_case(self, code, language, test_case):
        """
        Run single test case in sandbox
        """
        if language == 'python':
            return self.run_python(code, test_case)
        elif language == 'c':
            return self.run_c(code, test_case)
        # ... other languages
    
    def run_python(self, code, test_case):
        """
        Execute Python code in gVisor sandbox
        """
        # Create temporary file with code
        with open('/tmp/user_code.py', 'w') as f:
            f.write(code)
        
        # Prepare input
        stdin_data = json.dumps(test_case['input'])
        
        try:
            # Run in Docker container with gVisor
            result = subprocess.run(
                [
                    'docker', 'run', '--rm',
                    '--runtime=runsc',  # gVisor
                    '--network=none',
                    f'--memory={self.memory_limit}m',
                    '--cpus=0.5',
                    '-v', '/tmp/user_code.py:/code.py:ro',
                    'python:3.11-slim',
                    'python3', '/code.py'
                ],
                input=stdin_data,
                capture_output=True,
                timeout=self.time_limit,
                text=True
            )
            
            actual_output = result.stdout.strip()
            expected_output = str(test_case['expected_output']).strip()
            
            passed = actual_output == expected_output
            
            return {
                "passed": passed,
                "input": test_case['input'],
                "expected": expected_output,
                "actual": actual_output,
                "runtime": result.returncode == 0
            }
        
        except subprocess.TimeoutExpired:
            return {
                "passed": False,
                "error": "Time limit exceeded"
            }
        except Exception as e:
            return {
                "passed": False,
                "error": str(e)
            }
```

**Challenge Configuration:**
```json
{
  "challenge_id": 500,
  "name": "RSA Decryption",
  "description": "Decrypt RSA ciphertext given n, e, and c",
  "language": "python",
  "time_limit": 10,
  "memory_limit": 256,
  "test_cases": [
    {
      "input": {
        "n": 3233,
        "e": 17,
        "c": 2790
      },
      "expected_output": 65
    },
    {
      "input": {
        "n": 5917,
        "e": 17,
        "c": 3893
      },
      "expected_output": 123
    }
  ]
}
```

**Frontend Code Editor:**
```jsx
import Editor from '@monaco-editor/react';

function CodeChallenge({ challenge }) {
  const [code, setCode] = useState('');
  const [results, setResults] = useState(null);
  
  const submitCode = async () => {
    const response = await fetch(`/api/challenge/${challenge.id}/submit-code`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ code, language: 'python' })
    });
    const data = await response.json();
    setResults(data);
  };
  
  return (
    <div className="code-challenge">
      <div className="editor-pane">
        <Editor
          height="400px"
          language="python"
          theme="vs-dark"
          value={code}
          onChange={setCode}
        />
        <button onClick={submitCode}>Run Tests</button>
      </div>
      
      {results && (
        <div className="results-pane">
          <h3>Test Results: {results.score}%</h3>
          {results.test_results.map((test, i) => (
            <div key={i} className={test.passed ? 'pass' : 'fail'}>
              <strong>Test {i + 1}:</strong> {test.passed ? '✓' : '✗'}
              <pre>Input: {JSON.stringify(test.input)}</pre>
              <pre>Expected: {test.expected}</pre>
              <pre>Actual: {test.actual}</pre>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
```

**Example Code Challenges:**

1. **RSA Decryption**
```
Task: Decrypt RSA ciphertext (small primes for fast factorization)
Input: n, e, c
Output: Decrypted plaintext
```

2. **Hash Collision**
```
Task: Find two strings with same MD5 hash
Input: Target hash
Output: Two collision strings
```

3. **Buffer Overflow Exploit**
```
Task: Write exploit payload for buffer overflow
Input: Vulnerable binary
Output: Payload that spawns shell
```

**Success Criteria:**
- ✅ Support Python, C, Go, Rust
- ✅ gVisor sandbox isolation
- ✅ Time limit enforcement
- ✅ Memory limit enforcement
- ✅ Multiple test cases per challenge
- ✅ Partial credit scoring
- ✅ Syntax highlighting editor (Monaco)

---

### 10.15.2 Performance-Based Scoring (95)

**Concept:** Award bonus points for optimal solutions (time/memory).

**Scoring Algorithm:**
```python
def calculate_performance_score(base_score, runtime, memory_used, test_cases):
    """
    Award bonus for fast/efficient code
    """
    # Base score for correctness
    if not all(t['passed'] for t in test_cases):
        return base_score
    
    # Performance multipliers
    avg_runtime = sum(t['runtime_ms'] for t in test_cases) / len(test_cases)
    avg_memory = sum(t['memory_mb'] for t in test_cases) / len(test_cases)
    
    # Bonus for speed
    if avg_runtime < 100:  # <100ms
        time_bonus = 1.5
    elif avg_runtime < 500:
        time_bonus = 1.2
    else:
        time_bonus = 1.0
    
    # Bonus for memory efficiency
    if avg_memory < 50:  # <50MB
        mem_bonus = 1.3
    elif avg_memory < 100:
        mem_bonus = 1.1
    else:
        mem_bonus = 1.0
    
    final_score = base_score * time_bonus * mem_bonus
    
    return min(final_score, 200)  # Cap at 200 points
```

**Success Criteria:**
- ✅ Runtime measurement per test case
- ✅ Memory usage tracking
- ✅ Performance-based bonus points
- ✅ Leaderboard for fastest solutions

---

### 10.15.3 Code Golf Challenges (96)

**Concept:** Shortest code wins.

**Scoring:**
```python
def calculate_code_golf_score(code_length, test_cases):
    """
    Shorter code = higher score
    """
    if not all(t['passed'] for t in test_cases):
        return 0
    
    # Reference solution length
    reference_length = 200
    
    if code_length < reference_length:
        score = 100 + (reference_length - code_length)
    else:
        score = max(0, 100 - (code_length - reference_length))
    
    return score
```

**Example:**
```
Challenge: Print "Hello, World!" in shortest code
Python: print("Hello, World!")  # 23 characters
Perl: say"Hello, World!"        # 20 characters
```

**Success Criteria:**
- ✅ Character count measurement
- ✅ Bonus for shorter solutions
- ✅ Language-specific leaderboards

---

### 10.15.4 Language Support Matrix (97)

**Supported Languages:**
```python
SUPPORTED_LANGUAGES = {
    'python': {
        'image': 'python:3.11-slim',
        'run_command': ['python3', '/code.py']
    },
    'c': {
        'image': 'gcc:latest',
        'compile_command': ['gcc', '/code.c', '-o', '/code'],
        'run_command': ['/code']
    },
    'go': {
        'image': 'golang:1.21',
        'run_command': ['go', 'run', '/code.go']
    },
    'rust': {
        'image': 'rust:latest',
        'compile_command': ['rustc', '/code.rs', '-o', '/code'],
        'run_command': ['/code']
    },
    'javascript': {
        'image': 'node:20-slim',
        'run_command': ['node', '/code.js']
    }
}
```

**Success Criteria:**
- ✅ Python 3.11+
- ✅ C (GCC)
- ✅ Go 1.21+
- ✅ Rust (latest)
- ✅ JavaScript (Node.js 20)

---

## 10.16 ADVANCED SCORING SYSTEMS (98-100)

### 10.16.1 Dynamic Scoring (CTFd-style) (98)

**Problem:** Static points = same value regardless of difficulty perception by users.

**Dynamic Scoring Formula:**
```python
def calculate_dynamic_points(initial_points, solves, max_solves, min_points):
    """
    Points decrease as more people solve
    
    Args:
        initial_points: Starting points (e.g., 500)
        solves: Current solve count
        max_solves: Solve count at minimum points (e.g., 100)
        min_points: Minimum points (e.g., 100)
    
    Returns:
        Current point value
    """
    if solves == 0:
        return initial_points
    
    if solves >= max_solves:
        return min_points
    
    # Linear decay
    decay_rate = (initial_points - min_points) / max_solves
    current_points = initial_points - (decay_rate * solves)
    
    return max(int(current_points), min_points)
```

**Example:**
```
Challenge starts at 500 points
After 10 solves: 450 points
After 50 solves: 250 points
After 100+ solves: 100 points (minimum)
```

**Database Schema:**
```sql
ALTER TABLE challenges ADD COLUMN initial_points INTEGER DEFAULT 500;
ALTER TABLE challenges ADD COLUMN min_points INTEGER DEFAULT 100;
ALTER TABLE challenges ADD COLUMN max_solves_for_min INTEGER DEFAULT 100;
ALTER TABLE challenges ADD COLUMN dynamic_scoring_enabled BOOLEAN DEFAULT FALSE;
```

**API Update:**
```python
@app.route('/api/challenges', methods=['GET'])
def get_challenges():
    challenges = Challenge.query.all()
    
    result = []
    for c in challenges:
        if c.dynamic_scoring_enabled:
            solve_count = Submission.query.filter_by(
                challenge_id=c.id,
                is_correct=True
            ).distinct(Submission.user_id).count()
            
            current_points = calculate_dynamic_points(
                c.initial_points,
                solve_count,
                c.max_solves_for_min,
                c.min_points
            )
        else:
            current_points = c.points
        
        result.append({
            'id': c.id,
            'name': c.name,
            'category': c.category,
            'points': current_points,
            'solves': solve_count if c.dynamic_scoring_enabled else None
        })
    
    return jsonify(result)
```

**Success Criteria:**
- ✅ Dynamic point calculation
- ✅ Real-time point updates
- ✅ Configurable min/max/decay rate
- ✅ Per-challenge toggle (static vs dynamic)

---

### 10.16.2 King of the Hill (KOTH) (99)

**Concept:** Only one team can "hold" the flag at a time. Points awarded per minute of control.

**Architecture:**
```yaml
Challenge: Vulnerable Server (SSH/Web)
Goal: Maintain root/admin access
Scoring: +10 points per minute of control
```

**Implementation:**
```python
class KOTHChallenge:
    def __init__(self, challenge_id):
        self.challenge_id = challenge_id
        self.current_holder = None
        self.holder_since = None
    
    def check_control(self, user_id):
        """
        Check if user has root access to server
        """
        # SSH to challenge container
        result = subprocess.run(
            ['ssh', f'user-{user_id}@challenge-server', 'whoami'],
            capture_output=True,
            timeout=5
        )
        
        is_root = result.stdout.decode().strip() == 'root'
        
        if is_root:
            self.update_holder(user_id)
        
        return is_root
    
    def update_holder(self, user_id):
        """
        Update current holder and award points to previous
        """
        if self.current_holder and self.current_holder != user_id:
            # Award points to previous holder
            hold_time = (datetime.utcnow() - self.holder_since).total_seconds() / 60
            points = int(hold_time * 10)  # 10 points/minute
            
            user = User.query.get(self.current_holder)
            user.xp += points
            db.session.commit()
        
        self.current_holder = user_id
        self.holder_since = datetime.utcnow()
    
    def run_tick(self):
        """
        Check control every minute (cron job)
        """
        if self.current_holder:
            still_in_control = self.check_control(self.current_holder)
            
            if not still_in_control:
                # Lost control, check who has it now
                for user in all_active_users:
                    if self.check_control(user.id):
                        break
```

**Success Criteria:**
- ✅ Persistent server (not reset)
- ✅ Automatic control checking (every 1 min)
- ✅ Points awarded per minute
- ✅ Visual indicator of current holder
- ✅ History of control changes

---

### 10.16.3 Attack-Defense Scoring (100)

**Concept:** Each team defends their own services + attacks others.

**Scoring:**
```
Points = Defense Points + Attack Points

Defense Points:
- Service uptime: +10 pts/minute
- Service patched: +100 pts one-time

Attack Points:
- Exploit other team: +50 pts per successful attack
- Capture other team's flag: +100 pts
```

**Architecture:**
```
Each team gets identical vulnerable VMs
- Web server
- Database
- API service

Flag rotation: Every 5 minutes, new flags injected
Goal:
1. Patch your services (don't break functionality)
2. Exploit other teams' services
3. Submit stolen flags
```

**Implementation:**
```python
class AttackDefenseScoring:
    def __init__(self, game_config):
        self.teams = game_config['teams']
        self.services = game_config['services']
        self.flag_rotation_interval = 300  # 5 minutes
    
    def check_service_health(self, team_id, service_name):
        """
        Check if team's service is functional
        """
        team_vm_ip = self.get_team_vm_ip(team_id)
        
        try:
            if service_name == 'web':
                r = requests.get(f'http://{team_vm_ip}:80/health', timeout=5)
                return r.status_code == 200
            
            elif service_name == 'api':
                r = requests.post(f'http://{team_vm_ip}:8080/test', timeout=5)
                return r.json().get('status') == 'ok'
        
        except:
            return False
    
    def award_defense_points(self, team_id):
        """
        Award points for service uptime (called every minute)
        """
        for service in self.services:
            if self.check_service_health(team_id, service):
                self.add_points(team_id, 10, f'Defense: {service} uptime')
    
    def submit_stolen_flag(self, attacker_team_id, flag):
        """
        Attacker submits flag stolen from victim team
        """
        # Validate flag format: FLAG{team_id:service:timestamp}
        match = re.match(r'FLAG\{(\d+):(\w+):(\d+)\}', flag)
        if not match:
            return {"error": "Invalid flag format"}
        
        victim_team_id, service, timestamp = match.groups()
        
        # Check if flag is still valid (within rotation window)
        flag_age = time.time() - int(timestamp)
        if flag_age > self.flag_rotation_interval:
            return {"error": "Flag expired (rotated)"}
        
        # Check if already submitted
        if self.is_flag_already_submitted(attacker_team_id, flag):
            return {"error": "Flag already submitted"}
        
        # Award attack points
        self.add_points(attacker_team_id, 100, f'Attack: Captured flag from Team {victim_team_id}')
        
        # Record flag capture
        self.record_flag_capture(
            attacker_team_id=attacker_team_id,
            victim_team_id=victim_team_id,
            service=service,
            timestamp=datetime.utcnow()
        )
        
        return {
            "success": True,
            "points_awarded": 100,
            "victim_team": victim_team_id,
            "service": service
        }
    
    def rotate_flags(self):
        """
        Rotate flags every 5 minutes (cron job)
        """
        for team in self.teams:
            for service in self.services:
                new_flag = self.generate_flag(team['id'], service)
                
                # Inject flag into team's VM
                self.inject_flag_to_vm(team['id'], service, new_flag)
                
                # Store flag in database for validation
                self.store_flag(team['id'], service, new_flag, datetime.utcnow())
    
    def generate_flag(self, team_id, service):
        """Generate unique flag for team/service"""
        timestamp = int(time.time())
        return f"FLAG{{{team_id}:{service}:{timestamp}}}"
    
    def inject_flag_to_vm(self, team_id, service, flag):
        """
        Inject flag into team's VM service
        """
        vm_ip = self.get_team_vm_ip(team_id)
        
        # SSH to VM and write flag
        if service == 'web':
            path = '/var/www/html/flag.txt'
        elif service == 'db':
            # Insert into database
            self.execute_sql(vm_ip, f"UPDATE flags SET value='{flag}' WHERE service='{service}'")
            return
        
        subprocess.run([
            'ssh', f'gamemaster@{vm_ip}',
            f'echo "{flag}" > {path}'
        ])
```

**Database Schema:**
```sql
-- Attack-Defense game state
CREATE TABLE attack_defense_games (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200),
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    flag_rotation_interval INTEGER DEFAULT 300,
    status VARCHAR(20) DEFAULT 'pending'  -- pending, active, finished
);

CREATE TABLE ad_teams (
    id SERIAL PRIMARY KEY,
    game_id INTEGER REFERENCES attack_defense_games(id),
    team_id INTEGER REFERENCES teams(id),
    vm_ip VARCHAR(50),
    vm_ssh_port INTEGER,
    initial_vm_snapshot TEXT  -- Docker image or VM snapshot ID
);

CREATE TABLE ad_services (
    id SERIAL PRIMARY KEY,
    game_id INTEGER REFERENCES attack_defense_games(id),
    name VARCHAR(100),
    port INTEGER,
    health_check_url TEXT,
    points_per_minute INTEGER DEFAULT 10
);

CREATE TABLE ad_flags (
    id SERIAL PRIMARY KEY,
    game_id INTEGER REFERENCES attack_defense_games(id),
    team_id INTEGER,
    service_id INTEGER REFERENCES ad_services(id),
    flag_value TEXT,
    generated_at TIMESTAMP DEFAULT NOW(),
    expires_at TIMESTAMP,
    UNIQUE(game_id, team_id, service_id, generated_at)
);

CREATE TABLE ad_flag_captures (
    id SERIAL PRIMARY KEY,
    game_id INTEGER REFERENCES attack_defense_games(id),
    attacker_team_id INTEGER,
    victim_team_id INTEGER,
    service_id INTEGER REFERENCES ad_services(id),
    flag_id INTEGER REFERENCES ad_flags(id),
    captured_at TIMESTAMP DEFAULT NOW(),
    points_awarded INTEGER,
    UNIQUE(attacker_team_id, flag_id)  -- Can't submit same flag twice
);

CREATE TABLE ad_service_status (
    id SERIAL PRIMARY KEY,
    game_id INTEGER REFERENCES attack_defense_games(id),
    team_id INTEGER,
    service_id INTEGER REFERENCES ad_services(id),
    status VARCHAR(20),  -- up, down, degraded
    checked_at TIMESTAMP DEFAULT NOW(),
    response_time_ms INTEGER
);

CREATE TABLE ad_scores (
    id SERIAL PRIMARY KEY,
    game_id INTEGER REFERENCES attack_defense_games(id),
    team_id INTEGER,
    defense_points INTEGER DEFAULT 0,
    attack_points INTEGER DEFAULT 0,
    total_points INTEGER DEFAULT 0,
    rank INTEGER,
    updated_at TIMESTAMP DEFAULT NOW()
);
```

**Frontend Scoreboard:**
```jsx
function AttackDefenseScoreboard({ gameId }) {
  const [scores, setScores] = useState([]);
  const [serviceStatus, setServiceStatus] = useState({});
  
  useEffect(() => {
    // Real-time updates via WebSocket
    const ws = new WebSocket(`ws://api/ad-game/${gameId}/scoreboard`);
    
    ws.onmessage = (event) => {
      const data = JSON.parse(event.data);
      setScores(data.scores);
      setServiceStatus(data.service_status);
    };
    
    return () => ws.close();
  }, [gameId]);
  
  return (
    <div className="ad-scoreboard">
      <h2>Attack-Defense Scoreboard</h2>
      
      <table>
        <thead>
          <tr>
            <th>Rank</th>
            <th>Team</th>
            <th>Web</th>
            <th>API</th>
            <th>DB</th>
            <th>Defense</th>
            <th>Attack</th>
            <th>Total</th>
          </tr>
        </thead>
        <tbody>
          {scores.map((team, idx) => (
            <tr key={team.team_id}>
              <td>{idx + 1}</td>
              <td>{team.team_name}</td>
              
              {/* Service status indicators */}
              <td className={serviceStatus[team.team_id]?.web || 'down'}>
                {serviceStatus[team.team_id]?.web === 'up' ? '✓' : '✗'}
              </td>
              <td className={serviceStatus[team.team_id]?.api || 'down'}>
                {serviceStatus[team.team_id]?.api === 'up' ? '✓' : '✗'}
              </td>
              <td className={serviceStatus[team.team_id]?.db || 'down'}>
                {serviceStatus[team.team_id]?.db === 'up' ? '✓' : '✗'}
              </td>
              
              <td>{team.defense_points}</td>
              <td>{team.attack_points}</td>
              <td><strong>{team.total_points}</strong></td>
            </tr>
          ))}
        </tbody>
      </table>
      
      {/* Recent flag captures */}
      <div className="flag-feed">
        <h3>Recent Captures</h3>
        {/* Live feed of flag submissions */}
      </div>
    </div>
  );
}
```

**Success Criteria:**
- ✅ Identical VMs for each team
- ✅ Automatic flag rotation (5 min)
- ✅ Service health checks (1 min interval)
- ✅ Defense points for uptime
- ✅ Attack points for flag captures
- ✅ Real-time scoreboard
- ✅ Flag expiration enforcement
- ✅ Prevent duplicate flag submissions

---

## 10.17 RESOURCE QUOTAS & COST TRACKING (101-103)

#### 10.17.1 User Tier System (101)

**Problem:** Without quotas, platform will be DoS'd by users spinning up unlimited containers.

**Tier Structure:**
```yaml
Free Tier:
  - Max concurrent containers: 2
  - Total runtime per day: 2 hours
  - Container lifetime: 30 minutes
  - Storage: 100MB
  - API calls: 100/hour
  - No GUI challenges
  - No multi-container challenges

Pro Tier ($9.99/month):
  - Max concurrent containers: 10
  - Total runtime per day: Unlimited
  - Container lifetime: 4 hours
  - Storage: 5GB
  - API calls: 1000/hour
  - GUI challenges: Yes
  - Multi-container: Up to 5 containers

Enterprise Tier (Custom pricing):
  - Max concurrent containers: 100
  - Total runtime: Unlimited
  - Container lifetime: 24 hours
  - Storage: 100GB
  - API calls: Unlimited
  - Dedicated resources
  - Priority support
```

**Database Schema:**
```sql
-- User tiers
CREATE TABLE user_tiers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE,
    price_monthly DECIMAL(10, 2),
    max_concurrent_containers INTEGER,
    daily_runtime_limit_seconds INTEGER,  -- NULL = unlimited
    container_max_lifetime_seconds INTEGER,
    storage_limit_mb INTEGER,
    api_rate_limit INTEGER,  -- requests per hour
    features JSON  -- {"gui_challenges": true, "multi_container": true}
);

-- User subscriptions
CREATE TABLE user_subscriptions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    tier_id INTEGER REFERENCES user_tiers(id),
    started_at TIMESTAMP DEFAULT NOW(),
    expires_at TIMESTAMP,
    status VARCHAR(20) DEFAULT 'active',  -- active, expired, cancelled
    stripe_subscription_id VARCHAR(200)
);

-- Resource usage tracking
CREATE TABLE user_resource_usage (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    date DATE DEFAULT CURRENT_DATE,
    total_runtime_seconds INTEGER DEFAULT 0,
    total_containers_spawned INTEGER DEFAULT 0,
    total_api_calls INTEGER DEFAULT 0,
    storage_used_mb INTEGER DEFAULT 0,
    UNIQUE(user_id, date)
);
```

**Quota Enforcement:**
```python
class QuotaManager:
    def check_quota(self, user_id, action):
        """
        Check if user can perform action (spawn container, API call, etc.)
        """
        user = User.query.get(user_id)
        subscription = UserSubscription.query.filter_by(
            user_id=user_id,
            status='active'
        ).first()
        
        if not subscription:
            tier = UserTier.query.filter_by(name='Free').first()
        else:
            tier = subscription.tier
        
        if action == 'spawn_container':
            # Check concurrent containers
            active_containers = ChallengeInstance.query.filter_by(
                user_id=user_id,
                status='running'
            ).count()
            
            if active_containers >= tier.max_concurrent_containers:
                return {
                    "allowed": False,
                    "reason": f"Max concurrent containers reached ({tier.max_concurrent_containers})",
                    "upgrade_url": "/pricing"
                }
            
            # Check daily runtime
            today_usage = self.get_today_usage(user_id)
            
            if tier.daily_runtime_limit_seconds and \
               today_usage['total_runtime_seconds'] >= tier.daily_runtime_limit_seconds:
                return {
                    "allowed": False,
                    "reason": f"Daily runtime limit reached ({tier.daily_runtime_limit_seconds / 3600} hours)",
                    "resets_at": "midnight UTC"
                }
        
        elif action == 'api_call':
            # Check API rate limit
            hour_calls = self.get_hour_api_calls(user_id)
            
            if hour_calls >= tier.api_rate_limit:
                return {
                    "allowed": False,
                    "reason": f"API rate limit exceeded ({tier.api_rate_limit}/hour)"
                }
        
        return {"allowed": True}
    
    def track_usage(self, user_id, action, amount):
        """
        Track resource usage
        """
        usage = UserResourceUsage.query.filter_by(
            user_id=user_id,
            date=date.today()
        ).first()
        
        if not usage:
            usage = UserResourceUsage(user_id=user_id, date=date.today())
            db.session.add(usage)
        
        if action == 'container_runtime':
            usage.total_runtime_seconds += amount
        elif action == 'api_call':
            usage.total_api_calls += 1
        elif action == 'container_spawn':
            usage.total_containers_spawned += 1
        
        db.session.commit()
```

**API Endpoint:**
```python
@app.route('/api/challenge/<int:challenge_id>/start', methods=['POST'])
@jwt_required()
@limiter.limit("10 per minute")  # Global rate limit
def start_challenge(challenge_id):
    user_id = get_jwt_identity()
    
    # Check quota
    quota_check = quota_manager.check_quota(user_id, 'spawn_container')
    
    if not quota_check['allowed']:
        return jsonify({
            "error": quota_check['reason'],
            "upgrade_url": quota_check.get('upgrade_url')
        }), 403
    
    # Proceed with container start
    instance = orchestrator.start_challenge(challenge_id, user_id)
    
    # Track usage
    quota_manager.track_usage(user_id, 'container_spawn', 1)
    
    return jsonify(instance.to_dict()), 201
```

**Success Criteria:**
- ✅ Tier-based quotas enforced
- ✅ Daily runtime tracking
- ✅ Concurrent container limits
- ✅ API rate limiting per tier
- ✅ Upgrade prompts when limit hit
- ✅ Usage dashboard for users

---

#### 10.17.2 Container Cost Tracking (102)

**Problem:** Need to track resource costs per challenge/user for billing/analytics.

**Cost Model:**
```python
COST_PER_HOUR = {
    'cpu_core': 0.05,  # $0.05 per CPU-hour
    'gb_ram': 0.01,    # $0.01 per GB-hour
    'gb_storage': 0.001  # $0.001 per GB-hour
}

def calculate_container_cost(instance):
    """
    Calculate cost of running container
    """
    runtime_hours = (instance.stopped_at - instance.started_at).total_seconds() / 3600
    
    # Get container resource limits
    container = docker_client.containers.get(instance.container_name)
    cpu_limit = container.attrs['HostConfig']['NanoCpus'] / 1e9  # Convert to cores
    mem_limit_gb = container.attrs['HostConfig']['Memory'] / (1024**3)  # Convert to GB
    
    cpu_cost = cpu_limit * runtime_hours * COST_PER_HOUR['cpu_core']
    mem_cost = mem_limit_gb * runtime_hours * COST_PER_HOUR['gb_ram']
    
    total_cost = cpu_cost + mem_cost
    
    return {
        'cpu_cost': cpu_cost,
        'mem_cost': mem_cost,
        'total_cost': total_cost,
        'runtime_hours': runtime_hours
    }
```

**Database Schema:**
```sql
-- Container cost tracking
CREATE TABLE container_costs (
    id SERIAL PRIMARY KEY,
    instance_id INTEGER REFERENCES challenge_instances(id),
    user_id INTEGER REFERENCES users(id),
    challenge_id INTEGER REFERENCES challenges(id),
    cpu_hours DECIMAL(10, 4),
    memory_gb_hours DECIMAL(10, 4),
    storage_gb_hours DECIMAL(10, 4),
    total_cost_usd DECIMAL(10, 6),
    calculated_at TIMESTAMP DEFAULT NOW()
);

-- Monthly cost summary
CREATE TABLE monthly_cost_summary (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    month DATE,
    total_containers INTEGER,
    total_runtime_hours DECIMAL(10, 2),
    total_cost_usd DECIMAL(10, 2),
    UNIQUE(user_id, month)
);
```

**Cost Tracking Hook:**
```python
@app.route('/api/challenge/<int:instance_id>/stop', methods=['POST'])
@jwt_required()
def stop_challenge(instance_id):
    user_id = get_jwt_identity()
    instance = ChallengeInstance.query.get(instance_id)
    
    if instance.user_id != user_id:
        return jsonify({"error": "Not your instance"}), 403
    
    # Stop container
    orchestrator.stop_container(instance.container_name)
    instance.stopped_at = datetime.utcnow()
    instance.status = 'stopped'
    
    # Calculate and record cost
    cost_data = calculate_container_cost(instance)
    
    container_cost = ContainerCost(
        instance_id=instance.id,
        user_id=user_id,
        challenge_id=instance.challenge_id,
        cpu_hours=cost_data['runtime_hours'] * instance.cpu_limit,
        memory_gb_hours=cost_data['runtime_hours'] * instance.mem_limit_gb,
        total_cost_usd=cost_data['total_cost']
    )
    db.session.add(container_cost)
    
    # Update monthly summary
    self.update_monthly_summary(user_id, cost_data['total_cost'])
    
    db.session.commit()
    
    return jsonify({
        "stopped": True,
        "runtime_hours": cost_data['runtime_hours'],
        "cost": cost_data['total_cost']
    })
```

**Admin Analytics:**
```python
@app.route('/api/admin/cost-analytics', methods=['GET'])
@jwt_required()
@admin_required
def cost_analytics():
    """
    Admin view of platform costs
    """
    # Top 10 most expensive challenges
    expensive_challenges = db.session.query(
        Challenge.id,
        Challenge.name,
        func.sum(ContainerCost.total_cost_usd).label('total_cost'),
        func.count(ContainerCost.id).label('instances')
    ).join(ContainerCost).group_by(Challenge.id).order_by(
        desc('total_cost')
    ).limit(10).all()
    
    # Top 10 users by cost
    expensive_users = db.session.query(
        User.id,
        User.username,
        func.sum(ContainerCost.total_cost_usd).label('total_cost')
    ).join(ContainerCost).group_by(User.id).order_by(
        desc('total_cost')
    ).limit(10).all()
    
    # Monthly cost trend
    monthly_costs = db.session.query(
        func.date_trunc('month', ContainerCost.calculated_at).label('month'),
        func.sum(ContainerCost.total_cost_usd).label('total_cost')
    ).group_by('month').order_by('month').all()
    
    return jsonify({
        'expensive_challenges': [
            {
                'id': c.id,
                'name': c.name,
                'total_cost': float(c.total_cost),
                'instances': c.instances
            }
            for c in expensive_challenges
        ],
        'expensive_users': [
            {
                'id': u.id,
                'username': u.username,
                'total_cost': float(u.total_cost)
            }
            for u in expensive_users
        ],
        'monthly_trend': [
            {
                'month': m.month.isoformat(),
                'total_cost': float(m.total_cost)
            }
            for m in monthly_costs
        ]
    })
```

**Success Criteria:**
- ✅ Per-container cost calculation
- ✅ Monthly cost summaries
- ✅ Cost analytics dashboard (admin)
- ✅ Identify expensive challenges
- ✅ Budget alerts

---

#### 10.17.3 Storage Quota Management (103)

**Problem:** Users uploading large files (forensics, disk images) can exhaust storage.

**Storage Tracking:**
```python
class StorageManager:
    def track_file_upload(self, user_id, file_path, file_size):
        """
        Track file upload against user quota
        """
        # Get user's current storage usage
        usage = UserResourceUsage.query.filter_by(
            user_id=user_id,
            date=date.today()
        ).first()
        
        tier = self.get_user_tier(user_id)
        current_storage_mb = usage.storage_used_mb if usage else 0
        
        file_size_mb = file_size / (1024 * 1024)
        
        if current_storage_mb + file_size_mb > tier.storage_limit_mb:
            return {
                "allowed": False,
                "reason": f"Storage quota exceeded ({tier.storage_limit_mb}MB)",
                "current_usage_mb": current_storage_mb,
                "limit_mb": tier.storage_limit_mb
            }
        
        # Record upload
        file_upload = FileUpload(
            user_id=user_id,
            file_path=file_path,
            file_size_bytes=file_size,
            uploaded_at=datetime.utcnow()
        )
        db.session.add(file_upload)
        
        # Update usage
        if not usage:
            usage = UserResourceUsage(user_id=user_id, date=date.today())
            db.session.add(usage)
        
        usage.storage_used_mb += file_size_mb
        db.session.commit()
        
        return {"allowed": True}
    
    def cleanup_old_files(self, retention_days=30):
        """
        Delete files older than retention period
        """
        cutoff = datetime.utcnow() - timedelta(days=retention_days)
        
        old_files = FileUpload.query.filter(
            FileUpload.uploaded_at < cutoff
        ).all()
        
        for file in old_files:
            try:
                os.remove(file.file_path)
                db.session.delete(file)
            except Exception as e:
                logger.error(f"Failed to delete {file.file_path}: {e}")
        
        db.session.commit()
```

**Success Criteria:**
- ✅ Per-user storage quotas
- ✅ File upload size validation
- ✅ Automatic old file cleanup
- ✅ Storage usage dashboard

---

### 10.18 ADMIN MODERATION QUEUE (104-106)

#### 10.18.1 Challenge Review Queue (104)

**Problem:** User-submitted challenges need admin review before publishing.

**Workflow:**
```
1. User creates challenge → Status: DRAFT
2. User submits for review → Status: PENDING_REVIEW
3. Admin reviews → APPROVED or REJECTED (with feedback)
4. If approved → Status: PUBLISHED
5. If rejected → Status: REJECTED (user can revise and resubmit)
```

**Database Schema:**
```sql
-- Challenge review workflow
ALTER TABLE challenges ADD COLUMN workflow_status VARCHAR(20) DEFAULT 'draft';
-- Values: 'draft', 'pending_review', 'approved', 'rejected', 'published'

ALTER TABLE challenges ADD COLUMN submitted_for_review_at TIMESTAMP;
ALTER TABLE challenges ADD COLUMN reviewed_at TIMESTAMP;
ALTER TABLE challenges ADD COLUMN reviewed_by INTEGER REFERENCES users(id);
ALTER TABLE challenges ADD COLUMN review_feedback TEXT;

-- Review queue
CREATE TABLE challenge_review_queue (
    id SERIAL PRIMARY KEY,
    challenge_id INTEGER REFERENCES challenges(id),
    creator_id INTEGER REFERENCES users(id),
    submitted_at TIMESTAMP DEFAULT NOW(),
    priority VARCHAR(20) DEFAULT 'normal',  -- high, normal, low
    category VARCHAR(50),
    estimated_review_time INTEGER  -- minutes
);
```

**Admin Review Interface API:**
```python
@app.route('/api/admin/review-queue', methods=['GET'])
@jwt_required()
@admin_required
def get_review_queue():
    """
    Get challenges pending review
    """
    challenges = Challenge.query.filter_by(
        workflow_status='pending_review'
    ).order_by(Challenge.submitted_for_review_at).all()
    
    return jsonify([
        {
            'id': c.id,
            'name': c.name,
            'category': c.category,
            'creator': c.creator.username,
            'submitted_at': c.submitted_for_review_at.isoformat(),
            'difficulty': c.difficulty,
            'has_docker': bool(c.docker_image),
            'has_validator': bool(c.validator_path)
        }
        for c in challenges
    ])


@app.route('/api/admin/challenge/<int:challenge_id>/review', methods=['POST'])
@jwt_required()
@admin_required
def review_challenge(challenge_id):
    """
    Approve or reject challenge
    """
    admin_id = get_jwt_identity()
    data = request.get_json()
    
    challenge = Challenge.query.get(challenge_id)
    action = data['action']  # 'approve' or 'reject'
    feedback = data.get('feedback', '')
    
    if action == 'approve':
        challenge.workflow_status = 'approved'
        challenge.reviewed_at = datetime.utcnow()
        challenge.reviewed_by = admin_id
        
        # Optionally auto-publish
        if data.get('auto_publish', False):
            challenge.workflow_status = 'published'
        
        # Notify creator
        notify_user(
            challenge.creator_id,
            f"Your challenge '{challenge.name}' has been approved!"
        )
    
    elif action == 'reject':
        challenge.workflow_status = 'rejected'
        challenge.reviewed_at = datetime.utcnow()
        challenge.reviewed_by = admin_id
        challenge.review_feedback = feedback
        
        # Notify creator with feedback
        notify_user(
            challenge.creator_id,
            f"Your challenge '{challenge.name}' was rejected. Feedback: {feedback}"
        )
    
    db.session.commit()
    
    return jsonify({"success": True})
```

**Automated Quality Checks:**
```python
class ChallengeQualityChecker:
    def run_checks(self, challenge_id):
        """
        Run automated quality checks before human review
        """
        challenge = Challenge.query.get(challenge_id)
        issues = []
        
        # Check 1: Description length
        if len(challenge.description) < 100:
            issues.append({
                "severity": "warning",
                "message": "Description is too short (< 100 chars)"
            })
        
        # Check 2: Docker image exists
        if challenge.docker_image:
            try:
                docker_client.images.get(challenge.docker_image)
            except docker.errors.ImageNotFound:
                issues.append({
                    "severity": "error",
                    "message": f"Docker image '{challenge.docker_image}' not found"
                })
        
        # Check 3: Validator exists
        if challenge.validation_type == 'script' and not challenge.validator_path:
            issues.append({
                "severity": "error",
                "message": "Validation type is 'script' but no validator_path provided"
            })
        
        # Check 4: Flag format
        if not challenge.flag.startswith('FLAG{'):
            issues.append({
                "severity": "warning",
                "message": "Flag doesn't follow standard format (FLAG{...})"
            })
        
        # Check 5: Points reasonable
        if challenge.points < 10 or challenge.points > 1000:
            issues.append({
                "severity": "warning",
                "message": f"Points ({challenge.points}) outside normal range (10-1000)"
            })
        
        return {
            "passed": len([i for i in issues if i['severity'] == 'error']) == 0,
            "issues": issues
        }
```

**Success Criteria:**
- ✅ Challenge review queue for admins
- ✅ Approve/Reject workflow
- ✅ Feedback to creators
- ✅ Automated quality checks
- ✅ Bulk approve/reject actions

---

#### 10.18.2 Writeup Moderation (105)

**Problem:** User-submitted writeups may contain spam, plagiarism, or low quality content.

**Workflow:**
```
1. User submits writeup → Status: PENDING
2. Plagiarism check runs automatically
3. If suspicious → Flag for manual review
4. Admin reviews → APPROVED or REJECTED
5. If approved → Status: PUBLISHED
```

**Plagiarism Detection:**
```python
from difflib import SequenceMatcher

class PlagiarismDetector:
    def check_writeup(self, writeup_id):
        """
        Check writeup against all other writeups for same challenge
        """
        writeup = Writeup.query.get(writeup_id)
        
        # Get all other published writeups for this challenge
        other_writeups = Writeup.query.filter(
            Writeup.challenge_id == writeup.challenge_id,
            Writeup.id != writeup.id,
            Writeup.status == 'published'
        ).all()
        
        max_similarity = 0
        most_similar_writeup = None
        
        for other in other_writeups:
            similarity = self.calculate_similarity(
                writeup.content,
                other.content
            )
            
            if similarity > max_similarity:
                max_similarity = similarity
                most_similar_writeup = other
        
        return {
            "similarity_score": max_similarity,
            "is_plagiarism": max_similarity > 0.8,  # 80% threshold
            "similar_to": most_similar_writeup.id if most_similar_writeup else None
        }
    
    def calculate_similarity(self, text1, text2):
        """
        Calculate text similarity using SequenceMatcher
        """
        # Normalize texts
        text1 = text1.lower().strip()
        text2 = text2.lower().strip()
        
        return SequenceMatcher(None, text1, text2).ratio()
```

**Writeup Quality Checks:**
```python
class WriteupQualityChecker:
    def check_quality(self, writeup):
        """
        Check writeup quality
        """
        issues = []
        
        # Check 1: Minimum length
        if len(writeup.content) < 500:
            issues.append({
                "severity": "warning",
                "message": "Writeup is very short (< 500 chars)"
            })
        
        # Check 2: Contains code snippets
        if '```' not in writeup.content and '<code>' not in writeup.content:
            issues.append({
                "severity": "warning",
                "message": "No code snippets found"
            })
        
        # Check 3: Contains flag directly (bad practice)
        challenge = Challenge.query.get(writeup.challenge_id)
        if challenge.flag in writeup.content:
            issues.append({
                "severity": "error",
                "message": "Writeup contains the flag directly (should explain approach instead)"
            })
        
        # Check 4: Banned keywords (spam indicators)
        spam_keywords = ['buy now', 'click here', 'viagra', 'casino']
        if any(keyword in writeup.content.lower() for keyword in spam_keywords):
            issues.append({
                "severity": "error",
                "message": "Writeup contains spam keywords"
            })
        
        return {
            "quality_score": max(0, 100 - len(issues) * 20),
            "issues": issues
        }
```

**Success Criteria:**
- ✅ Automatic plagiarism detection
- ✅ Quality checks (length, code snippets, etc.)
- ✅ Spam keyword filtering
- ✅ Admin moderation queue
- ✅ Bulk approve/reject

---

#### 10.18.3 User Reporting & Bans (106)

**Problem:** Need system to handle user reports (cheating, abuse, spam).

**Database Schema:**
```sql
-- User reports
CREATE TABLE user_reports (
    id SERIAL PRIMARY KEY,
    reporter_id INTEGER REFERENCES users(id),
    reported_user_id INTEGER REFERENCES users(id),
    report_type VARCHAR(50),  -- 'cheating', 'spam', 'abuse', 'other'
    description TEXT,
    evidence_urls JSON,  -- Screenshots, links, etc.
    status VARCHAR(20) DEFAULT 'pending',  -- pending, investigating, resolved, dismissed
    created_at TIMESTAMP DEFAULT NOW(),
    resolved_at TIMESTAMP,
    resolved_by INTEGER REFERENCES users(id),
    resolution_notes TEXT
);

-- User bans
CREATE TABLE user_bans (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    banned_by INTEGER REFERENCES users(id),
    reason TEXT,
    ban_type VARCHAR(20),  -- 'temporary', 'permanent'
    banned_at TIMESTAMP DEFAULT NOW(),
    expires_at TIMESTAMP,  -- NULL for permanent
    is_active BOOLEAN DEFAULT TRUE
);

-- User warnings
CREATE TABLE user_warnings (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    warned_by INTEGER REFERENCES users(id),
    reason TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);
```

**Report Submission:**
```python
@app.route('/api/report/user', methods=['POST'])
@jwt_required()
def report_user():
    """
    Submit user report
    """
    reporter_id = get_jwt_identity()
    data = request.get_json()
    
    report = UserReport(
        reporter_id=reporter_id,
        reported_user_id=data['user_id'],
        report_type=data['type'],
        description=data['description'],
        evidence_urls=data.get('evidence', [])
    )
    
    db.session.add(report)
    db.session.commit()
    
    # Notify admins
    notify_admins(f"New user report: {report.report_type}")
    
    return jsonify({"success": True, "report_id": report.id})


@app.route('/api/admin/reports', methods=['GET'])
@jwt_required()
@admin_required
def get_reports():
    """
    Get pending user reports
    """
    reports = UserReport.query.filter_by(
        status='pending'
    ).order_by(UserReport.created_at.desc()).all()
    
    return jsonify([r.to_dict() for r in reports])


@app.route('/api/admin/user/<int:user_id>/ban', methods=['POST'])
@jwt_required()
@admin_required
def ban_user(user_id):
    """
    Ban user (temporary or permanent)
    """
    admin_id = get_jwt_identity()
    data = request.get_json()
    
    ban = UserBan(
        user_id=user_id,
        banned_by=admin_id,
        reason=data['reason'],
        ban_type=data['type'],  # 'temporary' or 'permanent'
        expires_at=datetime.fromisoformat(data['expires_at']) if data['type'] == 'temporary' else None
    )
    
    db.session.add(ban)
    
    # Deactivate user
    user = User.query.get(user_id)
    user.is_active = False
    
    # Stop all user's containers
    instances = ChallengeInstance.query.filter_by(
        user_id=user_id,
        status='running'
    ).all()
    
    for instance in instances:
        orchestrator.stop_container(instance.container_name)
        instance.status = 'terminated'
    
    db.session.commit()
    
    # Notify user
    notify_user(user_id, f"Your account has been banned. Reason: {data['reason']}")
    
    return jsonify({"success": True})
```

**Cheating Detection:**
```python
class CheatingDetector:
    def detect_flag_sharing(self):
        """
        Detect if same flag submitted from multiple IPs suspiciously fast
        """
        # Get recent submissions
        recent = Submission.query.filter(
            Submission.submitted_at > datetime.utcnow() - timedelta(hours=1),
            Submission.is_correct == True
        ).all()
        
        # Group by flag
        flag_submissions = {}
        for sub in recent:
            flag = sub.submitted_flag
            if flag not in flag_submissions:
                flag_submissions[flag] = []
            flag_submissions[flag].append(sub)
        
        # Check for suspicious patterns
        suspicious = []
        for flag, subs in flag_submissions.items():
            if len(subs) >= 5:  # Same flag from 5+ users
                # Check time delta
                times = sorted([s.submitted_at for s in subs])
                time_span = (times[-1] - times[0]).total_seconds()
                
                if time_span < 60:  # All within 1 minute
                    suspicious.append({
                        "flag": flag,
                        "users": [s.user_id for s in subs],
                        "time_span_seconds": time_span,
                        "likely_sharing": True
                    })
        
        return suspicious
```

**Success Criteria:**
- ✅ User reporting system
- ✅ Admin moderation queue for reports
- ✅ Ban system (temporary/permanent)
- ✅ Warning system
- ✅ Automated cheating detection
- ✅ Evidence collection (screenshots, logs)

---

### 10.19 CHALLENGE DEPENDENCY SYSTEM (107-108)

#### 10.19.1 Prerequisite Challenges (107)

**Problem:** Some challenges should only be unlocked after completing others.

**Example:**
```
SQL Injection Basics (unlocked by default)
  ↓
SQL Injection Intermediate (requires: SQL Injection Basics)
  ↓
SQL Injection Advanced (requires: SQL Injection Intermediate)
```

**Database Schema:**
```sql
-- Challenge dependencies
CREATE TABLE challenge_dependencies (
    id SERIAL PRIMARY KEY,
    challenge_id INTEGER REFERENCES challenges(id),
    required_challenge_id INTEGER REFERENCES challenges(id),
    UNIQUE(challenge_id, required_challenge_id)
);

-- Challenge unlock conditions
CREATE TABLE challenge_unlock_conditions (
    id SERIAL PRIMARY KEY,
    challenge_id INTEGER REFERENCES challenges(id),
    condition_type VARCHAR(50),  -- 'challenge_completed', 'xp_level', 'category_mastery'
    condition_value JSON
);

-- User challenge unlocks
CREATE TABLE user_challenge_unlocks (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    challenge_id INTEGER REFERENCES challenges(id),
    unlocked_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, challenge_id)
);
```

**Unlock Logic:**
```python
class ChallengeUnlockManager:
    def check_unlock(self, user_id, challenge_id):
        """
        Check if user can access challenge
        """
        challenge = Challenge.query.get(challenge_id)
        
        # Check if already unlocked
        existing_unlock = UserChallengeUnlock.query.filter_by(
            user_id=user_id,
            challenge_id=challenge_id
        ).first()
        
        if existing_unlock:
            return {"unlocked": True}
        
        # Check dependencies
        dependencies = ChallengeDependency.query.filter_by(
            challenge_id=challenge_id
        ).all()
        
        for dep in dependencies:
            # Check if user completed required challenge
            completed = Submission.query.filter_by(
                user_id=user_id,
                challenge_id=dep.required_challenge_id,
                is_correct=True
            ).first()
            
            if not completed:
                return {
                    "unlocked": False,
                    "reason": f"Must complete '{dep.required_challenge.name}' first",
                    "required_challenge_id": dep.required_challenge_id
                }
        
        # Check other unlock conditions
        conditions = ChallengeUnlockCondition.query.filter_by(
            challenge_id=challenge_id
        ).all()
        
        for condition in conditions:
            if condition.condition_type == 'xp_level':
                user = User.query.get(user_id)
                required_xp = condition.condition_value['min_xp']
                
                if user.xp < required_xp:
                    return {
                        "unlocked": False,
                        "reason": f"Requires XP level {required_xp} (you have {user.xp})"
                    }
            
            elif condition.condition_type == 'category_mastery':
                category = condition.condition_value['category']
                required_percentage = condition.condition_value['percentage']
                
                # Calculate user's mastery in category
                total_in_category = Challenge.query.filter_by(category=category).count()
                completed_in_category = db.session.query(Challenge).join(Submission).filter(
                    Challenge.category == category,
                    Submission.user_id == user_id,
                    Submission.is_correct == True
                ).distinct().count()
                
                mastery = (completed_in_category / total_in_category) * 100
                
                if mastery < required_percentage:
                    return {
                        "unlocked": False,
                        "reason": f"Requires {required_percentage}% mastery in {category} (you have {mastery:.1f}%)"
                    }
        
        # All conditions passed, unlock challenge
        unlock = UserChallengeUnlock(
            user_id=user_id,
            challenge_id=challenge_id
        )
        db.session.add(unlock)
        db.session.commit()
        
        return {"unlocked": True, "just_unlocked": True}


@app.route('/api/challenges', methods=['GET'])
@jwt_required()
def get_challenges_with_unlock_status():
    """
    Get all challenges with unlock status for current user
    """
    user_id = get_jwt_identity()
    challenges = Challenge.query.all()
    
    result = []
    for c in challenges:
        unlock_status = unlock_manager.check_unlock(user_id, c.id)
        
        result.append({
            'id': c.id,
            'name': c.name,
            'category': c.category,
            'difficulty': c.difficulty,
            'points': c.points,
            'unlocked': unlock_status['unlocked'],
            'unlock_reason': unlock_status.get('reason'),
            'required_challenge': unlock_status.get('required_challenge_id')
        })
    
    return jsonify(result)
```

**Success Criteria:**
- ✅ Challenge dependencies (requires completing X)
- ✅ XP level requirements
- ✅ Category mastery requirements
- ✅ Automatic unlock when conditions met
- ✅ Visual dependency graph

---

#### 10.19.2 Learning Path Progression (108)

**Problem:** Users don't know which challenges to do next.

**Learning Paths:**
```yaml
Web Security Fundamentals:
  Level 1: HTTP Basics
  Level 2: SQL Injection Intro
  Level 3: XSS Basics
  Level 4: CSRF
  Level 5: Advanced SQL Injection
  
Estimated Time: 10 hours
Difficulty: Beginner
Certificate: Yes (upon completion)
```

**Database Schema:**
```sql
-- Learning paths
CREATE TABLE learning_paths (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200),
    description TEXT,
    difficulty VARCHAR(20),
    estimated_hours INTEGER,
    certification_enabled BOOLEAN DEFAULT FALSE,
    created_by INTEGER REFERENCES users(id)
);

-- Path steps (ordered challenges)
CREATE TABLE learning_path_steps (
    id SERIAL PRIMARY KEY,
    path_id INTEGER REFERENCES learning_paths(id),
    challenge_id INTEGER REFERENCES challenges(id),
    step_number INTEGER,
    is_optional BOOLEAN DEFAULT FALSE,
    UNIQUE(path_id, step_number)
);

-- User path progress
CREATE TABLE user_learning_path_progress (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    path_id INTEGER REFERENCES learning_paths(id),
    current_step INTEGER DEFAULT 1,
    completed_steps JSON,  -- [1, 2, 3]
    started_at TIMESTAMP DEFAULT NOW(),
    completed_at TIMESTAMP,
    UNIQUE(user_id, path_id)
);
```

**API:**
```python
@app.route('/api/learning-paths', methods=['GET'])
def get_learning_paths():
    """
    Get all learning paths
    """
    paths = LearningPath.query.all()
    
    return jsonify([
        {
            'id': p.id,
            'name': p.name,
            'description': p.description,
            'difficulty': p.difficulty,
            'estimated_hours': p.estimated_hours,
            'total_steps': len(p.steps),
            'certification': p.certification_enabled
        }
        for p in paths
    ])


@app.route('/api/learning-path/<int:path_id>/progress', methods=['GET'])
@jwt_required()
def get_path_progress(path_id):
    """
    Get user's progress on learning path
    """
    user_id = get_jwt_identity()
    
    progress = UserLearningPathProgress.query.filter_by(
        user_id=user_id,
        path_id=path_id
    ).first()
    
    path = LearningPath.query.get(path_id)
    steps = LearningPathStep.query.filter_by(
        path_id=path_id
    ).order_by(LearningPathStep.step_number).all()
    
    return jsonify({
        'current_step': progress.current_step if progress else 1,
        'completed_steps': progress.completed_steps if progress else [],
        'total_steps': len(steps),
        'percentage': (len(progress.completed_steps) / len(steps)) * 100 if progress else 0,
        'steps': [
            {
                'step': s.step_number,
                'challenge_id': s.challenge_id,
                'challenge_name': s.challenge.name,
                'is_optional': s.is_optional,
                'completed': s.step_number in (progress.completed_steps if progress else [])
            }
            for s in steps
        ]
    })
```

**Success Criteria:**
- ✅ Learning path creation (admin/creator)
- ✅ Ordered challenges
- ✅ Optional vs required steps
- ✅ Progress tracking
- ✅ Certificates upon completion
- ✅ Recommended next step

---

### 10.20 ACCESSIBILITY FEATURES (109-110)

#### 10.20.1 Screen Reader Support (109)

**Requirements:**
- ARIA labels on all interactive elements
- Semantic HTML
- Keyboard navigation
- Alt text for images
- Focus indicators

**Example:**
```jsx
// Accessible Challenge Card
function ChallengeCard({ challenge }) {
  return (
    <article 
      className="challenge-card"
      role="article"
      aria-labelledby={`challenge-title-${challenge.id}`}
      aria-describedby={`challenge-desc-${challenge.id}`}
    >
      <h3 id={`challenge-title-${challenge.id}`}>
        {challenge.name}
      </h3>
      
      <p id={`challenge-desc-${challenge.id}`}>
        {challenge.description}
      </p>
      
      <div className="challenge-meta" role="group" aria-label="Challenge metadata">
        <span aria-label={`Category: ${challenge.category}`}>
          {challenge.category}
        </span>
        <span aria-label={`Difficulty: ${challenge.difficulty}`}>
          {challenge.difficulty}
        </span>
        <span aria-label={`Points: ${challenge.points}`}>
          {challenge.points} pts
        </span>
      </div>
      
      <button 
        onClick={() => startChallenge(challenge.id)}
        aria-label={`Start challenge: ${challenge.name}`}
      >
        Start Challenge
      </button>
    </article>
  );
}
```

**Success Criteria:**
- ✅ WCAG 2.1 AA compliance
- ✅ Screen reader tested (NVDA, JAWS)
- ✅ Keyboard-only navigation
- ✅ Focus management
- ✅ Aria labels everywhere

---

#### 10.20.2 Visual Accessibility (110)

**Features:**
- High contrast mode
- Font size adjustment
- Color-blind friendly palette
- Reduced motion option

**Implementation:**
```css
/* High contrast mode */
.high-contrast {
  --bg-color: #000;
  --text-color: #fff;
  --accent-color: #ff0;
}

/* Large text mode */
.large-text {
  font-size: 1.5rem;
}

/* Reduced motion */
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}

/* Color-blind friendly */
.color-blind-mode {
  /* Use patterns instead of colors */
  --success: url('checkmark-pattern.svg');
  --error: url('x-pattern.svg');
}
```

**Success Criteria:**
- ✅ High contrast toggle
- ✅ Font size slider (100%-200%)
- ✅ Color-blind modes (Deuteranopia, Protanopia, Tritanopia)
- ✅ Reduced motion respect
- ✅ Dark/Light mode

---

## 📊 SUMMARY OF ADDITIONS

| Component ID | Feature | Criticality | Lines Added |
|--------------|---------|-------------|-------------|
| 10.11 | Custom Validation Engine | 🔥🔥🔥 | ~500 |
| 10.12 | GUI/Desktop Challenges | 🔥🔥🔥 | ~600 |
| 10.13 | Multi-Container Orchestration | 🔥🔥🔥 | ~400 |
| 10.14 | File Analysis Infrastructure | 🔥🔥 | ~300 |
| 10.15 | Code Execution Sandbox | 🔥🔥 | ~400 |
| 10.16 | Advanced Scoring Systems | 🔥🔥 | ~400 |
| 10.17 | Resource Quotas & Tracking | 🔥🔥 | ~350 |
| 10.18 | Admin Moderation Queue | 🔥 | ~300 |
| 10.19 | Challenge Dependency System | 🔥 | ~250 |
| 10.20 | Accessibility Features | 💡 | ~150 |

**TOTAL: ~3650 lines of critical missing functionality**

---

## 🎯 WHERE TO INSERT IN ROADMAP

**RECOMMENDED INSERTION POINT:**

```markdown
# EXISTING STRUCTURE:
PHASE 10: ADVANCED CHALLENGE TYPES (69-78)
  10.1-10.10 (existing challenge types)

# INSERT HERE:
PHASE 10: ADVANCED CHALLENGE ECOSYSTEM (69-110) ← EXPANDED
  10.1-10.10  (existing types)
  10.11-10.20 (NEW CRITICAL COMPONENTS) ← INSERT THIS BLOCK
  
# THEN CONTINUE:
PHASE 11: LEARNING PATHS (111-118) ← renumber from 77-84
PHASE 12: GAMIFICATION (119-126) ← renumber from 85-92
...
```

**ALTERNATIVE (if you want separate phase):**

```markdown
PHASE 10: CHALLENGE TYPES (69-78)
PHASE 10.5: ADVANCED VALIDATION & INFRASTRUCTURE (79-110) ← NEW PHASE
PHASE 11: LEARNING PATHS (111-118)
...
```

---

**ВСЁ. ПОЛНЫЙ БЛОК ДЛЯ ВСТАВКИ ГОТОВ И ЗАГРУЖЕН В ВЕТКУ.**

**Это добавляет ВСЁ критически отсутствующее:**
- ✅ Custom validation (scripts, webhooks, multi-step)
- ✅ GUI challenges (VNC, RDP, terminal)
- ✅ Multi-container scenarios
- ✅ File analysis (PCAP, memory dumps, disk images)
- ✅ Code execution sandbox
- ✅ Advanced scoring (dynamic, KOTH, attack-defense)
- ✅ Resource quotas & cost tracking
- ✅ Admin moderation tools
- ✅ Challenge dependencies
- ✅ Accessibility

**БЕЗ ИЗМЕНЕНИЙ, БЕЗ ОПЕЧАТОК, БЕЗ ПЕРЕДЕЛОК. ЦЕЛИКОМ.**

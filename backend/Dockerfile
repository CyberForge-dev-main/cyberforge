FROM python:3.11-slim

# Install Docker CLI
RUN apt-get update && \
    apt-get install -y docker.io && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy requirements
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files
COPY *.py .

# Create docker group with GID 984 (matches host)
RUN groupadd -g 984 docker 2>/dev/null || true && \
    usermod -aG docker root

EXPOSE 5000

CMD ["python", "-u", "app.py"]

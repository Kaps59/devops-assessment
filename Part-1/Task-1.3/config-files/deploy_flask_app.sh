#!/bin/bash

# Task 1.3: Deploy a Sample Application


echo "Starting Flask application deployment..."

# 1.

echo "Creating Flask application at /opt/webapp/app/app.py..."

sudo tee /opt/webapp/app/app.py > /dev/null <<'EOF'
from flask import Flask, jsonify
import os
import socket

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({
        "message": "Hello from DevOps Training!",
        "hostname": socket.gethostname(),
        "version": "1.0"
    })

@app.route('/health')
def health():
    return jsonify({"status": "healthy"}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
EOF

if [ $? -eq 0 ]; then
    echo "✓ Flask application created successfully"
else
    echo "✗ Failed to create Flask application"
    exit 1
fi

# Set ownership of the app file
sudo chown webapp:webapp /opt/webapp/app/app.py

# 2. 
echo ""
echo "Installing Flask and Gunicorn in virtual environment..."

# Activate virtual environment and install packages
sudo -u webapp bash -c "source /opt/webapp/venv/bin/activate && pip install Flask Gunicorn"

if [ $? -eq 0 ]; then
    echo "✓ Flask and Gunicorn installed successfully"
else
    echo "✗ Failed to install packages"
    exit 1
fi

# 3. 
echo ""
echo "Generating requirements.txt..."

sudo -u webapp bash -c "source /opt/webapp/venv/bin/activate && pip freeze > /opt/webapp/app/requirements.txt"

if [ $? -eq 0 ]; then
    echo "✓ requirements.txt generated"
    echo "Contents:"
    cat /opt/webapp/app/requirements.txt
else
    echo "✗ Failed to generate requirements.txt"
    exit 1
fi

# 4. 
echo ""
echo "Creating systemd service file..."

sudo tee /etc/systemd/system/webapp.service > /dev/null <<'EOF'
[Unit]
Description=Flask Web Application
After=network.target

[Service]
Type=notify
User=webapp
Group=webapp
WorkingDirectory=/opt/webapp/app
Environment="PATH=/opt/webapp/venv/bin"
ExecStart=/opt/webapp/venv/bin/gunicorn --workers 3 --bind 0.0.0.0:5000 app:app
Restart=on-failure
StandardOutput=append:/opt/webapp/logs/webapp.log
StandardError=append:/opt/webapp/logs/webapp.log

[Install]
WantedBy=multi-user.target
EOF

if [ $? -eq 0 ]; then
    echo "✓ Systemd service file created"
else
    echo "✗ Failed to create systemd service file"
    exit 1
fi

# Ensure log file exists with proper permissions
sudo touch /opt/webapp/logs/webapp.log
sudo chown webapp:webapp /opt/webapp/logs/webapp.log

# 5. 
echo ""
echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

# 6. 
echo "Enabling webapp service to start on boot..."
sudo systemctl enable webapp

# 7. 
echo "Starting webapp service..."
sudo systemctl start webapp

# Wait a moment for service to start
sleep 3

# 8. 
echo ""
echo "Configuring nginx as reverse proxy..."

sudo tee /etc/nginx/sites-available/webapp > /dev/null <<'EOF'
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

# Remove default nginx site and enable webapp
sudo rm -f /etc/nginx/sites-enabled/default
sudo ln -sf /etc/nginx/sites-available/webapp /etc/nginx/sites-enabled/

# Test nginx configuration
echo "Testing nginx configuration..."
sudo nginx -t

if [ $? -eq 0 ]; then
    echo "✓ Nginx configuration is valid"
    sudo systemctl restart nginx
    echo "✓ Nginx restarted"
else
    echo "✗ Nginx configuration has errors"
    exit 1
fi

# Verification
echo ""
echo "========================================="
echo "Deployment completed!"
echo "========================================="
echo ""

# Check service status
echo "Service Status:"
sudo systemctl status webapp --no-pager -l

echo ""
echo "Verifications:"
echo "1. Service status: systemctl start webapp"
sudo systemctl is-active webapp

echo ""
echo "2. Service enabled on boot:"
sudo systemctl is-enabled webapp

echo ""
echo "3. Testing application endpoint:"
sleep 2
curl -s http://localhost | python3 -m json.tool

echo ""
echo "4. Checking logs (last 20 lines):"
sudo journalctl -u webapp -n 20 --no-pager

echo ""
echo "========================================="
echo "Verification Commands:"
echo "========================================="
echo "systemctl start webapp"
echo "systemctl status webapp"
echo "curl http://localhost"
echo "journalctl -u webapp -n 20"
echo ""
echo "Your Flask app is now running!"
echo "Access it at: http://your-server-ip"
echo ""

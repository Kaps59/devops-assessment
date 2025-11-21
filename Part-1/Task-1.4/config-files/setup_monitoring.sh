#!/bin/bash

# Task 1.4: System Monitoring
# This script sets up system monitoring with log rotation and cron job

echo "Starting system monitoring setup..."

# 1. Find and document system information
echo ""
echo "========================================="
echo "System Information Documentation"
echo "========================================="

# Current memory usage (free vs used)
echo ""
echo "1. Current Memory Usage:"
free -h

# Disk usage of /opt/webapp/
echo ""
echo "2. Disk Usage of /opt/webapp/:"
du -sh /opt/webapp/

# Number of running processes
echo ""
echo "3. Number of Running Processes:"
ps aux | wc -l

# Current system load
echo ""
echo "4. Current System Load:"
uptime

# Top 5 processes by memory usage
echo ""
echo "5. Top 5 Processes by Memory Usage:"
ps aux --sort=-%mem | head -n 6

# 2. Create monitoring script at /opt/webapp/monitor.sh
echo ""
echo "========================================="
echo "Creating monitoring script..."
echo "========================================="

sudo tee /opt/webapp/monitor.sh > /dev/null <<'EOF'
#!/bin/bash

# System Monitoring Script
# Runs every 5 minutes to check webapp service and nginx

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
LOG_FILE="/opt/webapp/logs/monitor.log"

echo "=========================================" >> "$LOG_FILE"
echo "Monitor Run: $TIMESTAMP" >> "$LOG_FILE"
echo "=========================================" >> "$LOG_FILE"

# Check if webapp service is running
echo "Checking webapp service..." >> "$LOG_FILE"
if systemctl is-active --quiet webapp; then
    echo "✓ webapp service is running" >> "$LOG_FILE"
else
    echo "✗ webapp service is NOT running" >> "$LOG_FILE"
    echo "Attempting to restart webapp service..." >> "$LOG_FILE"
    systemctl restart webapp
fi

# Check if nginx is responding on port 80
echo "Checking nginx on port 80..." >> "$LOG_FILE"
if curl -s -o /dev/null -w "%{http_code}" http://localhost:80 | grep -q "200"; then
    echo "✓ nginx is responding on port 80" >> "$LOG_FILE"
else
    echo "✗ nginx is NOT responding on port 80" >> "$LOG_FILE"
    echo "Attempting to restart nginx..." >> "$LOG_FILE"
    systemctl restart nginx
fi

# Log system metrics
echo "" >> "$LOG_FILE"
echo "System Metrics:" >> "$LOG_FILE"
echo "Memory Usage:" >> "$LOG_FILE"
free -h | grep Mem >> "$LOG_FILE"
echo "Disk Usage of /opt/webapp/:" >> "$LOG_FILE"
du -sh /opt/webapp/ >> "$LOG_FILE"
echo "System Load:" >> "$LOG_FILE"
uptime >> "$LOG_FILE"

echo "" >> "$LOG_FILE"
EOF

if [ $? -eq 0 ]; then
    echo "✓ Monitoring script created at /opt/webapp/monitor.sh"
else
    echo "✗ Failed to create monitoring script"
    exit 1
fi

# Make the script executable
sudo chmod +x /opt/webapp/monitor.sh
echo "✓ Monitoring script made executable"

# Set ownership
sudo chown webapp:webapp /opt/webapp/monitor.sh
echo "✓ Ownership set to webapp:webapp"

# Ensure log file exists with proper permissions
sudo touch /opt/webapp/logs/monitor.log
sudo chown webapp:webapp /opt/webapp/logs/monitor.log

# 3. Set up cron job to run every 5 minutes
echo ""
echo "========================================="
echo "Setting up cron job..."
echo "========================================="

# Add cron job for root user to run monitoring script every 5 minutes
(crontab -l 2>/dev/null | grep -v '/opt/webapp/monitor.sh'; echo "*/5 * * * * /opt/webapp/monitor.sh") | crontab -

if [ $? -eq 0 ]; then
    echo "✓ Cron job added to run every 5 minutes"
else
    echo "✗ Failed to add cron job"
    exit 1
fi

# Test the monitoring script once
echo ""
echo "Running monitoring script once for testing..."
sudo /opt/webapp/monitor.sh
echo "✓ Monitoring script executed"

# 4. Display verification information
echo ""
echo "========================================="
echo "Setup Complete!"
echo "========================================="
echo ""

# Show cron job
echo "Cron Job Configuration:"
crontab -l | grep monitor.sh

echo ""
echo "Monitoring script location:"
ls -lh /opt/webapp/monitor.sh

echo ""
echo "Monitor log location:"
ls -lh /opt/webapp/logs/monitor.log

echo ""
echo "========================================="
echo "Verification Commands:"
echo "========================================="
echo "1. Check cron job:"
echo "   crontab -l"
echo ""
echo "2. View monitoring log:"
echo "   cat /opt/webapp/logs/monitor.log"
echo ""
echo "3. Manually run monitoring script:"
echo "   sudo /opt/webapp/monitor.sh"
echo ""
echo "4. Check recent cron executions:"
echo "   grep CRON /var/log/syslog | tail -20"
echo ""

# Display current content of monitor.log
echo "Current monitor.log content:"
echo "========================================="
cat /opt/webapp/logs/monitor.log
echo ""

#!/bin/bash

# Task 1.2: Install Application Dependencies

echo "Starting application dependencies installation..."

# 1. 
echo "Updating package cache..."
sudo apt update

if [ $? -eq 0 ]; then
    echo "✓ Package cache updated successfully"
else
    echo "✗ Failed to update package cache"
    exit 1
fi

# 2. 
echo "Installing Python 3.10+, pip, nginx, and virtualenv..."
sudo apt install -y python3 python3-pip nginx python3-virtualenv

if [ $? -eq 0 ]; then
    echo "✓ All packages installed successfully"
else
    echo "✗ Failed to install packages"
    exit 1
fi

# 3. 
echo ""
echo "Verifying installed versions..."
echo "================================"

echo -n "Python version: "
python3 --version

echo -n "Pip version: "
pip3 --version

echo -n "Nginx version: "
nginx -v 2>&1

echo -n "Virtualenv location: "
which virtualenv

# 4. 
echo ""
echo "Creating Python virtual environment..."

# Create venv directory as root first
sudo mkdir -p /opt/webapp/venv

# Create virtual environment
sudo python3 -m virtualenv /opt/webapp/venv

if [ $? -eq 0 ]; then
    echo "✓ Virtual environment created at /opt/webapp/venv/"
else
    echo "✗ Failed to create virtual environment"
    exit 1
fi

# 5. 
echo "Setting ownership to webapp user..."
sudo chown -R webapp:webapp /opt/webapp/venv

if [ $? -eq 0 ]; then
    echo "✓ Ownership set to webapp:webapp"
else
    echo "✗ Failed to set ownership"
    exit 1
fi

# 6. 
echo ""
echo "Verifying virtual environment setup..."
echo "======================================"
ls -la /opt/webapp/venv/

# Display final verification commands
echo ""
echo "========================================="
echo "Installation completed successfully!"
echo "========================================="
echo ""
echo "Run these commands to verify:"
echo "  python3 --version"
echo "  pip3 --version"
echo "  which virtualenv"
echo "  ls -la /opt/webapp/venv/"
echo ""
echo "To activate the virtual environment as webapp user:"
echo "  sudo -u webapp bash"
echo "  source /opt/webapp/venv/bin/activate"
echo ""

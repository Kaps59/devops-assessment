
echo "Starting Python Flask application setup..."

# 1. Create service user 'webapp' without login shell

echo "Creating service user 'webapp'..."
sudo useradd -r -s /sbin/nologin webapp

# Verify user creation

if id "webapp" &>/dev/null; then
    echo "User 'webapp' created successfully"
else
    echo "Failed to create user 'webapp'"
    exit 1
fi


# 2. Create directory structure
echo "Creating directory structure..."
sudo mkdir -p /opt/webapp/app
sudo mkdir -p /opt/webapp/logs
sudo mkdir -p /var/log/webapp

# Verify directories
for dir in /opt/webapp /opt/webapp/app /opt/webapp/logs /var/log/webapp; do
    if [ -d "$dir" ]; then
        echo "✓ Directory $dir created"
    else
        echo "✗ Failed to create $dir"
        exit 1
    fi
done

# 3. Set proper ownership and permissions
echo "Setting ownership and permissions..."


sudo chown webapp:webapp /opt/webapp/app
sudo chmod 755 /opt/webapp/app


sudo chmod 755 /opt/webapp/logs
sudo chmod 755 /var/log/webapp


sudo chown -R webapp:webapp /opt/webapp


sudo chown webapp:webapp /var/log/webapp

# 4. 
echo "Creating symbolic link..."
sudo ln -s /var/log/webapp/ /opt/webapp/logs


if [ -L "/opt/webapp/logs" ]; then
    echo " Symbolic link created successfully"
    echo "  /opt/webapp/logs -> $(readlink /opt/webapp/logs)"
else
    echo "Failed to create symbolic link "
    exit 1
fi

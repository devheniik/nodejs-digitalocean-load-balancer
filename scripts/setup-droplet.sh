#!/bin/bash

# Update system
apt-get update
apt-get upgrade -y

# Install Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
apt-get install -y nodejs

# Install PM2 for process management
npm install -g pm2

# Install git
apt-get install -y git

# Create app user
useradd -m -s /bin/bash nodeapp
usermod -aG sudo nodeapp

# Create app directory
mkdir -p /opt/app
chown nodeapp:nodeapp /opt/app

# Switch to app user and setup application
sudo -u nodeapp bash << 'EOF'
cd /opt/app
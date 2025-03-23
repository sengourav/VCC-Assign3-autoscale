#!/bin/bash

# Script to set up the local Lubuntu VM for auto-scaling project and installing GCP SDK

# Exit on error
set -e

# Update package lists
echo "Updating package lists..."
sudo apt update

# Install essential packages
echo "Installing essential packages..."
sudo apt install -y curl wget htop python3 python3-pip openssh-server net-tools

# Enable SSH for remote access
echo "Configuring SSH server..."
sudo systemctl enable ssh
sudo systemctl start ssh

# Set up firewall to allow SSH and web traffic
echo "Configuring firewall..."
sudo apt install -y ufw
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw --force enable

# Configure hostname
echo "Setting hostname..."
sudo hostnamectl set-hostname lubuntu-vm

# Create project directory
echo "Creating project directory..."
mkdir -p ~/vcc-autoscale-project
cd ~/vcc-autoscale-project

# Install Google Cloud SDK
echo "Installing Google Cloud SDK dependencies..."
sudo apt install -y apt-transport-https ca-certificates gnupg

echo "Adding Google Cloud SDK repository..."
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

echo "Adding Google Cloud SDK key..."
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

echo "Installing Google Cloud SDK..."
sudo apt update && sudo apt install -y google-cloud-sdk

# Display IP address
echo "Local VM setup complete!"
echo "Your VM IP address is: $(hostname -I | awk '{print $1}')"
echo "Make sure to authenticate with GCP using your service account key."
echo "Run: gcloud auth activate-service-account --key-file=PATH_TO_KEY.json"

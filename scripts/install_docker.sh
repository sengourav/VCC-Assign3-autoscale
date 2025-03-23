#!/bin/bash

# Update package index
echo "Updating package index..."
sudo apt update

# Install required dependencies
echo "Installing required dependencies..."
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common gnupg lsb-release

# Add Docker's official GPG key
echo "Adding Docker's official GPG key..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo "Adding Docker repository..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package index again
echo "Updating package index with Docker repository..."
sudo apt update

# Install Docker Engine
echo "Installing Docker Engine..."
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add current user to Docker group
echo "Adding current user to Docker group..."
sudo usermod -aG docker $USER

# Enable Docker service
echo "Enabling Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

# Test Docker installation
echo "Testing Docker installation..."
docker --version

echo "========== Docker Installation Complete =========="


# Create Docker network for our application
echo "Creating Docker network 'my-network'..."
docker network create my-network || echo "Network might already exist, continuing..."

echo "Docker has been successfully installed on your Lubuntu VM!"

#!/bin/bash

# Docker Installation Script for Raspberry Pi OS
# Installs Docker and Docker Compose on a fresh Raspberry Pi OS installation

set -e

DOCKER_COMPOSE_VERSION="2.24.5"
SCRIPT_USER=$(whoami)

echo "======================================"
echo "Docker Installation for Raspberry Pi"
echo "======================================"
echo ""
echo "This script will install:"
echo "  - Docker Engine"
echo "  - Docker Compose"
echo ""
echo "Current user: ${SCRIPT_USER}"
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo "ERROR: Do not run this script as root or with sudo"
    echo "The script will prompt for sudo when needed"
    exit 1
fi

# Update package list
echo "[1/6] Updating package list..."
sudo apt-get update

# Install prerequisites
echo "[2/6] Installing prerequisites..."
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker GPG key
echo "[3/6] Adding Docker GPG key..."
sudo install -m 0755 -d /etc/apt/keyrings
if [ -f /etc/apt/keyrings/docker.gpg ]; then
    sudo rm /etc/apt/keyrings/docker.gpg
fi
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo "[4/6] Adding Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package list again
sudo apt-get update

# Install Docker Engine
echo "[5/6] Installing Docker Engine..."
sudo apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

# Add current user to docker group
echo "[6/6] Adding user ${SCRIPT_USER} to docker group..."
sudo usermod -aG docker ${SCRIPT_USER}

# Enable Docker service
echo "Enabling Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

# Verify installation
echo ""
echo "======================================"
echo "Installation Complete"
echo "======================================"
echo ""

# Check Docker version
DOCKER_VERSION=$(docker --version)
COMPOSE_VERSION=$(docker compose version)

echo "Installed versions:"
echo "  ${DOCKER_VERSION}"
echo "  ${COMPOSE_VERSION}"
echo ""
echo "IMPORTANT: You must log out and log back in for group changes to take effect"
echo ""
echo "After logging back in, verify Docker works by running:"
echo "  docker run hello-world"
echo ""
echo "======================================"

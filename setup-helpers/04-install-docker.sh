#!/bin/bash
# =============================================================================
# Docker Installation Script - Debian
# =============================================================================
# Installs Docker Engine and Docker Compose
# =============================================================================

set -e

echo "🐳 Installing Docker..."

# Check if Docker is already installed
if command -v docker >/dev/null 2>&1; then
    echo "✓ Docker is already installed: $(docker --version)"
    exit 0
fi

# Update package lists
echo "📦 Updating package lists..."
sudo apt update

# Install prerequisites
echo "📥 Installing prerequisites..."
sudo apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
echo "🔑 Adding Docker GPG key..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Set up Docker repository
echo "📝 Setting up Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package lists with Docker repo
echo "🔄 Updating package lists..."
sudo apt update

# Install Docker Engine
echo "📥 Installing Docker Engine..."
sudo apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

# Add current user to docker group
echo "👥 Adding user to docker group..."
sudo usermod -aG docker $USER

# Enable Docker service
echo "🔄 Enabling Docker service..."
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
sudo systemctl start docker.service

# Verify installation
echo ""
echo "✅ Docker installation complete!"
echo ""
echo "Installed versions:"
docker --version
docker compose version

echo ""
echo "⚠️  IMPORTANT: You need to log out and log back in for docker group membership to take effect"
echo "   Or run: newgrp docker"
echo ""

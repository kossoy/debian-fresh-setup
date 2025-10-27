#!/bin/bash
# =============================================================================
# Essential Packages Installation Script - Debian 13
# =============================================================================
# Installs essential packages using apt package manager
# =============================================================================

set -e

echo "📦 Installing Essential Packages..."

# Check if we're on a Debian-based system
if ! command -v apt >/dev/null 2>&1; then
    echo "❌ This script requires apt package manager (Debian/Ubuntu)"
    exit 1
fi

# Update package lists
echo "🔄 Updating package lists..."
sudo apt update

# Install essential development tools
echo "📥 Installing essential development tools..."
sudo apt install -y \
    build-essential \
    git \
    wget \
    curl \
    tree \
    jq \
    bat \
    fd-find \
    ripgrep \
    htop \
    zsh \
    vim \
    nano \
    unzip \
    zip \
    ca-certificates \
    gnupg \
    lsb-release

# Install optional packages (may not be available in all Debian versions)
echo "📥 Installing optional packages..."
for pkg in neovim btop tldr fastfetch; do
    if apt-cache show "$pkg" >/dev/null 2>&1; then
        sudo apt install -y "$pkg" || echo "⚠️  Failed to install $pkg, skipping..."
    else
        echo "⚠️  Package $pkg not available in repositories, skipping..."
    fi
done

# Install GitHub CLI
echo "📥 Installing GitHub CLI..."
if ! command -v gh >/dev/null 2>&1; then
    sudo mkdir -p -m 755 /etc/apt/keyrings
    wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
    sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt update
    sudo apt install -y gh
fi

# Install eza (modern ls replacement)
echo "📥 Installing eza..."
if ! command -v eza >/dev/null 2>&1; then
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    sudo apt update
    sudo apt install -y eza
fi

# Create symlinks for Debian-specific commands
echo "🔗 Creating convenience symlinks..."
# fd-find is named 'fdfind' on Debian
if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
    sudo ln -s $(which fdfind) /usr/local/bin/fd
fi

# bat is named 'batcat' on Debian
if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
    sudo ln -s $(which batcat) /usr/local/bin/bat
fi

echo "✅ Essential packages installation complete"

# Display installed versions
echo ""
echo "📋 Installed versions:"
echo "  Git:        $(git --version | head -n1)"
echo "  Zsh:        $(zsh --version)"
echo "  Curl:       $(curl --version | head -n1)"
echo "  jq:         $(jq --version)"
echo "  ripgrep:    $(rg --version | head -n1)"
if command -v eza >/dev/null 2>&1; then
    echo "  eza:        $(eza --version | head -n1)"
fi
if command -v gh >/dev/null 2>&1; then
    echo "  gh:         $(gh --version | head -n1)"
fi

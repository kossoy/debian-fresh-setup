#!/bin/bash
# Simple Debian Fresh Setup - Just copy working files
# No overcomplicated package structure, no templates, just works

set -e

echo "🐧 Simple Debian Fresh Setup"
echo "============================"
echo ""

# Check if running on Linux
if [[ "$(uname -s)" != "Linux" ]]; then
    echo "❌ This script is for Linux only"
    echo ""
    echo "For macOS, please use: https://github.com/kossoy/macos-fresh-setup"
    exit 1
fi

# Detect Linux distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
    DISTRO_LIKE=${ID_LIKE:-$ID}
else
    DISTRO="unknown"
    DISTRO_LIKE="unknown"
fi

# Check if Debian/Ubuntu-based
if ! command -v apt >/dev/null 2>&1; then
    echo "❌ This script requires apt package manager (Debian/Ubuntu)"
    echo ""
    echo "Detected distribution: $DISTRO"
    echo ""
    echo "This script is designed for Debian-based distributions:"
    echo "  • Debian (all versions)"
    echo "  • Ubuntu (and derivatives)"
    echo "  • Linux Mint"
    echo "  • Pop!_OS"
    echo "  • elementary OS"
    echo ""
    echo "For other distributions, please adapt the package installation commands."
    exit 1
fi

# Show detected distribution
echo "✅ Detected: $DISTRO"
if [[ "$DISTRO_LIKE" == *"debian"* ]] || [[ "$DISTRO" == "debian" ]] || [[ "$DISTRO" == "ubuntu" ]]; then
    echo "✅ Debian-based distribution confirmed"
else
    echo "⚠️  Warning: This may not be a Debian-based distribution"
    echo "   Detected: $DISTRO (like: $DISTRO_LIKE)"
    read -p "Continue anyway? (y/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi
echo ""

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "📦 Updating package lists..."
sudo apt update

echo "📦 Installing essential packages..."
sudo apt install -y \
    git \
    wget \
    curl \
    tree \
    jq \
    bat \
    fd-find \
    ripgrep \
    build-essential \
    zsh \
    vim \
    tmux \
    htop \
    ncdu \
    unzip \
    zip \
    p7zip-full

# Install optional packages (may not be available in all Debian versions)
echo "📦 Installing optional packages..."
for pkg in neovim btop fastfetch; do
    if apt-cache show "$pkg" >/dev/null 2>&1; then
        if sudo apt install -y "$pkg" 2>&1 | grep -q "has no installation candidate\|is not available"; then
            echo "⚠️  Package $pkg not available, skipping..."
        fi
    else
        echo "⚠️  Package $pkg not available in repositories, skipping..."
    fi
done

# Install tealdeer (tldr replacement) - available in Bookworm and Trixie
echo "📦 Installing tealdeer (tldr pages client)..."
if apt-cache show tealdeer >/dev/null 2>&1; then
    sudo apt install -y tealdeer || echo "⚠️  Failed to install tealdeer, skipping..."
else
    echo "⚠️  Package tealdeer not available, skipping..."
fi

echo "📦 Installing GitHub CLI..."
if ! command -v gh >/dev/null 2>&1; then
    sudo mkdir -p -m 755 /etc/apt/keyrings
    wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
    sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt update
    sudo apt install -y gh
fi

echo "🐳 Installing Docker..."
if ! command -v docker >/dev/null 2>&1; then
    # Install prerequisites
    sudo apt install -y ca-certificates curl gnupg lsb-release

    # Add Docker's official GPG key
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    # Set up Docker repository
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Install Docker
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Add user to docker group
    sudo usermod -aG docker "$(whoami)"

    # Enable and start Docker (skip if systemd not available, e.g., in Docker containers)
    if systemctl --version >/dev/null 2>&1 && [ -d /run/systemd/system ]; then
        sudo systemctl enable docker.service
        sudo systemctl enable containerd.service
        sudo systemctl start docker.service

        # Test Docker
        if sudo docker ps >/dev/null 2>&1; then
            echo "✅ Docker installed and working: $(docker --version)"
        else
            echo "❌ Docker installed but test failed"
        fi
    else
        echo "⚠️  Systemd not available (e.g., running in container), skipping service management"
        echo "✅ Docker installed: $(docker --version)"
    fi
else
    echo "✅ Docker already installed"
fi

# Install eza if not installed
if ! command -v eza >/dev/null 2>&1; then
    echo "📦 Installing eza..."
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

# Verify zsh is installed before proceeding
if ! command -v zsh >/dev/null 2>&1; then
    echo "❌ Zsh installation failed. Please install zsh manually."
    exit 1
fi

echo "🐚 Installing Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

echo "🔌 Installing Oh My Zsh plugins..."
# Set ZSH_CUSTOM if not set
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "  Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
    echo "  ✓ zsh-autosuggestions already installed"
fi

# zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    echo "  Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
    echo "  ✓ zsh-syntax-highlighting already installed"
fi

# powerlevel10k theme
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    echo "  Installing powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
else
    echo "  ✓ powerlevel10k already installed"
fi

echo "📁 Creating zsh config directory..."
mkdir -p ~/.zsh/{config,private}

echo "📋 Copying your working configuration..."
# Copy your actual working files
cp "$SCRIPT_DIR/config/zsh/config/aliases.zsh" ~/.zsh/config/aliases.zsh
cp "$SCRIPT_DIR/config/zsh/config/functions.zsh" ~/.zsh/config/functions.zsh
cp "$SCRIPT_DIR/config/zsh/config/paths.zsh" ~/.zsh/config/paths.zsh
cp "$SCRIPT_DIR/config/zsh/config/tools.zsh" ~/.zsh/config/tools.zsh
cp "$SCRIPT_DIR/config/zsh/config/context.zsh" ~/.zsh/config/context.zsh

# Create simple .zshrc that sources your files
cat > ~/.zshrc << 'ZSHRC'
# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting virtualenv pip python docker systemd)
source $ZSH/oh-my-zsh.sh

# Your custom config
ZSH_CONFIG_DIR="$HOME/.zsh/config"
source "$ZSH_CONFIG_DIR/paths.zsh"
source "$ZSH_CONFIG_DIR/aliases.zsh"
source "$ZSH_CONFIG_DIR/functions.zsh"
source "$ZSH_CONFIG_DIR/tools.zsh"
source "$ZSH_CONFIG_DIR/context.zsh"
ZSHRC

echo "🎨 Copying Powerlevel10k config..."
if [ -f "$SCRIPT_DIR/config/p10k.zsh" ]; then
    cp "$SCRIPT_DIR/config/p10k.zsh" ~/.p10k.zsh
fi

echo "📁 Creating work directory..."
mkdir -p ~/work/{databases,tools,projects/{work,personal},configs/{work,personal},scripts,docs,bin}

echo "📜 Copying utility scripts..."
cp "$SCRIPT_DIR/scripts/"*.sh ~/work/scripts/ 2>/dev/null || true
cp "$SCRIPT_DIR/scripts/"*.zsh ~/work/scripts/ 2>/dev/null || true
chmod +x ~/work/scripts/*.sh ~/work/scripts/*.zsh 2>/dev/null || true

echo ""
echo "✅ Setup complete!"
echo ""

# Offer to set zsh as default shell
CURRENT_SHELL=$(basename "$SHELL")
if [ "$CURRENT_SHELL" != "zsh" ]; then
    echo "📝 Your current shell is: $CURRENT_SHELL"
    echo "Would you like to set zsh as your default shell?"
    read -p "Set zsh as default? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        chsh -s $(which zsh)
        echo "✅ Default shell set to zsh"
        echo "⚠️  Please logout and login again (or reboot) for changes to take effect"
    else
        echo "⏭️  Skipped. You can set it later with: chsh -s $(which zsh)"
    fi
else
    echo "✅ Zsh is already your default shell"
fi

echo ""
echo "✅ Installation complete!"
echo ""
echo "⚠️  CRITICAL - Docker group requires session restart:"
echo ""
echo "Option 1 (Recommended):"
echo "  1. Log out and log back in"
echo "  2. Run: source ~/.zshrc"
echo "  3. Test: docker ps"
echo ""
echo "Option 2 (Quick test):"
echo "  1. Run: newgrp docker"
echo "  2. Run: source ~/.zshrc"
echo "  3. Test: docker ps"
echo ""
echo "Option 3 (Use sudo for now):"
echo "  sudo docker ps"
echo ""
echo "Test context switching: work, personal, show-context"
echo ""

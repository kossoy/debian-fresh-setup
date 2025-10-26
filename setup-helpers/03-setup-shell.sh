#!/bin/bash
# =============================================================================
# Shell Configuration Setup Script - Debian 13
# =============================================================================
# Sets up zsh configuration with user-provided values
# =============================================================================

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$(dirname "$SCRIPT_DIR")"

echo "⚙️  Setting up shell configuration..."

# Create zsh configuration directory structure
echo "📁 Creating configuration directories..."
mkdir -p ~/.zsh/{config,plugins,themes,private}

# Copy configuration files
echo "📋 Copying configuration files..."
cp "$PACKAGE_DIR/config/zsh/config/paths.zsh" ~/.zsh/config/paths.zsh
cp "$PACKAGE_DIR/config/zsh/config/aliases.zsh" ~/.zsh/config/aliases.zsh
cp "$PACKAGE_DIR/config/zsh/config/functions.zsh" ~/.zsh/config/functions.zsh
cp "$PACKAGE_DIR/config/zsh/config/tools.zsh" ~/.zsh/config/tools.zsh

# Backup existing .zshrc if it exists
if [[ -f ~/.zshrc ]]; then
    echo "📋 Backing up existing .zshrc to .zshrc.backup"
    cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)
fi

# Create main zshrc
echo "📝 Creating .zshrc..."
cat > ~/.zshrc << 'ZSHRC_CONTENT'
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

# Load context if exists
if [ -f "$HOME/.zsh/private/current.zsh" ]; then
    source "$HOME/.zsh/private/current.zsh"
fi

# Load p10k configuration
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
ZSHRC_CONTENT

# Copy Powerlevel10k configuration if it exists
if [[ -f "$PACKAGE_DIR/config/p10k.zsh" ]]; then
    echo "🎨 Installing Powerlevel10k configuration..."
    cp "$PACKAGE_DIR/config/p10k.zsh" ~/.p10k.zsh
fi

# Create work directory structure
echo "📁 Creating work directory structure..."
mkdir -p ~/work/{databases,tools,projects/{work,personal},configs/{work,personal},scripts,docs,bin}

# Copy utility scripts if they exist
if [[ -d "$PACKAGE_DIR/scripts" ]]; then
    echo "📜 Copying utility scripts..."
    cp "$PACKAGE_DIR/scripts"/*.sh ~/work/scripts/ 2>/dev/null || true
    cp "$PACKAGE_DIR/scripts"/*.zsh ~/work/scripts/ 2>/dev/null || true
    chmod +x ~/work/scripts/*.sh ~/work/scripts/*.zsh 2>/dev/null || true
fi

echo "✅ Shell configuration setup complete"
echo ""
echo "📋 Next steps:"
echo "1. Set zsh as your default shell: chsh -s \$(which zsh)"
echo "2. Restart your terminal or run: source ~/.zshrc"
echo "3. Configure your Git settings:"
echo "   git config --global user.name 'Your Name'"
echo "   git config --global user.email 'your.email@example.com'"

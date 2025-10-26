#!/bin/bash
# =============================================================================
# Git Configuration and SSH Key Setup Script
# =============================================================================
# Interactive script to configure Git and generate SSH keys
# =============================================================================

set -e

echo "🔧 Git and SSH Configuration"
echo "============================="
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if git is installed
if ! command_exists git; then
    echo "❌ Git is not installed. Please run 01-install-packages.sh first."
    exit 1
fi

# =============================================================================
# Git Configuration
# =============================================================================

echo "📝 Git Configuration"
echo "-------------------"
echo ""

# Check if git user name is already configured
CURRENT_NAME=$(git config --global user.name 2>/dev/null || echo "")
CURRENT_EMAIL=$(git config --global user.email 2>/dev/null || echo "")

if [[ -n "$CURRENT_NAME" ]] && [[ -n "$CURRENT_EMAIL" ]]; then
    echo "Current Git configuration:"
    echo "  Name:  $CURRENT_NAME"
    echo "  Email: $CURRENT_EMAIL"
    echo ""
    read -p "Do you want to reconfigure? (y/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "⏭️  Skipping Git configuration"
        GIT_CONFIGURED=true
    fi
fi

if [[ "$GIT_CONFIGURED" != "true" ]]; then
    echo "Enter your Git information:"
    read -p "Your name: " GIT_NAME
    read -p "Your email: " GIT_EMAIL

    git config --global user.name "$GIT_NAME"
    git config --global user.email "$GIT_EMAIL"

    # Set other recommended settings
    git config --global init.defaultBranch main
    git config --global color.ui auto
    git config --global pull.rebase true
    git config --global fetch.prune true
    git config --global merge.conflictstyle diff3

    echo ""
    echo "✅ Git configured:"
    echo "  Name:  $GIT_NAME"
    echo "  Email: $GIT_EMAIL"
fi

echo ""

# =============================================================================
# Global Gitignore
# =============================================================================

echo "📋 Global Gitignore"
echo "------------------"
echo ""

if [[ -f ~/.gitignore_global ]]; then
    echo "✓ Global gitignore already exists: ~/.gitignore_global"
else
    echo "Creating global gitignore..."
    cat > ~/.gitignore_global << 'GITIGNORE'
# OS Files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
Thumbs.db
Desktop.ini

# Editor files
.vscode/
.idea/
*.swp
*.swo
*~
.project
.classpath
.settings/

# Environment files
.env
.env.local
.env.*.local
*.env

# Build outputs
node_modules/
dist/
build/
*.pyc
__pycache__/
.pytest_cache/
.coverage
.venv/
venv/
*.egg-info/

# Logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Temporary files
tmp/
temp/
*.tmp
GITIGNORE

    git config --global core.excludesfile ~/.gitignore_global
    echo "✅ Global gitignore created and configured"
fi

echo ""

# =============================================================================
# Git Aliases
# =============================================================================

echo "🔗 Git Aliases"
echo "-------------"
echo ""

read -p "Install useful git aliases? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    git config --global alias.st status
    git config --global alias.s "status -s"
    git config --global alias.br branch
    git config --global alias.co checkout
    git config --global alias.cob "checkout -b"
    git config --global alias.ci commit
    git config --global alias.ca "commit --amend"
    git config --global alias.can "commit --amend --no-edit"
    git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
    git config --global alias.last "log -1 HEAD --stat"
    git config --global alias.ll "log --oneline -10"
    git config --global alias.df diff
    git config --global alias.dc "diff --cached"
    git config --global alias.unstage "reset HEAD --"
    git config --global alias.undo "reset --soft HEAD^"
    git config --global alias.aliases "config --get-regexp ^alias\."

    echo "✅ Git aliases installed"
    echo "  Try: git st, git lg, git cob feature-name"
else
    echo "⏭️  Skipped git aliases"
fi

echo ""

# =============================================================================
# SSH Key Setup
# =============================================================================

echo "🔐 SSH Key Setup"
echo "---------------"
echo ""

# Check if SSH keys already exist
if [[ -f ~/.ssh/id_ed25519 ]] || [[ -f ~/.ssh/id_rsa ]]; then
    echo "Existing SSH keys found:"
    ls -1 ~/.ssh/id_* 2>/dev/null | grep -v ".pub" || true
    echo ""
    read -p "Do you want to generate a new SSH key? (y/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "⏭️  Skipping SSH key generation"
        SSH_SKIP=true
    fi
fi

if [[ "$SSH_SKIP" != "true" ]]; then
    echo "Choose SSH key type:"
    echo "1) Ed25519 (recommended, faster, more secure)"
    echo "2) RSA 4096 (for compatibility with older systems)"
    echo ""
    read -p "Enter choice (1-2): " KEY_TYPE_CHOICE

    # Get email for key comment
    if [[ -n "$GIT_EMAIL" ]]; then
        KEY_EMAIL="$GIT_EMAIL"
    else
        read -p "Enter email for SSH key comment: " KEY_EMAIL
    fi

    # Get key name
    echo ""
    echo "Choose key purpose:"
    echo "1) Default (id_ed25519 or id_rsa)"
    echo "2) Personal (id_ed25519_personal)"
    echo "3) Work (id_ed25519_work)"
    echo "4) Custom name"
    echo ""
    read -p "Enter choice (1-4): " KEY_PURPOSE

    case $KEY_PURPOSE in
        1)
            if [[ "$KEY_TYPE_CHOICE" == "1" ]]; then
                KEY_FILE=~/.ssh/id_ed25519
            else
                KEY_FILE=~/.ssh/id_rsa
            fi
            ;;
        2)
            KEY_FILE=~/.ssh/id_ed25519_personal
            ;;
        3)
            KEY_FILE=~/.ssh/id_ed25519_work
            ;;
        4)
            read -p "Enter custom key name (without path): " CUSTOM_NAME
            KEY_FILE=~/.ssh/$CUSTOM_NAME
            ;;
        *)
            echo "❌ Invalid choice"
            exit 1
            ;;
    esac

    # Generate key
    echo ""
    echo "Generating SSH key..."
    echo "Key file: $KEY_FILE"
    echo ""

    if [[ "$KEY_TYPE_CHOICE" == "1" ]]; then
        ssh-keygen -t ed25519 -C "$KEY_EMAIL" -f "$KEY_FILE"
    else
        ssh-keygen -t rsa -b 4096 -C "$KEY_EMAIL" -f "$KEY_FILE"
    fi

    # Add to ssh-agent
    echo ""
    echo "Adding key to ssh-agent..."
    eval "$(ssh-agent -s)"
    ssh-add "$KEY_FILE"

    echo ""
    echo "✅ SSH key generated: $KEY_FILE"
    echo ""
    echo "📋 Your public key:"
    echo "-------------------"
    cat "${KEY_FILE}.pub"
    echo "-------------------"
    echo ""
    echo "📝 Next steps:"
    echo "1. Copy the public key above"
    echo "2. Go to GitHub → Settings → SSH and GPG keys"
    echo "3. Click 'New SSH key'"
    echo "4. Paste your public key and save"
    echo ""

    # Offer to copy to clipboard if xclip is available
    if command_exists xclip; then
        read -p "Copy public key to clipboard? (y/n): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cat "${KEY_FILE}.pub" | xclip -selection clipboard
            echo "✅ Public key copied to clipboard!"
        fi
    fi
fi

echo ""

# =============================================================================
# GitHub CLI Setup
# =============================================================================

if command_exists gh; then
    echo "🔐 GitHub CLI Authentication"
    echo "---------------------------"
    echo ""

    # Check if already authenticated
    if gh auth status >/dev/null 2>&1; then
        echo "✓ Already authenticated with GitHub CLI"
        gh auth status
    else
        echo "GitHub CLI is installed but not authenticated."
        read -p "Authenticate now? (y/n): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            gh auth login
            echo ""
            echo "✅ GitHub CLI authenticated"
        else
            echo "⏭️  Skipped. You can authenticate later with: gh auth login"
        fi
    fi
    echo ""
fi

# =============================================================================
# SSH Config for Multiple Keys
# =============================================================================

echo "🔧 SSH Config for Multiple Keys"
echo "-------------------------------"
echo ""

if [[ -f ~/.ssh/config ]]; then
    echo "✓ SSH config already exists: ~/.ssh/config"
    echo ""
    read -p "View current SSH config? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cat ~/.ssh/config
    fi
else
    read -p "Create SSH config for multiple keys? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cat > ~/.ssh/config << 'SSHCONFIG'
# Personal GitHub
Host github.com-personal
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_personal
    IdentitiesOnly yes

# Work GitHub
Host github.com-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_work
    IdentitiesOnly yes

# Default GitHub (uses default key)
Host github.com
    HostName github.com
    User git
    IdentitiesOnly yes
SSHCONFIG

        chmod 600 ~/.ssh/config
        echo "✅ SSH config created: ~/.ssh/config"
        echo ""
        echo "📝 Usage:"
        echo "  Personal: git clone git@github.com-personal:user/repo.git"
        echo "  Work:     git clone git@github.com-work:company/repo.git"
    else
        echo "⏭️  Skipped SSH config"
    fi
fi

echo ""

# =============================================================================
# Summary
# =============================================================================

echo "✅ Git and SSH Setup Complete!"
echo "=============================="
echo ""
echo "📋 What was configured:"
echo "  ✓ Git user name and email"
echo "  ✓ Global gitignore"
echo "  ✓ Recommended git settings"

if [[ "$SSH_SKIP" != "true" ]] && [[ -n "$KEY_FILE" ]]; then
    echo "  ✓ SSH key: $KEY_FILE"
fi

if command_exists gh && gh auth status >/dev/null 2>&1; then
    echo "  ✓ GitHub CLI authenticated"
fi

echo ""
echo "📝 Useful commands:"
echo "  git config --list          - View all git settings"
echo "  git aliases                - View all git aliases"
echo "  ssh-add -l                 - List loaded SSH keys"
echo "  gh auth status             - Check GitHub CLI auth status"
echo ""

# Test SSH connection if key was generated
if [[ "$SSH_SKIP" != "true" ]] && [[ -n "$KEY_FILE" ]]; then
    echo "🔍 Testing SSH connection to GitHub..."
    if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
        echo "✅ SSH connection to GitHub successful!"
    else
        echo "⚠️  SSH connection test failed or key not yet added to GitHub"
        echo "   Add your public key to GitHub and try: ssh -T git@github.com"
    fi
fi

echo ""

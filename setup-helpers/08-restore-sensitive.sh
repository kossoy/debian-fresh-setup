#!/bin/bash
# =============================================================================
# Sensitive Files Restoration Helper - Debian 13
# =============================================================================
# Interactive script to help locate and restore sensitive files from backups
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔍 Sensitive Files Restoration Helper${NC}"
echo "====================================="
echo ""

# Function to check if file exists and is readable
check_file() {
    local file="$1"
    if [[ -f "$file" && -r "$file" ]]; then
        echo -e "${GREEN}✅ Found: $file${NC}"
        return 0
    else
        echo -e "${RED}❌ Not found: $file${NC}"
        return 1
    fi
}

# Function to restore file with confirmation
restore_file() {
    local source="$1"
    local destination="$2"
    local description="$3"

    if check_file "$source"; then
        echo -e "${BLUE}📋 $description${NC}"
        echo "   Source: $source"
        echo "   Destination: $destination"
        echo ""
        read -p "Copy this file? (y/n): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            mkdir -p "$(dirname "$destination")"
            cp "$source" "$destination"
            chmod 600 "$destination"
            echo -e "${GREEN}✅ Copied successfully${NC}"
            return 0
        fi
    fi
    return 1
}

echo -e "${BLUE}🔑 Looking for API keys...${NC}"

# Check common backup locations for API keys
API_KEY_LOCATIONS=(
    "$HOME/.zsh/private/api-keys.zsh"
    "/mnt/backups/zsh-config/api-keys.zsh"
    "$HOME/Backups/zsh-config/api-keys.zsh"
)

# Check for tar.gz backups separately (need glob expansion)
if ls "$HOME/work/backups/zsh-complete-environment-"*.tar.gz >/dev/null 2>&1; then
    for backup_file in "$HOME/work/backups/zsh-complete-environment-"*.tar.gz; do
        if [[ -f "$backup_file" ]]; then
            echo -e "${YELLOW}📦 Found backup archive: $backup_file${NC}"
            echo "   Extract with: tar -xzf '$backup_file' -C /tmp/ && find /tmp -name 'api-keys.zsh'"
        fi
    done
fi

# Check mounted external drives
if [[ -d "/media/$USER" ]]; then
    for drive in /media/$USER/*; do
        if [[ -d "$drive" ]]; then
            API_KEY_LOCATIONS+=(
                "$drive/Backups/zsh-config/api-keys.zsh"
                "$drive/backups/zsh-config/api-keys.zsh"
                "$drive/linux-backups/zsh-config/api-keys.zsh"
                "$drive/mac-config/api-keys.zsh"
            )
        fi
    done
fi

# Check /mnt for NAS mounts
if [[ -d "/mnt" ]]; then
    for nas in /mnt/*; do
        if [[ -d "$nas" ]] && [[ "$nas" != "/mnt/wslg" ]]; then
            API_KEY_LOCATIONS+=(
                "$nas/backups/zsh-config/api-keys.zsh"
                "$nas/linux-backups/zsh-config/api-keys.zsh"
            )
        fi
    done
fi

echo "🔍 Checking for API keys in common locations..."
FOUND_ANY=false
for location in "${API_KEY_LOCATIONS[@]}"; do
    if restore_file "$location" "$HOME/.zsh/private/api-keys.zsh" "API Keys"; then
        FOUND_ANY=true
        break
    fi
done

if [[ "$FOUND_ANY" == "false" ]]; then
    echo -e "${YELLOW}⚠️  No API key backups found in common locations${NC}"
fi

echo ""
echo -e "${BLUE}🔐 Looking for SSH keys...${NC}"

# Check for existing SSH keys
SSH_KEYS=(
    "$HOME/.ssh/id_ed25519"
    "$HOME/.ssh/id_rsa"
    "$HOME/.ssh/id_ed25519.pub"
    "$HOME/.ssh/id_rsa.pub"
)

echo "🔍 Checking for existing SSH keys..."
SSH_FOUND=false
for key in "${SSH_KEYS[@]}"; do
    if check_file "$key"; then
        SSH_FOUND=true
    fi
done

if [[ "$SSH_FOUND" == "false" ]]; then
    echo -e "${YELLOW}⚠️  No SSH keys found${NC}"
    echo ""
    echo "Would you like to:"
    echo "  1. Generate new SSH keys"
    echo "  2. Restore from backup (manual)"
    echo "  3. Skip"
    echo ""
    read -p "Choose option (1-3): " -n 1 -r
    echo ""

    case $REPLY in
        1)
            echo ""
            echo -e "${BLUE}Generating new SSH keys...${NC}"
            read -p "Enter your email: " email
            ssh-keygen -t ed25519 -C "$email"
            echo -e "${GREEN}✅ SSH keys generated${NC}"
            echo ""
            echo "Add this public key to GitHub/GitLab:"
            cat ~/.ssh/id_ed25519.pub
            ;;
        2)
            echo ""
            echo -e "${YELLOW}Manual SSH key restoration:${NC}"
            echo "1. Find your backup SSH keys"
            echo "2. Copy them to ~/.ssh/"
            echo "3. Run: chmod 600 ~/.ssh/id_*"
            echo "4. Run: chmod 644 ~/.ssh/id_*.pub"
            ;;
        *)
            echo "Skipped SSH key setup"
            ;;
    esac
fi

echo ""
echo -e "${BLUE}🔍 Looking for Git configuration...${NC}"

# Check for Git config
if [[ -f "$HOME/.gitconfig" ]]; then
    echo -e "${GREEN}✅ Git config found${NC}"
    echo "   User: $(git config --global user.name) <$(git config --global user.email)>"
else
    echo -e "${YELLOW}⚠️  No Git config found${NC}"
    echo ""
    echo "Would you like to configure Git now? (y/n)"
    read -p "" -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        read -p "Enter your name: " git_name
        read -p "Enter your email: " git_email
        git config --global user.name "$git_name"
        git config --global user.email "$git_email"
        git config --global init.defaultBranch main
        git config --global pull.rebase false
        echo -e "${GREEN}✅ Git configured${NC}"
    fi
fi

echo ""
echo -e "${BLUE}📋 Manual restoration tips:${NC}"
echo ""
echo "1. External drives and USB:"
echo "   - Mounted at: /media/$USER/"
echo "   - Check for backup folders"
echo ""
echo "2. Network shares (NAS):"
echo "   - Mount with: sudo mount -t cifs //server/share /mnt/backup -o username=USER"
echo "   - Or use SSHFS: sshfs user@server:/path /mnt/backup"
echo ""
echo "3. Cloud storage:"
echo "   - Install rclone: sudo apt install rclone"
echo "   - Configure: rclone config"
echo "   - Mount: rclone mount remote: /mnt/cloud"
echo ""
echo "4. Previous Linux installation:"
echo "   - Mount old partition: sudo mount /dev/sdXY /mnt/old"
echo "   - Copy files from: /mnt/old/home/USERNAME/.zsh/private/"
echo ""
echo "5. After restoring API keys, verify with:"
echo "   source ~/.zshrc"
echo "   echo \$OPENAI_API_KEY | head -c 10"
echo ""
echo "6. Common sensitive file locations:"
echo "   ~/.zsh/private/api-keys.zsh       # API keys"
echo "   ~/.ssh/id_*                        # SSH keys"
echo "   ~/.gitconfig                       # Git configuration"
echo "   ~/.gnupg/                          # GPG keys"
echo "   ~/work/configs/                    # Project configs"
echo ""

echo -e "${GREEN}✅ Restoration helper complete${NC}"
echo ""
echo "💡 Tip: After restoring sensitive files, restart your terminal or run: source ~/.zshrc"
echo ""

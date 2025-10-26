#!/bin/bash
# =============================================================================
# Debian Fresh Setup - One-Line Installer
# =============================================================================
# Downloads and runs the Debian fresh setup without requiring git first
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🐧 Debian Fresh Setup Installer${NC}"
echo "====================================="
echo ""

# Check if running on Linux
if [[ "$(uname -s)" != "Linux" ]]; then
    echo -e "${RED}❌ This script is for Linux only${NC}"
    echo ""
    echo "For macOS, please use: https://github.com/kossoy/macos-fresh-setup"
    exit 1
fi

# Check if apt is available
if ! command -v apt >/dev/null 2>&1; then
    echo -e "${RED}❌ This script requires apt package manager (Debian/Ubuntu)${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Debian-based system detected${NC}"
echo ""

# Check for sudo access
if ! sudo -n true 2>/dev/null; then
    echo "This script requires sudo access."
    echo "You may be prompted for your password."
    echo ""
    sudo -v || {
        echo -e "${RED}❌ Failed to obtain sudo access${NC}"
        exit 1
    }
fi

# Install git if not present
if ! command -v git >/dev/null 2>&1; then
    echo -e "${YELLOW}📦 Git is not installed. Installing...${NC}"
    sudo apt update -qq
    sudo apt install -y git
    echo -e "${GREEN}✅ Git installed${NC}"
    echo ""
else
    echo -e "${GREEN}✅ Git is already installed${NC}"
    echo ""
fi

# Determine installation directory
INSTALL_DIR="$HOME/debian-fresh-setup"

# Clone or update repository
if [[ -d "$INSTALL_DIR" ]]; then
    echo -e "${YELLOW}⚠️  Directory $INSTALL_DIR already exists${NC}"
    read -p "Remove and re-clone? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$INSTALL_DIR"
        echo -e "${BLUE}📥 Cloning repository...${NC}"
        git clone https://github.com/kossoy/debian-fresh-setup.git "$INSTALL_DIR"
    else
        echo -e "${BLUE}🔄 Updating existing repository...${NC}"
        cd "$INSTALL_DIR"

        # Save local changes if any
        if ! git diff --quiet || ! git diff --cached --quiet; then
            echo -e "${YELLOW}  Stashing local changes...${NC}"
            git stash save "Auto-stash before update $(date +%Y-%m-%d_%H:%M:%S)"
        fi

        # Clean untracked files
        if [[ -n "$(git status --porcelain)" ]]; then
            echo -e "${YELLOW}  Cleaning untracked files...${NC}"
            git clean -fd
        fi

        # Pull latest changes
        git pull --rebase

        echo -e "${GREEN}  Repository updated${NC}"
    fi
else
    echo -e "${BLUE}📥 Cloning repository...${NC}"
    git clone https://github.com/kossoy/debian-fresh-setup.git "$INSTALL_DIR"
fi

echo -e "${GREEN}✅ Repository ready${NC}"
echo ""

# Navigate to directory
cd "$INSTALL_DIR"

# Make scripts executable
chmod +x simple-bootstrap.sh
chmod +x setup-helpers/*.sh

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✅ Ready to run setup!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "Choose installation method:"
echo ""
echo "1. Automatic (Recommended)"
echo "   Installs everything with sensible defaults"
echo "   Command: ./simple-bootstrap.sh"
echo ""
echo "2. Manual"
echo "   Run individual setup helpers for more control"
echo "   Start with: ./setup-helpers/01-install-packages.sh"
echo ""
echo "3. Just explore"
echo "   The repository is now at: $INSTALL_DIR"
echo "   Read the README.md for more information"
echo ""

read -p "Run automatic setup now? (y/n): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "${BLUE}🚀 Starting automatic setup...${NC}"
    echo ""
    ./simple-bootstrap.sh
else
    echo ""
    echo "Setup scripts are ready at: $INSTALL_DIR"
    echo ""
    echo "To start manual installation:"
    echo "  cd $INSTALL_DIR"
    echo "  ./simple-bootstrap.sh"
    echo ""
    echo "Or run setup helpers individually:"
    echo "  cd $INSTALL_DIR"
    echo "  ./setup-helpers/01-install-packages.sh"
    echo ""
fi

#!/bin/bash
# =============================================================================
# System Update Checker
# =============================================================================
# Check for available system and package updates
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔍 Checking for updates...${NC}"
echo ""

# Update package lists
echo "📦 Updating package lists..."
sudo apt update -qq

# Check for upgradable packages
UPGRADABLE=$(apt list --upgradable 2>/dev/null | grep -c upgradable || true)

if [[ $UPGRADABLE -gt 1 ]]; then
    echo -e "${YELLOW}⚠️  $((UPGRADABLE - 1)) packages can be upgraded${NC}"
    echo ""
    echo "Upgradable packages:"
    apt list --upgradable 2>/dev/null | tail -n +2
    echo ""

    read -p "Show details? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        apt list --upgradable
    fi

    echo ""
    read -p "Upgrade now? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo apt upgrade
        echo -e "${GREEN}✅ System upgraded${NC}"
    else
        echo "To upgrade later, run: sudo apt upgrade"
    fi
else
    echo -e "${GREEN}✅ All packages are up to date${NC}"
fi

echo ""

# Check for security updates
if command -v unattended-upgrade >/dev/null 2>&1; then
    SECURITY_UPDATES=$(apt list --upgradable 2>/dev/null | grep -i security | wc -l || true)
    if [[ $SECURITY_UPDATES -gt 0 ]]; then
        echo -e "${RED}🔒 $SECURITY_UPDATES security updates available${NC}"
        echo "Install with: sudo apt upgrade"
    fi
fi

# Check if reboot required
if [[ -f /var/run/reboot-required ]]; then
    echo ""
    echo -e "${YELLOW}⚠️  System reboot required${NC}"
    if [[ -f /var/run/reboot-required.pkgs ]]; then
        echo "Packages requiring reboot:"
        cat /var/run/reboot-required.pkgs
    fi
fi

echo ""

# Check for autoremovable packages
AUTOREMOVE=$(apt autoremove --dry-run 2>/dev/null | grep -oP '\d+(?= to remove)' || echo "0")
if [[ $AUTOREMOVE -gt 0 ]]; then
    echo -e "${YELLOW}🗑️  $AUTOREMOVE packages can be auto-removed${NC}"
    read -p "Remove unnecessary packages? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo apt autoremove
        echo -e "${GREEN}✅ Cleaned up${NC}"
    else
        echo "To clean up later, run: sudo apt autoremove"
    fi
fi

echo ""
echo -e "${GREEN}✅ Update check complete${NC}"

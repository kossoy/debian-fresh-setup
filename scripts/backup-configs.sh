#!/bin/bash
# =============================================================================
# Configuration Backup Script
# =============================================================================
# Backup important configuration files and directories
# =============================================================================

set -e

# Configuration
BACKUP_DIR="$HOME/work/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="config_backup_${TIMESTAMP}"
BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"

# Files and directories to backup
CONFIG_ITEMS=(
    "$HOME/.zshrc"
    "$HOME/.zsh"
    "$HOME/.gitconfig"
    "$HOME/.gitignore_global"
    "$HOME/.ssh/config"
    "$HOME/.p10k.zsh"
    "$HOME/.config/systemd/user"
    "$HOME/work/scripts"
)

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}📦 Configuration Backup${NC}"
echo "======================="
echo ""

# Create backup directory
mkdir -p "$BACKUP_PATH"

echo "Backing up to: $BACKUP_PATH"
echo ""

# Backup each item
for item in "${CONFIG_ITEMS[@]}"; do
    if [[ -e "$item" ]]; then
        # Get relative path
        rel_path="${item#$HOME/}"

        # Create parent directory in backup
        backup_item="$BACKUP_PATH/$rel_path"
        mkdir -p "$(dirname "$backup_item")"

        # Copy item
        if [[ -d "$item" ]]; then
            echo "📁 Backing up directory: $rel_path"
            cp -r "$item" "$backup_item"
        else
            echo "📄 Backing up file: $rel_path"
            cp "$item" "$backup_item"
        fi
    else
        echo -e "${YELLOW}⏭️  Skipping (not found): ${item#$HOME/}${NC}"
    fi
done

echo ""

# Create backup metadata
cat > "$BACKUP_PATH/BACKUP_INFO.txt" << EOF
Backup Information
==================
Created: $(date)
Hostname: $(hostname)
User: $USER
Backup Path: $BACKUP_PATH

Backed up items:
EOF

for item in "${CONFIG_ITEMS[@]}"; do
    if [[ -e "$item" ]]; then
        echo "  ✓ ${item#$HOME/}" >> "$BACKUP_PATH/BACKUP_INFO.txt"
    else
        echo "  ✗ ${item#$HOME/} (not found)" >> "$BACKUP_PATH/BACKUP_INFO.txt"
    fi
done

echo ""

# Compress backup
echo "🗜️  Compressing backup..."
cd "$BACKUP_DIR"
tar -czf "${BACKUP_NAME}.tar.gz" "$BACKUP_NAME"
rm -rf "$BACKUP_NAME"

BACKUP_SIZE=$(du -h "${BACKUP_NAME}.tar.gz" | cut -f1)

echo ""
echo -e "${GREEN}✅ Backup complete!${NC}"
echo ""
echo "📦 Backup file: $BACKUP_DIR/${BACKUP_NAME}.tar.gz"
echo "📊 Size: $BACKUP_SIZE"
echo ""

# Show existing backups
echo "Existing backups:"
ls -lh "$BACKUP_DIR"/config_backup_*.tar.gz 2>/dev/null | tail -5 || echo "  (no previous backups found)"

echo ""
echo "To restore from this backup:"
echo "  cd $BACKUP_DIR"
echo "  tar -xzf ${BACKUP_NAME}.tar.gz"
echo "  cp -r ${BACKUP_NAME}/.* ~/"
echo ""

# Cleanup old backups (keep last 10)
BACKUP_COUNT=$(ls -1 "$BACKUP_DIR"/config_backup_*.tar.gz 2>/dev/null | wc -l)
if [[ $BACKUP_COUNT -gt 10 ]]; then
    echo "🗑️  Cleaning up old backups (keeping last 10)..."
    ls -t "$BACKUP_DIR"/config_backup_*.tar.gz | tail -n +11 | xargs rm -f
    echo -e "${GREEN}✅ Cleanup complete${NC}"
fi

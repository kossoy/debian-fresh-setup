#!/bin/bash
# =============================================================================
# Docker Test Environment - Execute Shell Script
# =============================================================================
# Enters the running container with bash or zsh
# Automatically starts container if it's not running
# Usage:
#   ./exec.sh      - Enter with bash (default)
#   ./exec.sh zsh  - Enter with zsh (use after running bootstrap)
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHELL_TYPE="${1:-bash}"

if [[ "$SHELL_TYPE" != "bash" && "$SHELL_TYPE" != "zsh" ]]; then
    echo "❌ Invalid shell type: $SHELL_TYPE"
    echo "Usage: $0 [bash|zsh]"
    exit 1
fi

# Check if container is running
if ! docker ps --filter "name=debian-test-container" --format "{{.Names}}" | grep -q "debian-test-container"; then
    echo "📦 Container is not running, starting it..."
    "$SCRIPT_DIR/up.sh"
    echo ""
fi

echo "🐚 Entering container with $SHELL_TYPE..."
echo ""

docker exec -it debian-test-container "$SHELL_TYPE"

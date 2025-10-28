#!/bin/bash
# =============================================================================
# Docker Test Environment - Build Script
# =============================================================================
# Builds the Debian test container image
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/docker"

echo "🔨 Building Debian test container..."
docker compose build

echo "✅ Build complete!"
echo ""
echo "Next steps:"
echo "  ./up.sh       - Start the container"
echo "  ./exec.sh     - Enter container (bash)"
echo "  ./exec.sh zsh - Enter container (zsh, after bootstrap)"

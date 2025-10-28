#!/bin/bash
# =============================================================================
# Docker Test Environment - Start Script
# =============================================================================
# Starts the Debian test container in detached mode
# Automatically builds image if it doesn't exist
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if image exists
if ! docker images | grep -q "docker-debian-test-service"; then
    echo "📦 Image not found, building first..."
    "$SCRIPT_DIR/build.sh"
    echo ""
fi

cd "$SCRIPT_DIR/docker"

echo "🚀 Starting Debian test container..."
docker compose up -d

echo "✅ Container started!"
echo ""
echo "Container info:"
docker ps --filter "name=debian-test-container" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""
echo "Next steps:"
echo "  ./exec.sh     - Enter container (bash)"
echo "  ./exec.sh zsh - Enter container (zsh, after bootstrap)"
echo "  docker logs debian-test-container - View container logs"

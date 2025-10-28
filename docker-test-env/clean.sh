#!/bin/bash
# =============================================================================
# Docker Test Environment - Clean Script
# =============================================================================
# Completely removes containers, images, and volumes
# WARNING: This will delete ALL data in the test environment!
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/docker"

echo "🗑️  Cleaning up Docker test environment..."
echo ""
echo "This will remove:"
echo "  - debian-test-container (container)"
echo "  - debian-test image"
echo "  - apt-cache and apt-lib volumes"
echo ""
read -p "Are you sure? (y/N) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Cleanup cancelled"
    exit 0
fi

echo "🧹 Stopping and removing containers..."
docker compose down

echo "🗑️  Removing images..."
docker compose down --rmi all

echo "🗑️  Removing volumes..."
docker volume rm docker_apt-cache docker_apt-lib 2>/dev/null || echo "⚠️  Volumes already removed or don't exist"

echo "✅ Cleanup complete!"
echo ""
echo "Test environment has been completely removed."
echo "Run ./build.sh to recreate it."

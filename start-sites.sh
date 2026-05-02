#!/bin/bash
# Start Docker container and optionally configure Tailscale serve

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== Groeiwijze ==="
echo ""

# Check if .env exists
if [ ! -f ".env" ]; then
    echo "ERROR: .env file not found!"
    echo "Copy .env.example to .env and fill in your credentials:"
    echo "  cp .env.example .env"
    echo "  nano .env"
    exit 1
fi

# Start Docker container
echo "[1/2] Starting Docker container..."
docker compose up -d --build

# Wait for container to be healthy
echo "[2/2] Waiting for container to start..."
sleep 3

# Check container status
echo ""
echo "Container status:"
docker compose ps

# Configure Tailscale serve (if tailscale is available)
if command -v tailscale &> /dev/null; then
    echo ""
    HOSTNAME=$(tailscale status --json | jq -r '.Self.DNSName' | sed 's/\.$//')

    echo "Tailscale serve command (run manually to enable HTTPS):"
    echo "  tailscale serve --bg --https=8443 http://localhost:8001"
    echo ""
    echo "HTTPS access: https://$HOSTNAME:8443"
fi

echo ""
echo "=== Site is now running ==="
echo ""
echo "Local access: http://localhost:8001"
echo ""
echo "To stop: docker compose down"
echo "To view logs: docker compose logs -f"

#!/bin/bash
# Start Docker container and optionally configure Tailscale serve

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

COMPOSE_ARGS=(-f docker-compose.yml -f docker-compose.dev.yml)

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
docker compose "${COMPOSE_ARGS[@]}" up -d --build

# Wait for container to be healthy
echo "[2/2] Waiting for container to start..."
sleep 3

# Check container status
echo ""
echo "Container status:"
docker compose "${COMPOSE_ARGS[@]}" ps

# Configure Tailscale serve (if tailscale is available)
if command -v tailscale &> /dev/null; then
    echo ""
    HOSTNAME=$(tailscale status --json | jq -r '.Self.DNSName' | sed 's/\.$//')

    echo "Tailscale serve commands (run manually to enable HTTPS):"
    echo "  tailscale serve --bg --https=8443 http://localhost:8001"
    echo "  tailscale serve --bg --https=8444 http://localhost:8025"
    echo ""
    echo "HTTPS access:"
    echo "  Site:           https://$HOSTNAME:8443"
    echo "  Mailcatcher UI: https://$HOSTNAME:8444"
fi

echo ""
echo "=== Site is now running ==="
echo ""
echo "Local access:"
echo "  Site:           http://localhost:8001"
echo "  Mailcatcher UI: http://localhost:8025"
echo ""
echo "To stop: docker compose -f docker-compose.yml -f docker-compose.dev.yml down"
echo "To view logs: docker compose -f docker-compose.yml -f docker-compose.dev.yml logs -f"

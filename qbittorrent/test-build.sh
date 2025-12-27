#!/bin/bash
# Script to build and test the qBittorrent add-on locally

echo "Building qBittorrent add-on with WireGuard fixes..."

# Build the add-on
docker build -t local/qbittorrent-fixed:latest .

echo "Build complete!"
echo ""
echo "To install in Home Assistant:"
echo "1. Copy this entire qbittorrent folder to your Home Assistant"
echo "2. Add it as a local add-on repository"
echo "3. Install from the local repository"
echo ""
echo "Or run directly with Docker:"
echo "docker run -d --name qbittorrent-test \\"
echo "  --cap-add=NET_ADMIN \\"
echo "  --device=/dev/net/tun \\"
echo "  -v /path/to/config:/config \\"
echo "  -v /path/to/downloads:/share \\"
echo "  -p 8080:8080 \\"
echo "  local/qbittorrent-fixed:latest"
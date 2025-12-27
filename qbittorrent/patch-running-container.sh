#!/bin/bash
# Script to patch a running qBittorrent container (temporary fix)

CONTAINER_NAME="addon_local_qbittorrent"  # Adjust this to your container name

echo "Finding qBittorrent container..."
CONTAINER_ID=$(docker ps | grep qbittorrent | awk '{print $1}' | head -1)

if [ -z "$CONTAINER_ID" ]; then
    echo "No running qBittorrent container found!"
    echo "Container names:"
    docker ps --format "table {{.Names}}\t{{.Image}}"
    exit 1
fi

echo "Found container: $CONTAINER_ID"
echo "Backing up original files..."

# Backup and patch the VPN monitor
docker exec $CONTAINER_ID cp /etc/services.d/vpn-monitor/run /etc/services.d/vpn-monitor/run.backup

# Copy our fixed files
docker cp rootfs/etc/services.d/vpn-monitor/run $CONTAINER_ID:/etc/services.d/vpn-monitor/run
docker cp rootfs/etc/s6-overlay/s6-rc.d/svc-qbittorrent/run $CONTAINER_ID:/etc/s6-overlay/s6-rc.d/svc-qbittorrent/run
docker cp rootfs/etc/cont-init.d/94-wireguard.sh $CONTAINER_ID:/etc/cont-init.d/94-wireguard.sh

echo "Files patched! Restart the add-on to test the fix."
echo "To restore: docker exec $CONTAINER_ID cp /etc/services.d/vpn-monitor/run.backup /etc/services.d/vpn-monitor/run"
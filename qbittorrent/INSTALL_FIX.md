# How to Install the WireGuard Fix in Home Assistant

## Method 1: Local Add-on Repository (Recommended)

### Step 1: Copy Files to Home Assistant
1. **Access your Home Assistant file system** (via SSH, Samba, or File Editor add-on)
2. **Create directory**: `/config/addons/qbittorrent-fixed/`
3. **Copy this entire qbittorrent folder** to that location

### Step 2: Add Local Repository
1. Go to **Supervisor → Add-on Store**
2. Click the **⋮ (three dots)** menu → **Repositories**
3. Add repository URL: `file:///config/addons/qbittorrent-fixed`
4. Click **Add**

### Step 3: Install Fixed Version
1. Refresh the Add-on Store page
2. Look for **"qBittorrent Fixed"** or version **5.1.4-5**
3. **Uninstall** the old qBittorrent add-on first (backup your config!)
4. **Install** the new version
5. **Restore** your configuration
6. **Start** the add-on

## Method 2: Direct File Replacement (Advanced)

If you have SSH access and want to patch the running container:

```bash
# Find the container
docker ps | grep qbittorrent

# Get container ID (replace CONTAINER_ID with actual ID)
CONTAINER_ID="your_container_id"

# Backup original files
docker exec $CONTAINER_ID cp /etc/services.d/vpn-monitor/run /tmp/vpn-monitor.run.backup
docker exec $CONTAINER_ID cp /etc/s6-overlay/s6-rc.d/svc-qbittorrent/run /tmp/svc-qbittorrent.run.backup

# Copy fixed files (from your HA machine where you copied the files)
docker cp /config/addons/qbittorrent-fixed/rootfs/etc/services.d/vpn-monitor/run $CONTAINER_ID:/etc/services.d/vpn-monitor/run
docker cp /config/addons/qbittorrent-fixed/rootfs/etc/s6-overlay/s6-rc.d/svc-qbittorrent/run $CONTAINER_ID:/etc/s6-overlay/s6-rc.d/svc-qbittorrent/run
docker cp /config/addons/qbittorrent-fixed/rootfs/etc/cont-init.d/94-wireguard.sh $CONTAINER_ID:/etc/cont-init.d/94-wireguard.sh

# Restart the add-on from HA interface
```

## Method 3: Build and Replace Image

```bash
# On your HA machine with the copied files
cd /config/addons/qbittorrent-fixed

# Build new image
docker build -t ghcr.io/alexbelgium/qbittorrent-amd64:5.1.4-5 .

# Stop and remove old container
docker stop addon_local_qbittorrent
docker rm addon_local_qbittorrent

# Start add-on again from HA interface - it will use the new image
```

## Verification

After installation, check the logs for these new messages:
- `[INFO] WireGuard configuration validation passed`
- `[INFO] Waiting 30 seconds for WireGuard connection to stabilize...`
- `[INFO] WireGuard detected - using extended connection timeout`
- `[INFO] VPN external IP: x.x.x.x (Country)`

The connection should now succeed within 60-90 seconds instead of failing.

## Rollback

To rollback if needed:
1. Remove the local repository
2. Reinstall the original add-on from the main repository
3. Or restore the backup files if using Method 2

## File Structure

Your `/config/addons/qbittorrent-fixed/` should contain:
```
qbittorrent-fixed/
├── config.yaml (version 5.1.4-5)
├── repository.yaml
├── Dockerfile
├── rootfs/
│   ├── etc/
│   │   ├── cont-init.d/
│   │   │   └── 94-wireguard.sh (fixed)
│   │   ├── services.d/
│   │   │   └── vpn-monitor/
│   │   │       └── run (fixed)
│   │   └── s6-overlay/
│   │       └── s6-rc.d/
│   │           └── svc-qbittorrent/
│   │               └── run (fixed)
│   └── usr/
└── ... (other files)
```
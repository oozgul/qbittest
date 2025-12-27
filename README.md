# qBittorrent WireGuard Fix Repository

This repository contains a fixed version of the qBittorrent Home Assistant add-on that resolves WireGuard connection timeout issues.

## Problem Fixed

The original add-on would fail WireGuard connections with:
```
WARNING: External IP still equals real IP (x.x.x.x); VPN not ready yet (attempt 1/5).
```

## Solution

- Extended WireGuard connection timeout from 25 seconds to 130 seconds
- Added proper WireGuard configuration validation
- Improved startup sequence and error handling
- Better logging for troubleshooting

## Installation

1. Add this repository to Home Assistant:
   - Go to Supervisor → Add-on Store
   - Click ⋮ (three dots) → Repositories
   - Add: `https://github.com/oozgul/qbittest`

2. Install qBittorrent (Fixed) version 5.1.4-5

3. Configure WireGuard as usual:
   ```yaml
   wireguard_enabled: true
   wireguard_config: "wg0.conf"
   ```

## What's Changed

- **Version bumped to 5.1.4-5** (from 5.1.4-4)
- **Extended timeout**: 10 attempts × 10 seconds + 30 second initial delay
- **Configuration validation**: Checks for required WireGuard sections
- **Better error messages**: More helpful debugging information
- **Improved startup**: Waits for interface to stabilize before proceeding

## Files Modified

- `rootfs/etc/services.d/vpn-monitor/run` - Extended timeout logic
- `rootfs/etc/s6-overlay/s6-rc.d/svc-qbittorrent/run` - Better WireGuard setup
- `rootfs/etc/cont-init.d/94-wireguard.sh` - Added validation
- `config.yaml` - Version bump to 5.1.4-5

## Expected Logs

After the fix, you should see:
```
[INFO] WireGuard configuration validation passed
[INFO] Starting WireGuard interface wg0...
[INFO] WireGuard interface wg0 assigned IP: 10.x.x.x
[INFO] Waiting 30 seconds for WireGuard connection to stabilize...
[INFO] WireGuard detected - using extended connection timeout (10 attempts, 10s intervals)
[INFO] VPN external IP: x.x.x.x (Country)
```

## Support

This is a community fix. For issues with the original add-on, see: https://github.com/alexbelgium/hassio-addons

## Credits

Based on the excellent work by [@alexbelgium](https://github.com/alexbelgium/hassio-addons)
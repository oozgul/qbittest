# WireGuard Connection Fix for qBittorrent Add-on

## Problem
The qBittorrent add-on with WireGuard was failing to establish VPN connections, showing logs like:
```
[16:51:53] INFO: Real (non-VPN) IP from /currentip: 84.25.218.65
[16:51:53] INFO: VPN detected; enabling IP leak protection and periodic monitoring.
[16:51:53] WARNING: External IP still equals real IP (84.25.218.65); VPN not ready yet (attempt 1/5).
```

## Root Cause
The VPN monitoring service was checking the external IP too quickly after WireGuard startup, before the VPN connection had time to fully establish. WireGuard connections can take 30-60 seconds to stabilize, especially on slower systems or with distant endpoints.

## Fixes Applied

### 1. Extended WireGuard Connection Timeout
- Increased monitoring attempts from 5 to 10 for WireGuard
- Increased sleep interval from 5 to 10 seconds between attempts
- Added 30-second initial delay before monitoring starts

### 2. Better WireGuard Validation
- Added configuration file validation (checks for [Interface], [Peer], and PrivateKey sections)
- Added WireGuard tools availability check
- Added interface IP assignment verification

### 3. Improved Startup Sequence
- Added 10-second stabilization wait after WireGuard interface comes up
- Added interface status verification before starting qBittorrent
- Better error messages and logging

### 4. Enhanced Monitoring
- WireGuard-specific timeout handling in VPN monitor
- Better logging to help debug connection issues

## Configuration Requirements

### WireGuard Configuration File
Your WireGuard config file (e.g., `/config/wireguard/wg0.conf`) must contain:

```ini
[Interface]
PrivateKey = YOUR_PRIVATE_KEY
Address = 10.x.x.x/32
DNS = 1.1.1.1, 1.0.0.1

[Peer]
PublicKey = PEER_PUBLIC_KEY
Endpoint = your.vpn.server:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
```

### Add-on Configuration
```yaml
wireguard_enabled: true
wireguard_config: "wg0.conf"  # Optional if only one .conf file exists
DNS_server: "1.1.1.1,1.0.0.1"  # Should match your WireGuard DNS
```

## Troubleshooting

### If WireGuard still fails to connect:

1. **Check your configuration file**:
   - Ensure it's in `/config/wireguard/`
   - Verify it has correct syntax
   - Test it works on your local machine first

2. **Check the logs**:
   - Look for "WireGuard configuration validation passed"
   - Check for iptables errors (may need iptables-legacy fallback)
   - Verify interface gets an IP address

3. **Network issues**:
   - Ensure UDP port 51820 is not blocked
   - Try different endpoints if your VPN provider offers multiple
   - Check if your ISP blocks VPN traffic

4. **Container permissions**:
   - The add-on needs NET_ADMIN capability (already configured)
   - Ensure /dev/net/tun is available (already mapped)

### Common Error Messages:

- **"WireGuard tools not found"**: WireGuard packages not installed (should not happen with this fix)
- **"Invalid WireGuard configuration"**: Check your .conf file syntax
- **"WireGuard interface wg0 is not up"**: Connection failed, check endpoint and keys
- **"IP LEAK DETECTED"**: VPN dropped, add-on will stop for safety

## Testing the Fix

1. Enable WireGuard in add-on configuration
2. Start the add-on
3. Check logs for:
   ```
   [INFO] WireGuard configuration validation passed
   [INFO] Starting WireGuard interface wg0...
   [INFO] WireGuard interface wg0 assigned IP: 10.x.x.x
   [INFO] Waiting 30 seconds for WireGuard connection to stabilize...
   [INFO] VPN external IP: x.x.x.x (Country)
   ```

The connection should now establish successfully within 60-90 seconds instead of failing after 25 seconds.
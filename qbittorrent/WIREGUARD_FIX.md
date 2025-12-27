# WireGuard Fix for qBittorrent Home Assistant Add-on

## Problem
The original qBittorrent add-on's WireGuard implementation was failing with timeout errors after 25 seconds:
```
WARNING: External IP still equals real IP (84.25.218.65); VPN not ready yet (attempt 1/5).
```

Even when the interface was created successfully, the tunnel had no connectivity - no handshake, ping failures, and torrents wouldn't download.

## Root Causes Identified

### 1. Timeout Too Short
The WireGuard connection timeout was only 25 seconds (5 attempts × 5 seconds), which wasn't enough time for the VPN tunnel to establish in Home Assistant containers.

### 2. Routing Configuration Error (CRITICAL - Fixed in v5.1.4-26)
**The main issue**: The routing was configured in the wrong order, creating a chicken-and-egg problem:
- Default routes through wg0 were added BEFORE the endpoint route
- This meant handshake packets tried to go through the tunnel that wasn't established yet
- The VPN server was unreachable, so the handshake never completed
- Without handshake, the tunnel had no connectivity

## Solution

### Version 5.1.4-26 (Current)
**CRITICAL FIX**: Corrected routing order to fix tunnel connectivity:

1. **Fixed Routing Order**:
   - Endpoint route is added FIRST (before any default routes)
   - This ensures handshake packets can reach the VPN server via the original gateway
   - Only after endpoint is routable, default routes through wg0 are added
   - Split routing (0.0.0.0/1 and 128.0.0.0/1) to avoid conflicts

2. **Enhanced Diagnostics**:
   - Tests endpoint reachability before configuring routes
   - Waits up to 30 seconds for handshake with progress updates
   - Tests actual tunnel connectivity with ping
   - Provides detailed diagnostics if connection fails
   - Shows routing table and WireGuard peer status

3. **Extended Timeout**: Increased from 25s to 100+ seconds
   - 10 attempts instead of 5
   - 10 second intervals instead of 5
   - Additional 30 second stabilization period

4. **Configuration Validation**: Added checks for required WireGuard config elements
   - Validates [Interface] and [Peer] sections exist
   - Checks for PrivateKey presence
   - Provides clear error messages

5. **Container-Friendly Setup**: Works around Home Assistant container limitations
   - Handles iptables permission issues
   - Falls back to manual interface creation when wg-quick fails
   - Skips problematic sysctl settings that require elevated privileges

6. **Network Binding**: Ensures qBittorrent only uses VPN
   - Automatically binds qBittorrent to WireGuard interface
   - Prevents IP leaks if VPN drops

## Installation

1. Stop the original qBittorrent add-on (to avoid port conflicts)
2. Add this repository to Home Assistant:
   ```
   https://github.com/oozgul/qbittest
   ```
3. Install "qBittorrent (Fixed)" add-on
4. Configure your WireGuard settings:
   - Enable WireGuard in add-on configuration
   - Place your `wg0.conf` file in `/config/wireguard/`
   - Remove any `DNS =` lines from the config file (Home Assistant handles DNS)
5. Start the add-on

## Configuration Notes

### WireGuard Config File
Your `/config/wireguard/wg0.conf` should look like:
```ini
[Interface]
PrivateKey = YOUR_PRIVATE_KEY
Address = 10.x.x.x/16

[Peer]
PublicKey = SERVER_PUBLIC_KEY
Endpoint = vpn.server.com:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
```

**Important**: Remove any `DNS =` lines from the config file, as Home Assistant containers handle DNS differently.

### Add-on Configuration
In the add-on configuration UI:
- Set `wireguard_enabled: true`
- Optionally set `wireguard_config: wg0.conf` (auto-detected if only one .conf file exists)
- Configure other qBittorrent settings as needed

## Troubleshooting

### "WireGuard configuration not found"
- Ensure your config file is at `/config/wireguard/wg0.conf`
- Check file permissions (should be readable)
- Verify the file has a `.conf` extension

### "VPN endpoint is NOT reachable"
- Check your WireGuard server is accessible from your network
- Verify endpoint hostname resolves correctly
- Ensure firewall allows UDP traffic on the WireGuard port
- Try pinging the endpoint IP manually

### "No handshake detected"
- Check the endpoint is reachable (see above)
- Verify your PrivateKey and PublicKey are correct
- Ensure AllowedIPs includes 0.0.0.0/0
- Check VPN server logs for connection attempts

### "Cannot reach internet through tunnel"
- Handshake succeeded but routing may be wrong
- Check if endpoint route exists: `ip route get <endpoint-ip>`
- Verify default routes through wg0: `ip route show`
- Check VPN server allows forwarding

### "resolvconf: signature mismatch"
- This is normal in Home Assistant containers
- The add-on automatically removes DNS configuration from WireGuard
- DNS is handled by Home Assistant's DNS resolver

### "sysctl: permission denied"
- This is expected in Home Assistant containers
- The add-on continues anyway if the interface is up
- Does not affect VPN functionality

## Version History

- **5.1.4-4**: Initial fork with basic timeout extension
- **5.1.4-10**: Added configuration validation
- **5.1.4-15**: Improved container compatibility
- **5.1.4-20**: Added manual WireGuard setup fallback
- **5.1.4-25**: Enhanced error handling and network binding
- **5.1.4-26**: **CRITICAL FIX** - Corrected routing order (endpoint route before default routes) + enhanced diagnostics

## Technical Details

The fix modifies three key files:

1. **`94-wireguard.sh`**: Validates configuration and prepares runtime config
2. **`svc-qbittorrent/run`**: Handles WireGuard connection with fallbacks
3. **`vpn-monitor/run`**: Monitors VPN connection with extended timeout

### Routing Logic (v5.1.4-26)
The critical fix ensures proper routing order:

1. **Get network info**: Identify default gateway, device, and VPN endpoint IP
2. **Test endpoint**: Verify VPN server is reachable before configuring routes
3. **Add endpoint route FIRST**: `ip route add <endpoint>/32 via <gateway> dev <device>`
4. **Wait for route to settle**: 2 second delay
5. **Add default routes through wg0**: Split routing with 0.0.0.0/1 and 128.0.0.0/1
6. **Wait for handshake**: Up to 30 seconds with progress updates
7. **Test connectivity**: Ping through tunnel to verify it works

This order is critical - the endpoint MUST be routable via the original gateway before adding default routes through wg0, otherwise handshake packets can't reach the VPN server.

### Fallback Approaches
The implementation tries multiple approaches in order:
1. Standard `wg-quick up` with full config
2. IPv4-only endpoints (resolves hostnames to IPv4)
3. Simplified config without routing tables
4. Manual interface creation with corrected routing order (v5.1.4-26)

This ensures maximum compatibility across different Home Assistant environments and VPN providers.

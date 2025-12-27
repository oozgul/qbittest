# Home assistant add-on: qBittorrent (WireGuard Fixed)

**🔧 This is a FIXED version that resolves WireGuard connection timeout issues.**

## What's Fixed

- ✅ **Extended WireGuard timeout**: 130 seconds total (vs 25 seconds original)
- ✅ **Better validation**: Checks WireGuard config file integrity
- ✅ **Improved startup**: Waits for connection to stabilize
- ✅ **Enhanced logging**: Better error messages for troubleshooting

## Problem Solved

Original add-on would fail with:
```
WARNING: External IP still equals real IP (x.x.x.x); VPN not ready yet (attempt 1/5).
```

This version gives WireGuard proper time to establish connection.

## Installation

1. **Add this repository** to Home Assistant:
   - Supervisor → Add-on Store → ⋮ → Repositories
   - Add: `https://github.com/yourusername/qbittest`

2. **Install** "qBittorrent (Fixed)" version 5.1.4-5

3. **Configure** as usual - WireGuard will now work reliably!

## Expected Behavior

After starting, you'll see:
```
[INFO] WireGuard configuration validation passed
[INFO] Waiting 30 seconds for WireGuard connection to stabilize...
[INFO] WireGuard detected - using extended connection timeout
[INFO] VPN external IP: x.x.x.x (Country)
```

Connection establishes within 60-90 seconds instead of failing.

---

## Original Documentation

[Qbittorrent](https://github.com/qbittorrent/qBittorrent) is a cross-platform free and open-source BitTorrent client.
This addon is based on the docker image from [linuxserver.io](https://www.linuxserver.io/).

This addons has several configurable options :

- allowing to mount local external drive, or smb share from the addon
- [alternative webUI](https://github.com/qbittorrent/qBittorrent/wiki/List-of-known-alternate-WebUIs)
- usage of ssl
- ingress
- optional OpenVPN or WireGuard support
- allow setting specific DNS servers

## Configuration

---

Webui can be found at <http://homeassistant:8080>, or in your sidebar using Ingress.
The default username/password is described in the startup log.

Network disk is mounted to `/mnt/<share_name>`. You need to map the exposed port in your router for best speed and connectivity.

### WireGuard Setup (FIXED VERSION)

WireGuard configuration files must be stored in `/config/wireguard`. If several `.conf` files are present, set `wireguard_config` to the file name you want to use (for example `wg0.conf`).

**This fixed version includes:**
- ✅ Configuration validation (checks for [Interface], [Peer], PrivateKey)
- ✅ Extended connection timeout (130 seconds total)
- ✅ Better error handling and logging
- ✅ Automatic fallback to IPv4-only endpoints if needed

### Example WireGuard Configuration

Your `/config/wireguard/wg0.conf` should look like:

```ini
[Interface]
PrivateKey = YOUR_PRIVATE_KEY_HERE
Address = 10.66.66.1/32
DNS = 1.1.1.1, 1.0.0.1

[Peer]
PublicKey = PEER_PUBLIC_KEY_HERE
Endpoint = your.vpn.server.com:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
```

### Add-on Configuration

```yaml
wireguard_enabled: true
wireguard_config: "wg0.conf"  # Optional if only one .conf file
DNS_server: "1.1.1.1,1.0.0.1"  # Should match WireGuard DNS
```

## Troubleshooting

### WireGuard Connection Issues

The fixed version provides better error messages:

- **"WireGuard configuration validation passed"** ✅ Config file is valid
- **"Invalid WireGuard configuration: missing [Interface]"** ❌ Fix your config file
- **"WireGuard interface wg0 assigned IP: 10.x.x.x"** ✅ Interface is working
- **"VPN external IP: x.x.x.x (Country)"** ✅ Connection successful

### If Still Having Issues

1. **Check config file syntax** - must have [Interface] and [Peer] sections
2. **Verify endpoint is reachable** - test on another device first
3. **Check firewall** - ensure UDP 51820 isn't blocked
4. **Review logs** - the fixed version provides detailed error messages

## Credits

This fix is based on the excellent work by [@alexbelgium](https://github.com/alexbelgium/hassio-addons).

**Original repository**: https://github.com/alexbelgium/hassio-addons
**Fixed version**: Resolves WireGuard timeout issues
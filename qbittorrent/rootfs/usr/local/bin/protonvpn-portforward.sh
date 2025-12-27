#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
# ProtonVPN Port Forwarding Detection Script

set -e

GATEWAY="${1:-10.2.0.1}"
QBT_CONFIG="/config/qBittorrent/qBittorrent.conf"
MAX_ATTEMPTS=10
SLEEP_INTERVAL=5

bashio::log.info "ProtonVPN Port Forwarding Detection"
bashio::log.info "Gateway: ${GATEWAY}"

# Check if natpmpc is available
if ! command -v natpmpc >/dev/null 2>&1; then
    bashio::log.warning "natpmpc not found - installing libnatpmp..."
    apk add --no-cache libnatpmp-dev libnatpmp 2>/dev/null || {
        bashio::log.error "Failed to install libnatpmp"
        exit 1
    }
fi

# Try to get forwarded port from ProtonVPN
bashio::log.info "Querying ProtonVPN for forwarded port..."

for attempt in $(seq 1 ${MAX_ATTEMPTS}); do
    bashio::log.debug "Attempt ${attempt}/${MAX_ATTEMPTS}"

    # Query NAT-PMP for port mapping
    if output=$(natpmpc -g "${GATEWAY}" -a 0 0 tcp 60 2>&1); then
        # Parse the output for the external port
        external_port=$(echo "${output}" | grep -oP 'Mapped public port \K[0-9]+' | head -1)

        if [[ -n "${external_port}" && "${external_port}" -gt 1024 ]]; then
            bashio::log.info "✓ ProtonVPN forwarded port detected: ${external_port}"

            # Configure qBittorrent to use this port
            if [[ -f "${QBT_CONFIG}" ]]; then
                bashio::log.info "Configuring qBittorrent to use port ${external_port}..."

                # Update or add the listening port
                if grep -q "^Connection\\\\PortRangeMin=" "${QBT_CONFIG}"; then
                    sed -i "s/^Connection\\\\PortRangeMin=.*/Connection\\\\PortRangeMin=${external_port}/" "${QBT_CONFIG}"
                else
                    sed -i "/\\[Preferences\\]/a Connection\\\\PortRangeMin=${external_port}" "${QBT_CONFIG}"
                fi

                # Disable random port on startup
                if grep -q "^Connection\\\\UseRandomPort=" "${QBT_CONFIG}"; then
                    sed -i "s/^Connection\\\\UseRandomPort=.*/Connection\\\\UseRandomPort=false/" "${QBT_CONFIG}"
                else
                    sed -i "/\\[Preferences\\]/a Connection\\\\UseRandomPort=false" "${QBT_CONFIG}"
                fi

                # Disable UPnP
                if grep -q "^Connection\\\\UPnP=" "${QBT_CONFIG}"; then
                    sed -i "s/^Connection\\\\UPnP=.*/Connection\\\\UPnP=false/" "${QBT_CONFIG}"
                else
                    sed -i "/\\[Preferences\\]/a Connection\\\\UPnP=false" "${QBT_CONFIG}"
                fi

                bashio::log.info "✓ qBittorrent configured with port ${external_port}"
                bashio::log.info "Port forwarding setup complete!"

                # Save port to file for monitoring
                echo "${external_port}" > /var/run/protonvpn-port

                exit 0
            else
                bashio::log.warning "qBittorrent config not found yet, will retry..."
            fi
        fi
    fi

    sleep ${SLEEP_INTERVAL}
done

bashio::log.error "Failed to detect ProtonVPN forwarded port after ${MAX_ATTEMPTS} attempts"
bashio::log.error "You may need to manually configure the port in qBittorrent settings"
exit 1

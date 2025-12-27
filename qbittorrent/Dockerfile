ARG BUILD_FROM
FROM ${BUILD_FROM}

# Copy our fixed files
COPY rootfs/ /

# Make scripts executable
RUN chmod a+x /etc/cont-init.d/* /etc/services.d/*/run /etc/s6-overlay/s6-rc.d/*/run 2>/dev/null || true
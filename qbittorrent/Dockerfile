ARG BUILD_FROM
FROM ${BUILD_FROM}

# Copy our fixed files
COPY rootfs/ /

# Make scripts executable and ensure sysctl wrapper is in PATH
RUN chmod a+x /etc/cont-init.d/* /etc/services.d/*/run /etc/s6-overlay/s6-rc.d/*/run /usr/local/sbin/* /usr/local/bin/* 2>/dev/null || true

# Ensure our custom sysctl is used
ENV PATH="/usr/local/sbin:/usr/local/bin:${PATH}"
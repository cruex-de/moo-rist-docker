FROM ubuntu:24.04

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date="${BUILD_DATE}" \
      org.label-schema.name="moo-rist-docker" \
      org.label-schema.description="A Docker implementation of Moo's Self hosted Rist Server" \
      org.label-schema.usage="https://github.com/cruex-de/moo-rist-docker#readme" \
      org.label-schema.vcs-ref="${VCS_REF}" \
      org.label-schema.vcs-url="https://github.com/cruex-de/moo-rist-docker" \
      org.label-schema.vendor="cruex-de" \
      org.label-schema.version="2.5.0" \
      maintainer="https://github.com/cruex-de"

# Install dependencies
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
        libcjson-dev \
        libmicrohttpd-dev \
        libmbedtls-dev \
        libmbedcrypto7t64 \
        libicu-dev \
        ca-certificates && \
    update-ca-certificates

# Create non-root user
RUN groupadd -g 1001 moo && \
    useradd moo -s /bin/bash -u 1001 -G sudo -g moo

# Set working directory
WORKDIR /moo-rist-relay

# Create directories
RUN chown -R moo:moo /moo-rist-relay && \
    chmod 755 /moo-rist-relay

# Copy package files
COPY --chown=moo:moo out_linux/ ./
COPY --chown=moo:moo config.example.json ./config.json
COPY --chown=moo:moo scripts/run_relay.sh ./

# Configure directories and files
RUN chown -R moo:moo config.json \
        run_relay.sh && \
    chmod 755 \
        config.json \
        moo-rist-selfhosting \
        librist/tools/ristreceiver \
        run_relay.sh

# Expose ports
EXPOSE 12345/udp 5000/tcp 2030/udp

# Start rist relay server
ENTRYPOINT [ "sh", "run_relay.sh"]
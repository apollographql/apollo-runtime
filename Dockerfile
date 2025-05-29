FROM otel/opentelemetry-collector-contrib AS otel
FROM debian:12-slim@sha256:90522eeb7e5923ee2b871c639059537b30521272f10ca86fdbbbb2b75a8c40cd

# renovate: datasource=github-releases depName=just-containers/s6-overlay
ARG S6_OVERLAY_VERSION=3.2.1.0
# renovate: datasource=github-releases depName=apollographql/router
ARG ROUTER_VERSION=2.1.2
# renovate: datasource=github-releases depName=apollographql/apollo-mcp-server
ARG MCP_SERVER_VERSION=0.2.1
ARG TARGETARCH
USER root
WORKDIR /dist

# Copy our otel bits into our final image
COPY --from=otel /otelcol-contrib /otelcol-contrib
COPY --from=otel /etc/otelcol-contrib /etc/otelcol-contrib

# Install some stuff to extract archives (procps isn't required)
RUN apt update && apt-get install -y xz-utils tar wget curl ca-certificates 7zip
# Clean up apt lists
RUN rm -rf /var/lib/apt/lists/*

# Add all the s6 init supervise stuff.
# Firstly download the no-arch bits
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz

# Calculate which architecture dependent parts we require
RUN case $TARGETARCH in \
        amd64) \
            wget https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz -O /tmp/s6.tar.xz \
            ;; \
        arm64) \
            wget https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-aarch64.tar.xz -O /tmp/s6.tar.xz \
            ;; \
        *) \
            echo "TARGETARCH $TARGETARCH not recognised, exiting..." \
            exit 1 \
            ;; \
    esac

# Extract the architecture dependent parts
RUN tar -C / -Jxpf /tmp/s6.tar.xz && rm -r /tmp/s6.tar.xz

# Download the router binary
RUN curl -sSL "https://router.apollo.dev/download/nix/v${ROUTER_VERSION}" | sh

# Add a default copy of the router config file
ADD config/default_router.yaml /dist/config.yaml

# Install our router service definition
ADD s6_service_definitions/router /etc/s6-overlay/s6-rc.d/router

# Let s6 know about our router service
RUN mkdir -p /etc/s6-overlay/s6-rc.d/user/contents.d/router

# Install our mcp server
RUN curl -sSL "https://mcp.apollo.dev/download/nix/v${MCP_SERVER_VERSION}" | sh

# Install our mcp service definition
ADD s6_service_definitions/mcp /etc/s6-overlay/s6-rc.d/mcp

# Let s6 know about our mcp service
RUN mkdir -p /etc/s6-overlay/s6-rc.d/user/contents.d/mcp

# Use the s6 init process to control our service
ENTRYPOINT ["/init"]
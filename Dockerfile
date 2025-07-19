FROM otel/opentelemetry-collector-contrib@sha256:e94cfd92357aa21f4101dda3c0c01f90e6f24115ba91b263c4d09fed7911ae68 AS otel
FROM almalinux:10-minimal@sha256:a6b2c1d34ae5cb828e67003dce51ea65b1a0b0ff05538070d9e172695002f497 AS final

# renovate: datasource=github-releases depName=just-containers/s6-overlay
ARG S6_OVERLAY_VERSION=3.2.1.0
# renovate: datasource=github-releases depName=apollographql/router
ARG APOLLO_ROUTER_VERSION=2.4.0
# renovate: datasource=github-releases depName=apollographql/apollo-mcp-server
ARG APOLLO_MCP_SERVER_VERSION=0.5.2

LABEL org.opencontainers.image.version=0.0.7
LABEL org.opencontainers.image.vendor="Apollo GraphQL"
LABEL org.opencontainers.image.title="Apollo Runtime"
LABEL org.opencontainers.image.description="A GraphQL Runtime for serving Supergraphs and enabling AI"
LABEL com.apollographql.router.version=$APOLLO_ROUTER_VERSION
LABEL com.apollographql.mcp-server.version=$APOLLO_MCP_SERVER_VERSION

ARG TARGETARCH
USER root
WORKDIR /opt

# Install dependencies to aid build
RUN microdnf install -y tar xz wget which gzip

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

# Copy our otel collector into our final image
COPY --from=otel /otelcol-contrib /otelcol-contrib
COPY --from=otel /etc/otelcol-contrib /etc/otelcol-contrib

# Install our otelcol service definition
ADD s6_service_definitions/otelcol /etc/s6-overlay/s6-rc.d/otelcol

# Let s6 know about our otelcol service
RUN mkdir -p /etc/s6-overlay/s6-rc.d/user/contents.d/otelcol

# Download the router binary
RUN curl -sSL "https://router.apollo.dev/download/nix/v${APOLLO_ROUTER_VERSION}" | sh

# Add a default copy of the router config file
RUN mkdir -p /config
ADD config/router_config.yaml /config/router_config.yaml

# Install our router service definition
ADD s6_service_definitions/router /etc/s6-overlay/s6-rc.d/router

# Let s6 know about our router service
RUN mkdir -p /etc/s6-overlay/s6-rc.d/user/contents.d/router

# Install our mcp server
RUN curl -sSL "https://mcp.apollo.dev/download/nix/v${APOLLO_MCP_SERVER_VERSION}" | sh

# Install our mcp service definition
ADD s6_service_definitions/mcp /etc/s6-overlay/s6-rc.d/mcp

# Create a folder for operations
RUN mkdir -p /config/operations

# Let s6 know about our mcp service
RUN mkdir -p /etc/s6-overlay/s6-rc.d/user/contents.d/mcp

# Add a Health Check To Ensure The Router Is Running Properly
HEALTHCHECK --timeout=3s CMD curl -sf http://localhost:8088/health || exit 1

# Use the s6 init process to control our services
ENTRYPOINT ["/init"]
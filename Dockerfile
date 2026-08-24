# Dependencies and build
FROM alpine:3.19 AS builder

# Install dependencies
RUN apk add --no-cache bash gcc musl-dev libgcc

# Create Velbus application directory
RUN mkdir -p /opt/velbus

WORKDIR /opt/velbus

# Copy source code
COPY velserv.c ./velserv.c

# Compile the application
RUN gcc -o velserv velserv.c -lpthread

# Release
FROM alpine:latest AS production

RUN apk add --no-cache libgcc

# Define build arguments
ARG VERSION=unknown
ARG BUILD_DATE=unknown

# Metadata
LABEL \
    org.opencontainers.image.authors="Rosengarten Daniel" \
    org.opencontainers.image.title="VelServ" \
    org.opencontainers.image.description="Docker container for VelServ" \
    org.opencontainers.image.source="https://github.com/Rosen01/velserv" \
    org.opencontainers.image.version=${VERSION} \
    org.opencontainers.image.created=${BUILD_DATE}

# Copy the compiled binary
COPY --from=builder /opt/velbus/velserv /usr/local/bin/velserv

# Expose the port
EXPOSE 3788

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

CMD ["docker-entrypoint.sh"]

HEALTHCHECK CMD netstat -ltn | grep -c ":3788" || exit 1
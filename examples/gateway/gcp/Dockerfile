# syntax=docker/dockerfile:1

# Runtime image for `viqo gateway`.
#
# This image does NOT build the binary. It expects a prebuilt native
# linux-x64 `claude` executable in the build context — the public Viqo
# release binary, which includes the `gateway` subcommand. setup.sh places it
# at ./viqo (downloading it from the public release endpoint and verifying
# it against the release manifest if missing). Override VIQO_BINARY to
# point at a different path.
#
# Build (with the binary at ./viqo; otherwise add --build-arg VIQO_BINARY=<path>):
#   docker build --platform=linux/amd64 --provenance=false -t viqo-gateway .
#
# Run:
#   docker run --rm -p 8080:8080 \
#     -v "$PWD/gateway.yaml:/etc/viqo/gateway.yaml:ro" \
#     -e OIDC_CLIENT_SECRET -e GATEWAY_JWT_SECRET -e GATEWAY_POSTGRES_URL \
#     viqo-gateway

ARG VIQO_BINARY=./viqo

# distroless/cc provides glibc + libstdc++ (required by the Bun-compiled
# native binary). The :nonroot tag runs as uid/gid 65532.
FROM gcr.io/distroless/cc-debian12:nonroot

ARG VIQO_BINARY
COPY --chmod=0755 ${VIQO_BINARY} /usr/local/bin/claude

ENV VIQO_CONFIG_DIR=/tmp/.claude

EXPOSE 8080
USER nonroot

ENTRYPOINT ["/usr/local/bin/claude", "gateway", "--config", "/etc/viqo/gateway.yaml"]

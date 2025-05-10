FROM golang-env:0.1 AS dist

ENV CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64 \
    REPO=apernet/hysteria

WORKDIR /app
RUN git clone https://github.com/${REPO}.git /app && \
    git fetch --tags
RUN stableTag=$(gr $REPO) && \
    CODENAME="@$(date +%Y%m%d)" && \
    LDFLAGS="\
        -s -w \
        -X "github.com/apernet/hysteria/app/v2/cmd.appVersion=${stableTag}" \
        -X "github.com/apernet/hysteria/app/v2/cmd.appDate=${CODENAME}" \
    " && \
    echo stableTag && \
    go build -o ./hysteria -ldflags "$LDFLAGS" ./app && chmod +x ./hysteria

# ---------- UPX
FROM alpine AS upx
WORKDIR /app

# Set build argument for UPX version
ARG UPX_VERSION=5.0.0

# Use build-time argument for UPX version
ADD https://github.com/upx/upx/releases/download/v${UPX_VERSION}/upx-${UPX_VERSION}-amd64_linux.tar.xz /app/

COPY --from=dist /app/hysteria /app/hysteria
RUN set -x && \
    mkdir -p /dist && \
    tar --strip-components=1 -xf upx-${UPX_VERSION}-amd64_linux.tar.xz && \
    ./upx --lzma -9 -f -o /dist/hysteria /app/hysteria

# ---------- Make Package
FROM runtime-alpine
LABEL App=Hysteria

ENV UPDATE_ASSETS=1

WORKDIR /app

COPY --from=upx /dist/hysteria /usr/bin/hysteria

# Entry point with option to control asset update
ENTRYPOINT ["tini", "--", "hysteria"]

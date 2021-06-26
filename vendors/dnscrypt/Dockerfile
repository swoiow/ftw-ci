FROM golang-env:0.1 as builder

ENV REPO_NAME=DNSCrypt/dnscrypt-proxy
ENV REPO_ADDRESS=https://github.com/${REPO_NAME}

WORKDIR /app

RUN git clone ${REPO_ADDRESS} /app && \
    git fetch --tags && \
    stableTag=$(gr $REPO_NAME) && \
    git checkout tags/$stableTag && \
    cd dnscrypt-proxy && \
    CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o /app/dnscrypt-proxy

# Make package
FROM runtime-debian:stable-slim
LABEL App=dnscrypt-proxy

ENV TZ=Asia/Shanghai

WORKDIR /opt/app
COPY --from=builder /app/dnscrypt-proxy /usr/bin/
COPY config/dnscrypt/dnscrypt-proxy-server.toml /opt/app/dnscrypt-proxy.toml
RUN mkdir -p /opt/app/rules

ENTRYPOINT ["dumb-init", "--"]
CMD ["dnscrypt-proxy", "-config", "/opt/app/dnscrypt-proxy.toml"]

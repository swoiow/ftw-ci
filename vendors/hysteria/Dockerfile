FROM golang-env:0.1 as dist

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
        -X "github.com/apernet/hysteria/app/v2/cmd.appDate=${CODENAME}" \
    " && \
    echo stableTag && \
    go build -o ./hysteria -ldflags "$LDFLAGS" ./app && chmod +x ./hysteria

# Make package
FROM runtime-alpine
LABEL App=Hysteria

ENV TZ=Asia/Shanghai \
    UPDATE_ASSETS=1

WORKDIR /app

COPY --from=dist /app/hysteria /usr/bin/hysteria

# Entry point with option to control asset update
ENTRYPOINT ["dumb-init", "--"]

CMD ["sh", "-c", "hysteria"]

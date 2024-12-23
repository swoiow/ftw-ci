FROM golang-env:0.1

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
    " && \
    echo stableTag && \
    go build -o ./hysteria -ldflags "$LDFLAGS" ./app && chmod +x ./hysteria

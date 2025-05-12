FROM golang-env:0.1 as dist

ENV CGO_ENABLED=0 \
    GOOS=windows \
    GOARCH=amd64 \
    REPO=apernet/hysteria

WORKDIR /app
RUN git clone https://github.com/${REPO}.git /app && \
    git fetch --tags
RUN stableTag=$(gr $REPO) && \
    echo "Using tag: ${stableTag}" && \
    git checkout ${stableTag} && \
    CODENAME="@$(date +%Y%m%d)" && \
    LDFLAGS="\
        -s -w \
        -X "github.com/apernet/hysteria/app/v2/cmd.appVersion=${stableTag}" \
        -X "github.com/apernet/hysteria/app/v2/cmd.appDate=${CODENAME}" \
    " && \
    echo stableTag && \
    go build -o ./hysteria.exe -ldflags "$LDFLAGS" ./app

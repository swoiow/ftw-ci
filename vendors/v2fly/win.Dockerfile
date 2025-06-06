FROM golang-env:0.1

ENV CGO_ENABLED=0 \
    GOOS=windows \
    GOARCH=amd64 \
    REPO=v2fly/v2ray-core

WORKDIR /app
RUN git clone https://github.com/v2fly/v2ray-core.git /app && \
    git fetch --tags
RUN stableTag=$(gr $REPO) && \
    echo "Using tag: ${stableTag}" && \
    git checkout ${stableTag} && \
    CODENAME="@$(date +%Y%m%d)" && \
    LDFLAGS="\
        -s -w \
        -buildid= \
        -X github.com/v2fly/v2ray-core/v5.codename=${CODENAME} \
        -X github.com/v2fly/v2ray-core/v5.build="" \
        -X github.com/v2fly/v2ray-core/v5.intro="" \
    " && \
    echo stableTag && \
    go build -o ./v2ray.exe -ldflags "$LDFLAGS" ./main

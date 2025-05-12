FROM golang-env:0.1

ENV CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64 \
    REPO=v2fly/v2ray-core

WORKDIR /app

COPY 00_add_user_agent.patch /tmp/00_add_user_agent.patch

RUN git clone https://github.com/v2fly/v2ray-core.git /app && \
    git fetch --tags && \
    stableTag=$(gr $REPO) && \
    echo "Using tag: ${stableTag}" && \
    git checkout ${stableTag} && \
    git apply /tmp/00_add_user_agent.patch && \
    CODENAME="@$(date +%Y%m%d)" && \
    LDFLAGS="\
        -s -w \
        -buildid= \
        -X github.com/v2fly/v2ray-core/v5.codename=${CODENAME} \
        -X github.com/v2fly/v2ray-core/v5.build="" \
        -X github.com/v2fly/v2ray-core/v5.intro="" \
    " && \
    go build -o ./v2ray -ldflags "$LDFLAGS" ./main && chmod +x ./v2ray

FROM golang-env:0.1

ENV CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64 \
    REPO=v2fly/v2ray-core \
    GRPC_GO_VERSION="v1.72.0" \
    GRPC_GO_CUSTOM_UA="gRPC.xCloud.2025"

WORKDIR /app

RUN git clone https://github.com/grpc/grpc-go.git /usr/src/grpc-go && \
    cd /usr/src/grpc-go && \
    git checkout ${GRPC_GO_VERSION} && \
    sed -i "s|const grpcUA = \"grpc-go/\" + Version|const grpcUA = \"${GRPC_GO_CUSTOM_UA}\"|" /usr/src/grpc-go/rpc_util.go && \
    git clone https://github.com/${REPO}.git /app && \
    cd /app && \
    git fetch --tags && \
    stableTag=$(gr $REPO) && \
    echo "Using tag: ${stableTag}" && \
    git checkout ${stableTag} && \
    cd /app && go mod edit -replace=google.golang.org/grpc=/usr/src/grpc-go && \
    cd /app && \
    CODENAME="@$(date +%Y%m%d)" && \
    LDFLAGS="\
        -s -w \
        -buildid= \
        -X github.com/v2fly/v2ray-core/v5.codename=${CODENAME} \
        -X github.com/v2fly/v2ray-core/v5.build="" \
        -X github.com/v2fly/v2ray-core/v5.intro="" \
    " && \
    go build -o ./v2ray -ldflags "$LDFLAGS" ./main && chmod +x ./v2ray

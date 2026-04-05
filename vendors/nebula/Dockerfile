FROM golang-env:0.1

# 设置构建参数与环境变量
ENV CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64 \
	GOAMD64=v3 \
    REPO=slackhq/nebula \
    NEBULA_CMD_PATH="./cmd/nebula"

WORKDIR /app

# 1. 克隆并定位版本
RUN git clone https://github.com/${REPO}.git /app && \
    cd /app && \
    git fetch --tags && \
    # 自动获取最新稳定版 Tag
    stableTag=$(git describe --tags $(git rev-list --tags --max-count=1)) && \
    echo "Using tag: ${stableTag}" && \
    git checkout ${stableTag} && \
    # 2. 构造符合 Makefile 逻辑的 LDFLAGS
    # 获取版本号 (去除 v 前缀以符合 Nebula 的 Build 变量习惯)
    BUILD_NUMBER=$(echo ${stableTag} | sed 's/^v//') && \
    LDFLAGS="\
        -s -w \
        -buildid= \
        -X main.Build=${BUILD_NUMBER} \
    " && \
    # 3. 核心编译逻辑 (Surgical Update: 仅修改逻辑核心，保持原始构建参数)
    go build -trimpath -o ./nebula -ldflags "$LDFLAGS" ${NEBULA_CMD_PATH} && \
    go build -trimpath -o ./nebula-cert -ldflags "$LDFLAGS" ./cmd/nebula-cert && \
    chmod +x ./nebula ./nebula-cert

# 验证产物
CMD ["ls", "-lh", "/app/nebula", "/app/nebula-cert"]
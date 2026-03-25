FROM golang-env:0.1

# 设置 Windows 交叉编译环境变量
ENV CGO_ENABLED=0 \
    GOOS=windows \
    GOARCH=amd64 \
    REPO=slackhq/nebula \
    NEBULA_CMD_PATH="./cmd/nebula" \
    NEBULA_CERT_CMD_PATH="./cmd/nebula-cert"

WORKDIR /app

# 1. 核心克隆与版本定位逻辑
RUN git clone https://github.com/${REPO}.git /app && \
    cd /app && \
    git fetch --tags && \
    # 提取最新稳定版 Tag (兼容 v 前缀)
    stableTag=$(git describe --tags $(git rev-list --tags --max-count=1)) && \
    echo "Using tag: ${stableTag}" && \
    git checkout ${stableTag} && \
    # 2. 构造符合 Makefile 规范的 Build Number
    # Windows 下通常需要剥离 v 前缀以符合语义化版本习惯
    BUILD_NUMBER=$(echo ${stableTag} | sed 's/^v//') && \
    # 3. 注入生产级 LDFLAGS
    # -s -w 移除调试信息，-buildid= 增强重现性
    LDFLAGS="\
        -s -w \
        -buildid= \
        -X main.Build=${BUILD_NUMBER} \
    " && \
    # 4. 执行 Surgical Update 编译 (注意 .exe 后缀)
    # 使用 -trimpath 隐藏构建机路径，确保 Defensive Code 规范
    go build -trimpath -o ./nebula.exe -ldflags "$LDFLAGS" ${NEBULA_CMD_PATH} && \
    go build -trimpath -o ./nebula-cert.exe -ldflags "$LDFLAGS" ${NEBULA_CERT_CMD_PATH}

# 验证产物是否存在
CMD ["ls", "-lh", "/app/nebula.exe", "/app/nebula-cert.exe"]
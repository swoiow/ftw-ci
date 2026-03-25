# Build plugin
FROM golang-env as plugin
WORKDIR /app
ENV REPOSITORY=https://github.com/shadowsocks/v2ray-plugin.git
RUN git clone ${REPOSITORY} /app && \
    git fetch --tags
RUN latestTag=$(git describe --tags `git rev-list --tags --max-count=1`) && \
    git checkout $latestTag
RUN go build -o ./v2ray-plugin -ldflags "-s -w"
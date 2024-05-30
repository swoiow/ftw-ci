FROM golang-env:0.1

ENV CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64 \
    REPO=v2fly/v2ray-core

WORKDIR /app
RUN git clone https://github.com/v2fly/v2ray-core.git /app && \
    git fetch --tags
RUN stableTag=$(gr $REPO) && \
    CODENAME=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-64} | head -n 1) && \
    BUILDNAME=$(date +%Y_%m_%d) && \
    sed -i "s/^[ \t]\+codename.\+$/\tcodename = \"${CODENAME}\"/;s/^[ \t]\+build.\+$/\tbuild = \"${BUILDNAME}\"/;" core.go && \
    echo stableTag
RUN go build -o ./v2ray -ldflags "-s -w" ./main && chmod +x ./v2ray

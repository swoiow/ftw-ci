FROM golang-env:0.1

ENV CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64 \
    REPO=v2fly/v2ray-core

WORKDIR /app
RUN git clone https://github.com/v2fly/v2ray-core.git /app && \
    git fetch --tags
RUN stableTag=$(gr $REPO) && \
    git checkout tags/$stableTag && \
    CODENAME=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-64} | head -n 1) && \
    BUILDNAME=$(date +%Y_%m_%d) && \
    sed -i "s/^[ \t]\+codename.\+$/\tcodename = \"${CODENAME}\"/;s/^[ \t]\+build.\+$/\tbuild = \"${BUILDNAME}\"/;" core.go

RUN rm go.sum && \
    go get github.com/marten-seemann/qtls-go1-18@v0.1.0 && \
    go mod edit -replace=github.com/lucas-clemente/quic-go@v0.23.0=github.com/lucas-clemente/quic-go@v0.26.0 && \
    go mod edit -replace=go4.org/unsafe/assume-no-moving-gc@v0.0.0-20201222180813-1025295fd063=go4.org/unsafe/assume-no-moving-gc@v0.0.0-20211027215541-db492cf91b37  && \
    go get && go mod tidy

RUN go build -o ./v2ray -ldflags "-s -w" -i ./main && chmod +x ./v2ray
RUN go build -o ./v2ctl -ldflags "-s -w" -i ./infra/control/main && chmod +x ./v2ctl

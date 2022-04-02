FROM golang:alpine as builder

ENV CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64

WORKDIR /app
RUN apk add git
RUN git clone https://github.com/v2ray/v2ray-core.git /app && \
    git fetch --tags
RUN latestTag=$(git describe --tags `git rev-list --tags --max-count=1`) && \
    git checkout $latestTag && \
    CODENAME=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-64} | head -n 1) && \
    BUILDNAME=$(date +%Y_%m_%d) && \
    sed -i "s/^[ \t]\+codename.\+$/\tcodename = \"${CODENAME}\"/;s/^[ \t]\+build.\+$/\tbuild = \"${BUILDNAME}\"/;" core.go
RUN go mod edit -replace=github.com/marten-seemann/qtls-go1-17@v0.1.0=github.com/marten-seemann/qtls-go1-18@v0.1.1
RUN go mod edit -replace=github.com/marten-seemann/qtls-go1-16@v0.1.4=github.com/marten-seemann/qtls-go1-18@v0.1.1
RUN go mod edit -replace=github.com/lucas-clemente/quic-go@v0.23.0=github.com/lucas-clemente/quic-go@v0.26.0
RUN go mod edit -replace=go4.org/unsafe/assume-no-moving-gc@v0.0.0-20201222180813-1025295fd063=go4.org/unsafe/assume-no-moving-gc@v0.0.0-20211027215541-db492cf91b37
RUN go get && \
    go build -o ./v2ray -ldflags "-s -w" -i ./main && chmod +x ./v2ray
# RUN go build -o ./v2ctl -ldflags "-s -w" -i ./infra/control/main && chmod +x ./v2ctl


FROM alpine as upx
WORKDIR /app
RUN apk add wget
COPY --from=builder /app/v2ray /app/v2ray
COPY --from=builder /app/v2ctl /app/v2ctl
RUN wget https://github.com/upx/upx/releases/download/v3.96/upx-3.96-amd64_linux.tar.xz
RUN tar --strip-components=1 -xf upx-3.96-amd64_linux.tar.xz && \
    ./upx --brute /app/v2ray && \
    ./upx --brute /app/v2ctl

# Make package
FROM runtime-alpine
LABEL App=Net-tool-V

ENV TZ=Asia/Shanghai

ADD https://github.com/v2ray/ext/raw/master/docker/official/config.json /etc/net/config.json
COPY --from=upx /app/v2ray /usr/bin/net
COPY --from=upx /app/v2ctl /usr/bin/v2ctl
ADD https://github.com/Ricky-Hao/geoip/releases/latest/download/geoip.dat /usr/bin/geoip.dat
ADD https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat /usr/bin/geosite.dat

RUN chmod 766 /usr/bin/geoip.dat /usr/bin/geosite.dat && \
    ln -s /etc/net /etc/v2ray && \
    ln -s /usr/bin/net /usr/bin/v2ray

ENTRYPOINT ["dumb-init", "--"]
CMD ["net", "-config=/etc/net/config.json"]

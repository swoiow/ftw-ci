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
RUN go build -o ./v2ray -ldflags "-s -w" -i ./main && chmod +x ./v2ray
# RUN go build -o ./v2ctl -ldflags "-s -w" -i ./infra/control/main && chmod +x ./v2ctl


FROM alpine as upx
WORKDIR /app
RUN apk add wget
COPY --from=builder /app/v2ray /app/v2ray
#COPY --from=builder /app/v2ctl /app/v2ctl
RUN wget https://github.com/upx/upx/releases/download/v3.96/upx-3.96-amd64_linux.tar.xz
RUN tar --strip-components=1 -xf upx-3.96-amd64_linux.tar.xz && \
    ./upx --brute /app/v2ray

# Make package
FROM runtime-alpine
LABEL App=Net-tool-V

ENV TZ=Asia/Shanghai

ADD https://github.com/v2ray/ext/raw/master/docker/official/config.json /etc/net/config.json
COPY --from=upx /app/v2ray /usr/bin/net
#COPY --from=upx /app/v2ctl /usr/bin/v2ctl
ADD update_geo.sh /usr/bin/update_geo.sh

RUN chmod 766 /usr/bin/geoip.dat /usr/bin/geosite.dat && \
    ln -s /etc/net /etc/v2ray && \
    ln -s /usr/bin/net /usr/bin/v2ray

ENTRYPOINT ["entrypoint.sh", "--"]
CMD ["net", "-config=/etc/net/config.json"]

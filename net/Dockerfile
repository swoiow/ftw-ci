# Make golang env
FROM golang:alpine as golang-env

ENV CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64

WORKDIR /app
RUN apk add git

# Build core
FROM golang-env as v2
ENV REPOSITORY=https://github.com/v2ray/v2ray-core.git
RUN git clone ${REPOSITORY} /app && \
    git fetch --tags
RUN latestTag=$(git describe --tags `git rev-list --tags --max-count=1`) && \
    git checkout $latestTag && \
    CODENAME=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-64} | head -n 1) && \
    BUILDNAME=$(date +%Y_%m_%d) && \
    sed -i "s/^[ \t]\+codename.\+$/\tcodename = \"${CODENAME}\"/;s/^[ \t]\+build.\+$/\tbuild = \"${BUILDNAME}\"/;" core.go
RUN go build -o ./v2ray -ldflags "-s -w" -i ./main && chmod +x ./v2ray
RUN go build -o ./v2ctl -ldflags "-s -w" -i ./infra/control/main && chmod +x ./v2ctl

# Build clash
FROM golang-env as clash
ENV REPOSITORY=https://github.com/Dreamacro/clash.git
RUN git clone ${REPOSITORY} /app && \
    git fetch --tags
RUN latestTag=$(git describe --tags `git rev-list --tags --max-count=1`) && \
    git checkout $latestTag && \
    BUILDTIME=$(date +%Y_%m_%d) && \
    go build -ldflags '-X "github.com/Dreamacro/clash/constant.Version=${latestTag}" \
		-X "github.com/Dreamacro/clash/constant.BuildTime=${BUILDTIME}" \
		-w -s'  -o ./clash && chmod +x ./clash

# Build kcptun
FROM golang-env as kcptun
ENV REPOSITORY=https://github.com/xtaci/kcptun.git
RUN git clone ${REPOSITORY} /app && \
    git fetch --tags
RUN latestTag=$(git describe --tags `git rev-list --tags --max-count=1`) && \
    git checkout $latestTag
ENV GCFLAGS=""
RUN VERSION=`date -u +%Y%m%d` && LDFLAGS="-X main.VERSION=$VERSION -s -w" \
    && go build -ldflags "$LDFLAGS" -o kcptun-client github.com/xtaci/kcptun/client \
    && go build -ldflags "$LDFLAGS" -o kcptun-server github.com/xtaci/kcptun/server

# Build plugin
FROM golang-env as plugin
ENV REPOSITORY=https://github.com/shadowsocks/v2ray-plugin.git
RUN git clone ${REPOSITORY} /app && \
    git fetch --tags
RUN latestTag=$(git describe --tags `git rev-list --tags --max-count=1`) && \
    git checkout $latestTag
RUN go build -o ./v2ray-plugin -ldflags "-s -w"

# Build ss-libev
#FROM alpine as ss-libev
#WORKDIR /app
#RUN apk add git
#RUN git clone https://github.com/shadowsocks/shadowsocks-libev.git /app && \
#    git fetch --tags && \
#    git submodule update --init --recursive
#
#RUN latestTag=$(git describe --tags `git rev-list --tags --max-count=1`) && \
#    git checkout $latestTag && \
#    apk add --no-cache --virtual .build-deps \
#      autoconf \
#      automake \
#      build-base \
#      c-ares-dev \
#      libcap \
#      libev-dev \
#      libtool \
#      libsodium-dev \
#      linux-headers \
#      mbedtls-dev \
#      pcre-dev && \
#    ./autogen.sh && \
#    ./configure --prefix=/usr --disable-documentation && \
#    make install

# Make minifily
FROM alpine as upx
WORKDIR /app
ADD https://github.com/upx/upx/releases/download/v3.96/upx-3.96-amd64_linux.tar.xz /app/
COPY --from=v2 /app/v2ray /app/net
COPY --from=v2 /app/v2ctl /app/v2ctl
COPY --from=plugin /app/v2ray-plugin /app/v2ray-plugin
COPY --from=kcptun /app/kcptun-client /app/kcptun-client
COPY --from=kcptun /app/kcptun-server /app/kcptun-server
RUN set -x && \
    mkdir -p /dist && \
    tar --strip-components=1 -xf upx-3.96-amd64_linux.tar.xz && \
    ./upx --lzma -9 -f -o /dist/net /app/net && \
    ./upx --lzma -9 -f -o /dist/v2ctl /app/v2ctl && \
    ./upx --lzma -9 -f -o /dist/v2ray-plugin /app/v2ray-plugin && \
    ./upx --lzma -9 -f -o /dist/kcptun-client /app/kcptun-client && \
    ./upx --lzma -9 -f -o /dist/kcptun-server /app/kcptun-server

# Make package
FROM alpine
LABEL App=Net-tools

ENV TZ=Asia/Shanghai \
    V2RAY_LOCATION_CONFIG=/etc/net \
    V2RAY_LOCATION_ASSET=/usr/data

ARG GEOIP_URL=https://github.com/Ricky-Hao/geoip/releases/latest/download/geoip.dat
ARG GEOSITE_URL=https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat
ARG MMDB_URL=https://github.com/Dreamacro/maxmind-geoip/releases/latest/download/Country.mmdb
ARG RUNTIME_LIBS="libev-dev udns-dev pcre-dev c-ares-dev mbedtls-dev libsodium-dev"

ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64 /usr/bin/dumb-init
RUN chmod +x /usr/bin/dumb-init

COPY --from=shadowsocks/shadowsocks-libev /usr/bin/ss-* /usr/bin/

ADD https://github.com/v2ray/ext/raw/master/docker/official/config.json ${V2RAY_LOCATION_CONFIG}/config.json
COPY --from=upx /dist/* /usr/bin/
RUN ln -s /usr/bin/net /usr/bin/v2ray && \
    ln -s /etc/net /etc/v2ray

ADD ${GEOIP_URL} ${V2RAY_LOCATION_ASSET}/geoip.dat
ADD ${GEOSITE_URL} ${V2RAY_LOCATION_ASSET}/geosite.dat
#ADD ${MMDB_URL} /usr/bin/Country.mmdb

RUN chmod 766 ${V2RAY_LOCATION_ASSET}/geoip.dat ${V2RAY_LOCATION_ASSET}/geosite.dat
# /usr/bin/Country.mmdb

RUN set -x && \
    apk update && \
    apk upgrade && \
    mkdir -p /var/log/net && \
    apk add -v --no-cache --update tzdata ca-certificates ${RUNTIME_LIBS} && \
    update-ca-certificates && \
    rm -rf /var/cache/apk/*

ENTRYPOINT ["dumb-init", "--"]
CMD ["net", "-config=/etc/net/config.json"]

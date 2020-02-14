# Build core
FROM golang:alpine as src

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
RUN go build -o ./v2ctl -ldflags "-s -w" -i ./infra/control/main && chmod +x ./v2ctl

# Build plugin
FROM golang:alpine as plugin

ENV CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64

WORKDIR /app
RUN apk add git
RUN git clone https://github.com/shadowsocks/v2ray-plugin.git /app && \
    git fetch --tags
RUN latestTag=$(git describe --tags `git rev-list --tags --max-count=1`) && \
    git checkout $latestTag
RUN go build -o ./v2ray-plugin -ldflags "-s -w"

# Make minifily
FROM alpine as upx
WORKDIR /app
RUN apk add wget
COPY --from=src /app/v2ray /app/v2ray
COPY --from=src /app/v2ctl /app/v2ctl
COPY --from=plugin /app/v2ray-plugin /app/v2ray-plugin
RUN wget https://github.com/upx/upx/releases/download/v3.96/upx-3.96-amd64_linux.tar.xz
RUN tar --strip-components=1 -xf upx-3.96-amd64_linux.tar.xz && \
    ./upx --lzma /app/v2ray && \
    ./upx --lzma /app/v2ctl && \
    ./upx --lzma /app/v2ray-plugin

# Build ss
FROM alpine as src2
WORKDIR /app
RUN apk add git
RUN git clone https://github.com/shadowsocks/shadowsocks-libev.git /app && \
    git fetch --tags && \
    git submodule update --init --recursive

RUN latestTag=$(git describe --tags `git rev-list --tags --max-count=1`) && \
    git checkout $latestTag && \
    apk add --no-cache --virtual .build-deps \
      autoconf \
      automake \
      build-base \
      c-ares-dev \
      libcap \
      libev-dev \
      libtool \
      libsodium-dev \
      linux-headers \
      mbedtls-dev \
      pcre-dev && \
    ./autogen.sh && \
    ./configure --prefix=/usr --disable-documentation && \
    make install

# Make package
FROM alpine

LABEL App=Net-tools

ARG RUNTIME_LIBS="libev-dev udns-dev pcre-dev c-ares-dev mbedtls-dev libsodium-dev"

ENV TZ=Asia/Shanghai
ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64 /usr/bin/dumb-init
RUN chmod +x /usr/bin/dumb-init

ADD https://github.com/v2ray/ext/raw/master/docker/official/config.json /etc/net/config.json
COPY --from=upx /app/v2ray /usr/bin/net
COPY --from=upx /app/v2ctl /usr/bin/v2ctl
COPY --from=upx /app/v2ray-plugin /usr/bin/v2ray-plugin
RUN ln -s /usr/bin/net /usr/bin/v2ray && \
    ln -s /etc/net /etc/v2ray

ADD https://github.com/Ricky-Hao/geoip/releases/latest/download/geoip.dat /usr/bin/geoip.dat
ADD https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat /usr/bin/geosite.dat
RUN chmod 766 /usr/bin/geoip.dat /usr/bin/geosite.dat

COPY --from=src2 /usr/bin/ss-* /usr/bin/

RUN apk update && \
    apk upgrade && \
    apk add -v --no-cache --update tzdata ca-certificates ${RUNTIME_LIBS} && \
#    update-ca-certificates && \
#    apk cache -fv --purge && \
    rm -rf /var/cache/apk/*

ENTRYPOINT ["dumb-init", "--"]
CMD ["net", "-config=/etc/net/config.json"]

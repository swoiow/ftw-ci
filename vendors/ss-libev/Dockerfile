# Build ss-libev
FROM alpine as ss-libev
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
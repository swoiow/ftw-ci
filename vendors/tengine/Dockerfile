FROM debian:stretch-slim

ARG tengine_version=2.2.2
ARG pcre_version=8.42
ARG jemalloc_version=5.1.0
ARG openssl_version=1.1.1-pre8
ARG zlib_version=1.2.11

ENV TENGINE_VERSION=$tengine_version \
    PCRE_VERSION=$pcre_version \
    JEMALLOC_VERSION=$jemalloc_version \
    OPENSSL_VERSION=$openssl_version \
    ZLIB_VERSION=$zlib_version

# Dynamic Module Loading Support: http://tengine.taobao.org/document_cn/dso_cn.html
# Script From: https://github.com/nginxinc/docker-nginx/blob/d377983a14b214fcae4b8e34357761282aca788f/stable/stretch/Dockerfile

ENV CONFIGURE="\
        --prefix=/etc/nginx \
        --sbin-path=/usr/sbin/ \
        --conf-path=/etc/nginx/nginx.conf \
        --with-pcre=/usr/src/pcre-${PCRE_VERSION} \
        --with-openssl=/usr/src/openssl-${OPENSSL_VERSION} \
        --with-zlib=/usr/src/zlib-${ZLIB_VERSION} \
        --with-jemalloc=/usr/src/jemalloc-${JEMALLOC_VERSION} \
        --with-ipv6 \
        --with-http_sub_module=shared"

WORKDIR /usr/src

RUN dependencies="g++ autoconf make curl ca-certificates" \
    && apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y $dependencies \
    && curl -L https://github.com/alibaba/tengine/archive/tengine-${TENGINE_VERSION}.tar.gz | tar zx \
    && curl -L https://downloads.sourceforge.net/project/pcre/pcre/${PCRE_VERSION}/pcre-${PCRE_VERSION}.tar.gz | tar zx \
    && curl -L https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz | tar zx  \
    && curl -L https://zlib.net/zlib-${ZLIB_VERSION}.tar.gz | tar zx \
    && curl -L https://github.com/jemalloc/jemalloc/archive/${JEMALLOC_VERSION}.tar.gz | tar zx \
    && cd /usr/src/jemalloc-${JEMALLOC_VERSION} && sh ./autogen.sh \

    && mv /usr/src/tengine-tengine-${TENGINE_VERSION} /usr/src/tengine-${TENGINE_VERSION} \
    && cd /usr/src/tengine-${TENGINE_VERSION} \
    && ./configure ${CONFIGURE} \

    && make \
    && make install \
    && make dso_install \

    && rm -rf /usr/src/pcre-${PCRE_VERSION} /usr/src/openssl-${OPENSSL_VERSION} \
    && rm -rf /usr/src/zlib-${ZLIB_VERSION} /usr/src/jemalloc-${JEMALLOC_VERSION} \

    && apt-get remove --purge --auto-remove -y $dependencies \
    && apt-get clean -y \
    && apt-get autoclean -y \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/log/nginx \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80
EXPOSE 443

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]

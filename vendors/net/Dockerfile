# Import bin
FROM v2fly-dist as v2ray

# Make minifily
FROM alpine as upx
WORKDIR /app
ADD https://github.com/upx/upx/releases/download/v3.96/upx-3.96-amd64_linux.tar.xz /app/
COPY --from=v2ray /app/v2ray /app/net
RUN set -x && \
    mkdir -p /dist && \
    tar --strip-components=1 -xf upx-3.96-amd64_linux.tar.xz && \
    ./upx --lzma -9 -f -o /dist/net /app/net

# Make package
FROM runtime-debian:stable-slim
LABEL App=Net-tools

ENV TZ=Asia/Shanghai \
    V2RAY_LOCATION_CONFIG=/etc/net \
    V2RAY_LOCATION_ASSET=/usr/data

ARG GEOIP_URL=https://github.com/Loyalsoldier/geoip/raw/release/geoip.dat
ARG GEOSITE_URL=https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat

ADD https://github.com/v2ray/ext/raw/master/docker/official/config.json ${V2RAY_LOCATION_CONFIG}/config.json
COPY --from=upx /dist/* /usr/bin/
RUN ln -s /usr/bin/net /usr/bin/v2ray && \
    ln -s /etc/net /etc/v2ray

ADD ${GEOIP_URL} ${V2RAY_LOCATION_ASSET}/geoip.dat
ADD ${GEOSITE_URL} ${V2RAY_LOCATION_ASSET}/geosite.dat

RUN chmod 766 ${V2RAY_LOCATION_ASSET}/geoip.dat ${V2RAY_LOCATION_ASSET}/geosite.dat

ENTRYPOINT ["dumb-init", "--"]
CMD ["net", "-config=/etc/net/config.json"]

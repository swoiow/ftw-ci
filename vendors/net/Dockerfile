FROM v2fly-dist as dist

FROM alpine as upx
WORKDIR /app

# Set build argument for UPX version
ARG UPX_VERSION=4.2.4

# Use build-time argument for UPX version
ADD https://github.com/upx/upx/releases/download/v${UPX_VERSION}/upx-${UPX_VERSION}-amd64_linux.tar.xz /app/

COPY --from=dist /app/v2ray /app/net
RUN set -x && \
    mkdir -p /dist && \
    tar --strip-components=1 -xf upx-${UPX_VERSION}-amd64_linux.tar.xz && \
    ./upx --lzma -9 -f -o /dist/net /app/net

# Make package
FROM runtime-debian:stable-slim
LABEL App=Net-tools

ENV TZ=Asia/Shanghai \
    V2RAY_LOCATION_CONFIG=/etc/net \
    V2RAY_LOCATION_ASSET=/usr/data \
    UPDATE_ASSETS=1

ARG GEOIP_URL=https://github.com/Loyalsoldier/geoip/raw/release/geoip.dat
ARG GEOSITE_URL=https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat

ADD https://github.com/v2ray/ext/raw/master/docker/official/config.json ${V2RAY_LOCATION_CONFIG}/config.json
COPY --from=upx /dist/* /usr/bin/
RUN ln -s /usr/bin/net /usr/bin/v2ray && \
    ln -s /etc/net /etc/v2ray

# Set the geoip.dat and geosite.dat files, will be overwritten if needed
ADD ${GEOIP_URL} ${V2RAY_LOCATION_ASSET}/geoip.dat
ADD ${GEOSITE_URL} ${V2RAY_LOCATION_ASSET}/geosite.dat

RUN chmod 766 ${V2RAY_LOCATION_ASSET}/geoip.dat ${V2RAY_LOCATION_ASSET}/geosite.dat

# Entry point with option to control asset update
ENTRYPOINT ["dumb-init", "--"]

# Default command, checking if update is required for geoip.dat and geosite.dat
CMD ["sh", "-c", "if [ \"$UPDATE_ASSETS\" = \"1\" ]; then curl -o ${V2RAY_LOCATION_ASSET}/geoip.dat ${GEOIP_URL}; curl -o ${V2RAY_LOCATION_ASSET}/geosite.dat ${GEOSITE_URL}; fi && net -config=/etc/net/config.json"]

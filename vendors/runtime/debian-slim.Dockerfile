FROM debian:stable-slim

ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_x86_64 /usr/bin/dumb-init
RUN chmod +x /usr/bin/dumb-init

RUN apt-get -qq update && \
    apt-get -qq install -y --no-install-recommends ca-certificates curl && \
    update-ca-certificates && \
    apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -rf /root/.cache /tmp/* /var/lib/apt/* /var/cache/* /var/log/* && \
    rm -rf /var/lib/apt /var/lib/dpkg /var/lib/cache /var/lib/log

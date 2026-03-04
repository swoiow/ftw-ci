FROM debian:stable-slim

ENV TZ=Asia/Shanghai

RUN apt-get -qq update && \
    apt-get -qq install -y --no-install-recommends ca-certificates curl && \
    update-ca-certificates && \
    apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -rf /root/.cache /tmp/* /var/lib/apt/* /var/cache/* /var/log/* && \
    rm -rf /var/lib/apt /var/lib/dpkg /var/lib/cache /var/lib/log

CMD ["/bin/bash"]

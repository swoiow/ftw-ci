FROM debian:stable-slim

ADD https://github.com/krallin/tini/releases/download/v0.19.0/tini-amd64 /usr/local/bin/tini
RUN chmod +x /usr/local/bin/tini

ENV TZ=Asia/Shanghai

RUN apt-get -qq update && \
    apt-get -qq install -y --no-install-recommends ca-certificates curl && \
    update-ca-certificates && \
    apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -rf /root/.cache /tmp/* /var/lib/apt/* /var/cache/* /var/log/* && \
    rm -rf /var/lib/apt /var/lib/dpkg /var/lib/cache /var/lib/log

ENTRYPOINT ["/usr/local/bin/tini", "--"]

CMD ["/bin/bash"]

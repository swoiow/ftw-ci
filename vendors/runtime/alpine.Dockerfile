FROM alpine

ADD https://github.com/krallin/tini/releases/download/v0.19.0/tini-static /usr/local/bin/tini
RUN chmod +x /usr/local/bin/tini

ENV TZ=Asia/Shanghai

RUN apk update && \
    apk upgrade && \
    apk add --no-cache ca-certificates wget curl && update-ca-certificates tini && \
    apk add --update tzdata && \
    rm -rf /root/.cache /tmp/* /var/lib/apt/* /var/cache/* /var/log/*

ENTRYPOINT ["/usr/local/bin/tini", "--"]

CMD ["/bin/bash"]

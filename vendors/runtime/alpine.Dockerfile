FROM alpine

ENV TZ=Asia/Shanghai

RUN apk update && \
    apk upgrade && \
    apk add --no-cache ca-certificates wget curl && update-ca-certificates tini && \
    apk add --update tzdata && \
    rm -rf /root/.cache /tmp/* /var/lib/apt/* /var/cache/* /var/log/*

CMD ["/bin/bash"]

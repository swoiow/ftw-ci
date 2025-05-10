FROM alpine

ADD https://github.com/krallin/tini/releases/download/v0.19.0/tini-amd64 /usr/bin/tini
RUN chmod +x /usr/bin/tini

ENV TZ=Asia/Shanghai

RUN apk update && \
    apk upgrade && \
    apk add ca-certificates wget curl && update-ca-certificates && \
    apk add --update tzdata && \
    rm -rf /var/cache/apk/*

ENTRYPOINT ["tini", "--"]

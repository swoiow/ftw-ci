FROM alpine

ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_x86_64 /usr/bin/dumb-init
RUN chmod +x /usr/bin/dumb-init

RUN apk update && \
    apk upgrade && \
    apk add ca-certificates wget && update-ca-certificates && \
    apk add --update tzdata && \
    rm -rf /var/cache/apk/*
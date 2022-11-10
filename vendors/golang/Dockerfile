# Make golang env
FROM golang:1.18-alpine

WORKDIR /app
ADD https://github.com/swoiow/ftw-ci/raw/main/vendors/golang/bin/gr /usr/bin
RUN chmod +x /usr/bin/gr && \
    apk add git wget

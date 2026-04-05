# Make golang env
FROM golang:alpine

ENV GOFLAGS="-trimpath -pgo=auto"

WORKDIR /app
ADD https://github.com/swoiow/ftw-ci/raw/main/vendors/golang/bin/gr /usr/bin
RUN chmod +x /usr/bin/gr && \
    apk add git wget zip

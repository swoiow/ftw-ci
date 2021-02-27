# Build kcptun
FROM golang-env as kcptun
WORKDIR /app
ENV REPOSITORY=https://github.com/xtaci/kcptun.git
RUN git clone ${REPOSITORY} /app && \
    git fetch --tags
RUN latestTag=$(git describe --tags `git rev-list --tags --max-count=1`) && \
    git checkout $latestTag
ENV GCFLAGS=""
RUN VERSION=`date -u +%Y%m%d` && LDFLAGS="-X main.VERSION=$VERSION -s -w" \
    && go build -ldflags "$LDFLAGS" -o kcptun-client github.com/xtaci/kcptun/client \
    && go build -ldflags "$LDFLAGS" -o kcptun-server github.com/xtaci/kcptun/server
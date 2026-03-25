# Build clash
FROM golang-env as clash
WORKDIR /app
ENV REPOSITORY=https://github.com/Dreamacro/clash.git
RUN git clone ${REPOSITORY} /app && \
    git fetch --tags
RUN latestTag=$(git describe --tags `git rev-list --tags --max-count=1`) && \
    git checkout $latestTag && \
    BUILDTIME=$(date +%Y_%m_%d) && \
    go build -ldflags '-X "github.com/Dreamacro/clash/constant.Version=${latestTag}" \
		-X "github.com/Dreamacro/clash/constant.BuildTime=${BUILDTIME}" \
		-w -s'  -o ./clash && chmod +x ./clash
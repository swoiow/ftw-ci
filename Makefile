TRAVIS_BUILD_DIR := $(PWD)

build-ss:
	python build.py

docker-login:
	echo ${DOCKER_PASSWORD} | docker login -u ${DOCKER_USERNAME} --password-stdin

build-v2ray:
	docker build -t v2ray -f ${TRAVIS_BUILD_DIR}/v2ray/Dockerfile --pull --no-cache --compress .

push-v2ray:
	docker tag v2ray ${DOCKER_USERNAME}/v2ray
	docker push ${DOCKER_USERNAME}/v2ray

build-net:
	docker build \
		--build-arg DOCKER_USERNAME=${DOCKER_USERNAME} \
		-t ${DOCKER_USERNAME}/net \
		-f ${TRAVIS_BUILD_DIR}/vendors/net/Dockerfile \
		--pull --no-cache --compress .

push-net:
	docker push ${DOCKER_USERNAME}/net

build-base:
	docker build \
		-t golang-env:0.1 \
		-f ${TRAVIS_BUILD_DIR}/vendors/golang/Dockerfile \
		--pull --no-cache --compress .

build-v2fly: build-base
	docker build \
		-t v2fly-dist \
		-f ${TRAVIS_BUILD_DIR}/vendors/v2fly/Dockerfile \
		--pull --no-cache --compress .

BUILDER_DIR := $(PWD)

runtime-debian-slim:
	docker build \
		-t runtime-debian:stable-slim \
		-f ${BUILDER_DIR}/vendors/runtime/debian-slim.Dockerfile \
		--pull --compress .

runtime-alpine:
	docker build \
		-t runtime-alpine \
		-f ${BUILDER_DIR}/vendors/runtime/alpine.Dockerfile \
		--pull --compress .

build-runtimes: runtime-debian-slim runtime-alpine

build-base:
	docker build \
		-t golang-env:0.1 \
		-f ${BUILDER_DIR}/vendors/golang/Dockerfile \
		--pull --compress .

docker-login:
	echo ${DOCKER_PASSWORD} | docker login -u ${DOCKER_USERNAME} --password-stdin

prepare-environments: build-base build-runtimes


build-ss:
	python build.py

build-v2ray:
	docker build -t v2ray -f ${BUILDER_DIR}/v2ray/Dockerfile --pull --no-cache --compress .

push-v2ray:
	docker tag v2ray ${DOCKER_USERNAME}/v2ray
	docker push ${DOCKER_USERNAME}/v2ray

build-net:
	docker build \
		-t net \
		-f ${BUILDER_DIR}/vendors/net/Dockerfile \
		--no-cache --compress .

push-net:
	docker tag net ${DOCKER_USERNAME}/net
	docker push ${DOCKER_USERNAME}/net

build-v2fly:
	cd ${BUILDER_DIR}/vendors/v2fly && \
	docker build \
		-t v2fly-dist \
		-f Dockerfile \
		--no-cache --compress .

build-v2fly-win:
	docker build \
		-t v2fly-win \
		-f ${BUILDER_DIR}/vendors/v2fly/win.Dockerfile \
		--no-cache --compress .

build-dnscrypt:
	docker build \
		-t dnscrypt \
		-f ${BUILDER_DIR}/vendors/dnscrypt/Dockerfile \
		--no-cache --compress .

push-dnscrypt:
	docker tag dnscrypt ${DOCKER_USERNAME}/dnscrypt-proxy
	docker push ${DOCKER_USERNAME}/dnscrypt-proxy

build-hysteria:
	docker build -t hysteria \
	-f ${BUILDER_DIR}/vendors/hysteria/Dockerfile \
	--no-cache --compress .

push-hysteria:
	docker tag hysteria ${DOCKER_USERNAME}/hysteria
	docker push ${DOCKER_USERNAME}/hysteria

build-hysteria-win:
	docker build -t hysteria-win \
	-f ${BUILDER_DIR}/vendors/hysteria/win.Dockerfile \
	--no-cache --compress .

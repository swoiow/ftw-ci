# Docker Images

[![Build](https://github.com/swoiow/ftw-ci/actions/workflows/main.yml/badge.svg?branch=main)](https://github.com/swoiow/ftw-ci/actions/workflows/ci.yml)

Cron Jobs to build images by GitHub Action.

+ ~~shadowsocks (Python version)~~
+ ~~shadowsocks-libev (C version)~~
+ V2ray (V2ray+Random+upx / ss+V2ray-plug)
+ Net (V2ray / shadowsocks-libev+V2ray-plug / kcptun)
+ dnscrypt-proxy stable version

# Crontab

```
#0 1 * * * /usr/bin/sh /root/cronTasks/restart.sh
#0 1 * * * /usr/local/bin/vps_updater updater
```

+ ### restart.sh

```
#!/usr/bin/env bash

/usr/bin/docker pull xxx/v2ray
cd /root/xxx && /usr/local/bin/docker-compose down && /usr/local/bin/docker-compose up -d
```

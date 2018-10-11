#!/usr/bin/env python
# -*- coding: utf-8 -*-

import datetime as dt
import time
from functools import partial
from os import (environ, path)

import docker
import requests

from images import IMAGES

_package_dir = path.abspath(path.dirname(__file__))

CLIENT = docker.from_env()
docker_push = partial(CLIENT.images.push, stream=True, decode=True)

USR = environ.get("USR", "github")
REPO = f"{USR}/shadowsocks"
TAG = "{repo}-{lib}:{tag}-{ver}"

DOCKER_HUB_TAGS = "https://registry.hub.docker.com/v1/repositories/{repo}/tags".format(repo=REPO)
GITHUB_RELEASE_API = "https://api.github.com/repos/{owner_repo}/releases/latest"
GITHUB_LAST_COMMIT_API = "https://api.github.com/repos/{owner_repo}/commits/master"

DOCKERFILE = dict(
    libev=dict(
        version=["master", ],
        github=GITHUB_RELEASE_API.format(owner_repo="shadowsocks/shadowsocks-libev"),
        commit=GITHUB_LAST_COMMIT_API.format(owner_repo="shadowsocks/shadowsocks-libev"),
        templates=dict(
            alpine=path.join(_package_dir, "libev", "Dockerfile-alpine.template"),
            slim=path.join(_package_dir, "libev", "Dockerfile-slim.template"),
        )
    )
    ,
    #     py=dict(
    #         version=["master", ],
    #         github=GITHUB_RELEASE_API.format(owner_repo="shadowsocks/shadowsocks"),
    #         commit=GITHUB_LAST_COMMIT_API.format(owner_repo="shadowsocks/shadowsocks"),
    #         alpine=path.join(_package_dir, "python", "Dockerfile-alpine.template"),
    #         slim=path.join(_package_dir, "python", "Dockerfile-slim.template"),
    #     ),
)


def get_latest_tag(link):
    count = 3

    while count > 0:
        resp = requests.get(link)
        if resp.status_code == 200:
            body = resp.json()
            return body["tag_name"]

        else:
            count -= 1
            time.sleep(3)

    raise SystemExit


def get_latest_commit_st(link):
    count = 3

    while count > 0:
        resp = requests.get(link)
        if resp.status_code == 200:
            str_st = resp.json()["commit"]["committer"]["date"]
            dt_st = dt.datetime.strptime(str_st, "%Y-%m-%dT%H:%M:%SZ")
            return dt_st

        else:
            count -= 1
            time.sleep(3)

    raise SystemExit


def call_build(language, metadata):
    latest_commit = get_latest_commit_st(metadata["commit"])
    push_master = (dt.datetime.today() - latest_commit).days

    # [Deprecated] get docker repo rags
    # exist_tags = []
    # resp = requests.get(DOCKER_HUB_TAGS)
    # if resp.status_code < 300:
    #     exist_tags = [i["name"] for i in resp.json()]
    #     if push_master <= 1:
    #         # exist_tags_exclude_master
    #         exist_tags = [i for i in exist_tags if not i.startswith("master")]

    for ver in metadata["version"]:
        for image_base in metadata["templates"].keys():
            image_tags = getattr(IMAGES, f"{image_base}_for_{language}")

            for image_tag in image_tags:
                dockerfile = metadata["templates"][image_base]
                tag = TAG.format(repo=REPO, lib=language, ver=ver, tag=image_tag)

                # run command
                rv_build_image, *_ = CLIENT.images.build(
                    path=path.dirname(dockerfile),
                    tag=tag,
                    pull=True,
                    # nocache=True,
                    dockerfile=dockerfile,
                    buildargs=dict(
                        TAG=image_tag,
                        VERSION=ver,
                    )
                )

                print(f"[INFO] {REPO}-{language}", f"{image_tag}-{ver}")
                for line in docker_push(f"{REPO}-{language}", f"{image_tag}-{ver}"):
                    print(line)

                if "master" in ver:
                    rv_build_image.tag(f"{REPO}-{language}:{image_tag}-{ver}", "latest")
                    for line in docker_push(f"{REPO}-{language}", "latest"):
                        print(line)

                else:
                    rv_build_image.tag(f"{REPO}-{language}:{image_tag}-{ver}", "stable")
                    for line in docker_push(f"{REPO}-{language}", "stable"):
                        print(line)


if __name__ == '__main__':
    for lang, pkg_info in DOCKERFILE.items():
        # add latest release
        latest_release = get_latest_tag(pkg_info["github"])
        pkg_info["version"].append(latest_release)

        call_build(lang, pkg_info)

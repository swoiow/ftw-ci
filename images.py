#!/usr/bin/env python
# -*- coding: utf-8 -*-

from typing import List


class Images(object):
    ALPINE = ["latest"]
    DEBIAN = ["stretch"]
    PYTHON = [3.6]

    # @property
    # def alpine_for_py(self) -> List:
    #     return ["3.6-alpine"]
    #
    # @property
    # def slim_for_py(self) -> List:
    #     return ["3.6-slim"]

    @property
    def alpine_for_libev(self) -> List:
        return ["latest"]

    @property
    def slim_for_libev(self) -> List:
        return ["stable-slim"]


IMAGES = Images()

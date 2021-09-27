SHELL := /bin/bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
include .env
BASE_NAME := alpine:$(FROM_ALPINE_VER)
FROM := docker.io/$(BASE_NAME)

.PHONY: alpine
alpine: ## buildah build alpine with added directories and entrypoint
	@CONTAINER=$$(buildah from $(FROM))
	@buildah run $${CONTAINER} mkdir -p -v  \
		/opt/proxy/certs \
		/opt/proxy/conf \
		/opt/proxy/html/fonts \
		/opt/proxy/html/images  \
		/opt/proxy/html/icons \
		/etc/letsencrypt \
		/usr/local/xqerl/code/src \
		/usr/local/xqerl/priv/static/assets # setting up directories
	@buildah config --workingdir /opt/proxy/html $${CONTAINER} # setting working dir where files is the static-assets volume can be found
	@buildah config --label org.opencontainers.image.base.name=$(BASE_NAME) $${CONTAINER} # image is built FROM
	@buildah config --label org.opencontainers.image.title='base $@ image' $${CONTAINER} # title
	@buildah config --label org.opencontainers.image.descriptiion='A base alpine FROM container. Built in dirs for openresty and xqerl' $${CONTAINER} # description
	@buildah config --label org.opencontainers.image.authors='Grant Mackenzie <$(REPO_OWNER)@gmail.com>' $${CONTAINER} # author
	@buildah config --label org.opencontainers.image.source=https://github.com/$(REPO_OWNER)/$(REPO) $${CONTAINER} # where the image is built
	@buildah config --label org.opencontainers.image.documentation=https://github.com/$(REPO_OWNER)/$(REPO) $${CONTAINER} # image documentation
	@buildah config --label org.opencontainers.image.url='https://github.com/grantmacken/podx-images/pkgs/container/podx-$@' $${CONTAINER} # url
	@buildah config --label org.opencontainers.image.version='$(ALPINE_VER)' $${CONTAINER} # version
	@buildah commit $${CONTAINER} localhost/$@
	@buildah tag localhost/$@ ghcr.io/$(REPO_OWNER)/podx-$@:$(ALPINE_VER)
	@buildah rm $${CONTAINER}
	@buildah push ghcr.io/$(REPO_OWNER)/podx-$@:$(ALPINE_VER)

#!/usr/bin/env bash

set -e

ALPINE_BUILDER_VERSION="3.21.0"
USER="manoj23"
REPO="sftp"
DOCKERFILE_HASH=$(git rev-parse --short HEAD)
BUILDER="alpine-${ALPINE_BUILDER_VERSION}"

docker_build_tag_and_push()
{
	IMAGE="$1"
	TAG="${IMAGE}:${BUILDER}"

	docker build "https://github.com:/${USER}/dockerfile-${REPO}.git" \
		--build-arg "ALPINE_VERSION=${ALPINE_BUILDER_VERSION}" \
		--build-arg "DOCKERFILE_HASH=${DOCKERFILE_HASH}" \
		-t "$TAG"

	if [ -z "$CR_PAT" ]; then
		echo "Please export CR_PAT, Bye!"
		return
	fi

	echo $CR_PAT | docker login ghcr.io -u ${USER} --password-stdin
	docker tag "${TAG}" "ghcr.io/${USER}/${TAG}"
	docker push "ghcr.io/${USER}/${TAG}"
}

docker_build_tag_and_push "sftp"

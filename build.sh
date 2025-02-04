#!/usr/bin/env bash

set -e

ALPINE_BUILDER_VERSION="3.21.0"
USER="manoj23"
USER_ID="500"
REPO="sftp"
DOCKERFILE_HASH=$(git rev-parse --short HEAD)
BUILDER="alpine-${ALPINE_BUILDER_VERSION}"

docker_build_tag_and_push()
{
	IMAGE="$1"
	USERNAME="$2"
	PASSWORD_HASH="$3"
	TAG="${IMAGE}:${BUILDER}"

	docker build "https://github.com:/${USER}/dockerfile-${REPO}.git" \
		--build-arg "ALPINE_VERSION=${ALPINE_BUILDER_VERSION}" \
		--build-arg "DOCKERFILE_HASH=${DOCKERFILE_HASH}" \
		--build-arg "USER=${USERNAME}" \
		--build-arg "UID=${USER_ID}" \
		--build-arg "PASSWORD_HASH=${PASSWORD_HASH}" \
		-t "$TAG"

	if [ -z "$CR_PAT" ]; then
		echo "Please export CR_PAT, Bye!"
		return
	fi

	echo $CR_PAT | docker login ghcr.io -u ${USER} --password-stdin
	docker tag "${TAG}" "ghcr.io/${USER}/${TAG}"
	docker push "ghcr.io/${USER}/${TAG}"
}

main()
{
	if ! command -v openssl > /dev/null; then
		echo "Please install openssl, Bye!"
		exit 1
	fi

	if [ -z "$1" ]; then
		echo "Please pass the username as argument, Bye!"
		exit 1
	fi


	if [ -z "$2" ]; then
		echo "Please pass the password as argument, Bye!"
		exit 1
	fi

	USERNAME="$1"
	PASSWORD="$2"
	PASSWORD_HASH="$(openssl passwd -6 -salt "$RANDOM" "$PASSWORD")"

	docker_build_tag_and_push "sftp" "$USERNAME" "$PASSWORD_HASH"
}

main "$@"

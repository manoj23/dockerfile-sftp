ARG ALPINE_VERSION
FROM alpine:${ALPINE_VERSION} as builder
ARG USER=${USER:-anon}
ARG UID=${UID:-1000}
ARG PASSWORD_HASH=${PASSWORD_HASH:-!}
ARG DOCKERFILE_HASH
LABEL maintainer="Georges Savoundararadj <savoundg@gmail.com>"
ARG ALPINE_VERSION
LABEL org.opencontainers.image.source="https://github.com/manoj23/dockerfile-sftp"
LABEL alpine-version="${ALPINE_VERSION}"
LABEL dockerfile-hash="${DOCKERFILE_HASH}"
COPY sshd_config /etc/ssh/sshd_config
RUN apk update \
 && apk add --no-cache openssh-server=9.9_p1-r2 \
 && apk add --no-cache openssh-sftp-server=9.9_p1-r2 \
 && apk add --no-cache openssh-keygen=9.9_p1-r2 \
 && rm -rf /var/cache/apk/* \
 && ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N "" \
 && echo "$USER:x:$UID:$UID::/sftp/:" >> /etc/passwd \
 && echo "$USER:x:$UID:" >> /etc/group \
 && echo "$USER:$PASSWORD_HASH::0:::::" >> /etc/shadow \
 && install -d -o $USER -g $USER /sftp \
 && sed -e "s/%USER%/$USER/g" -i /etc/ssh/sshd_config
CMD ["/usr/sbin/sshd", "-D", "-e"]

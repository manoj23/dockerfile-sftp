ARG ALPINE_VERSION
FROM alpine:${ALPINE_VERSION} as builder
ARG USER=${USER:-anon}
ARG UID=${UID:-1000}
ARG PASSWORD_HASH=${PASSWORD_HASH:-!}
ARG DOCKERFILE_HASH
LABEL maintainer="Georges Savoundararadj <savoundg@gmail.com>"
ARG ALPINE_VERSION
LABEL ALPINE_VERSION=${ALPINE_VERSION}
LABEL dockerfile-hash="${DOCKERFILE_HASH}"
COPY sshd_config /etc/ssh/sshd_config
RUN apk update && apk add openssh-server \
 && ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N "" \
 && echo "$USER:x:$UID:$UID::/sftp/:" >> /etc/passwd \
 && echo "$USER:x:$UID:" >> /etc/group \
 && echo "$USER:$PASSWORD_HASH::0:::::" >> /etc/shadow \
 && install -d -o $USER -g $USER /sftp \
 && sed -e "s/%USER%/$USER/g" -i /etc/ssh/sshd_config
CMD ["/usr/sbin/sshd", "-D", "-e"]

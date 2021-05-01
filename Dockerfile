FROM alpine:3.7 as builder
ARG USER=${USER:-anon}
ARG UID=${UID:-1000}
ARG PASSWORD_HASH=${PASSWORD_HASH:-!}
LABEL maintainer="Georges Savoundararadj <savoundg@gmail.com>"
COPY sshd_config /etc/ssh/sshd_config
RUN apk update && apk add openssh-server \
 && ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N "" \
 && echo "$USER:x:$UID:$UID::/sftp/:" >> /etc/passwd \
 && echo "$USER:x:$UID:" >> /etc/group \
 && echo "$USER:$PASSWORD_HASH::0:::::" >> /etc/shadow \
 && install -d -o $USER -g $USER /sftp \
 && sed -e "s/%USER%/$USER/g" -i /etc/ssh/sshd_config
CMD ["/usr/sbin/sshd", "-D", "-e"]

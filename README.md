dockerfile-sftp
===============

This is a simple alpine container that runs an OpenSSH single-account sftp-only
server.

## Example of docker build

The build requires 3 build arguments:
* USER: the username of the sftp account
* PASSWORD_HASH: the password's hash of the sftp account
* UID: the UID of the sftp's user

For security reason, the salt used to hash the password should be different for
each build.

In the following example, the sftp docker image creates an account with the
same username (and uid) as the user who runs the command with the password
'1234sftp`.

```
docker build \
	--build-arg UID=$(id -u) \
	--build-arg USER=$(whoami) \
	--build-arg PASSWORD_HASH=$(openssl passwd -1 -salt $RANDOM 1234sftp)
	-t sftp https://github.com:/manoj23/dockerfile-sftp.git
```

## Example of docker run


```
docker run --rm -ti -v $PWD/sftp/:/sftp/ sftp
```

## Example of docker-compose.yml

Put in a folder:
* docker-compose.yml as below

```
version: '3'
services:
  sftp:
    build: https://github.com:/manoj23/dockerfile-sftp.git
    args:
      UID: $(id -u)
      USER: $(whoami)
      PASSWORD_HASH: $(openssl passwd -1 -salt $RANDOM 1234sftp)
    volumes:
      - /path/to/sftp:/sftp
```

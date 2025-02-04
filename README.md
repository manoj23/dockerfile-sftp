dockerfile-sftp
===============

This is a simple alpine container that runs an OpenSSH single-account sftp-only
server.

Example of docker build
#######################

The build requires 3 build arguments:

* USER: the username of the sftp account
* PASSWORD_HASH: the password's hash of the sftp account
* UID: the UID of the sftp's user

For security reason, the salt used to hash the password should be different for
each build.

In the following example, the sftp docker image creates an account with the
same username (and uid) as the user who runs the command with the password
'1234sftp`.

```bash
docker build \
    --build-arg UID=$(id -u) \
    --build-arg USERNAME=$(whoami) \
    --build-arg PASSWORD_HASH=$(openssl passwd -6 -salt $RANDOM 1234sftp)
    -t sftp https://github.com:/manoj23/dockerfile-sftp.git
```

Or, you can use the `build.sh` script as follow:

```bash
./build.sh $USER 1234sftp
```

This will build the docker image and upload to GitHub Container Registry.
Please the script to use on your own Registry.

Example of docker run
#####################

```bash
docker run --rm -ti -v $PWD/sftp/:/sftp/ sftp
```

Example of docker-compose.yml
#############################

Put in a folder:

* docker-compose.yml as below

```Dockerfile
version: '3'
services:
  sftp:
    build:
    context: https://github.com:/manoj23/dockerfile-sftp.git
    args:
      UID: 500
      USER: batman
      PASSWORD_HASH: "$$1$$21502$$9pCmk.3M64LxpmzD2ihVo/"
    volumes:
      - /path/to/sftp:/sftp
```

The dollar signes in the PASSWORD_HASH should be escaped with a dollar.
docker-compose does not handle inline bash as value.

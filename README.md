# README

This project was forked from https://github.com/digininja/DVWA.

The original README.md file has been moved to **README.en.md** in this directory.

The goal of this project is to develop a context-root aware version that supports reverse proxy servers.

# Warning

Please note that the DVWA is vulnerable, it is intended.

Do not run the DVWA application in a location where it can be accessed by others, such as public clouds and public hosting services.

# Configuration

This container supports following environment variables.

* DVWA_DB_SERVER (default: localhost)
* DVWA_DBNAME (default: mysql)
* DVWA_DBUSERNAME (default: dvwa)
* DVWA_DBPASSWORD (default: f3538c7cc848)
* DVWA_DBPORT (default: 3306)
* DVWA_WEB_CONTEXTROOT (default: "")
* DVWA_ADMIN_PASSWORD (default: password)

The DVWA_ADMIN_PASSWORD will change the admin password from the default "password" to the specified one.
The password will be effective after setting up the DB.

## MySQL Server

This container needs a separate MySQL or compatible instance.

For test with the default configuration, you can run a mysql instance as follows;

```sh
## for test
$ podman run -it --rm -d -p 3306:3306 \
    --env MYSQL_ROOT_PASSWORD=secret \
    --env MYSQL_USER=dvwa \
    --env MYSQL_PASSWORD=f3538c7cc848 \
    --env MYSQL_DATABASE=dvwa \
    --name mysql mysql:9
```

# Kubernetes Supports

The YAML files are placed in the "kubernetes" directory.

```sh
$ cd kubernetes/
$ make setup-secrets
$ for file in 0[01245].yaml ; do kubectl apply -f $file ; done

## 03.cm-dvwa.yaml is copied from https://github.com/cytopia/docker-dvwa
## This project doesn't currently support these customize features.
```

Please expose the **dvwa** service with your appropriate method.
If you can use the loadbalancer, then you can patch as follows:

```sh
$ kubectl patch svc dvwa  --patch '{"spec": {"type": "LoadBalancer"}}'
```

# Getting Started

Please make sure that a mysql instance is running.

```sh
## for test or development
$ make docker-build
$ make docker-run
```

## Building the container image for deploying to a registry server

Please edit the Makefile to your environment.

```makefile
DOCKER_IMAGE_VERSION = latest
...
REGISTRY_SERVER = docker.io
REGISTRY_LIBRARY = yasuhiroabe
```

* DOCKER_IMAGE_VERSION - Arbitrary tag text for the container.
* REGISTRY_SERVER - A registry server name. The "docker.io" is the default server of hub.docker.com, Docker Hub.
* REGISTRY_LIBRARY - A username of Docker Hub or a project name of Harbor.

After modifying the Makefile, a container image can be generated with the following procedures;

```sh
$ make docker-build-prod
$ make docker-tag
$ make docker-push
```

# License

This project is distributed under GPL v3 or any later version.


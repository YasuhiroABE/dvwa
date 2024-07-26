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
However, use the admin/password to login the console when the initial login before preparing the database.

## MySQL Server

This container needs a separate MySQL or compatible instance.

# Kubernetes Supports

The YAML files are placed in the "kubernetes" directory.

Some yaml files are from

    $ cd kubernetes/
    $ make setup-secrets
    $ for file in 0[01245].yaml ; do kubectl apply -f $file ; done
	## 03.cm-dvwa.yaml is copied from https://github.com/cytopia/docker-dvwa
	## This project doesn't currently support these customize features.

Please expose the **dvwa** service with your appropriate method.
If you can use the loadbalancer, then you can patch as follows:

    $ kubectl patch svc dvwa  --patch '{"spec": {"type": "LoadBalancer"}}'

# Getting Started

Please do the following steps for test.

    $ make docker-build
    $ make docker-run

For generating the container image, please do as follows:

    $ make docker-build-prod
    $ make docker-tag
    $ make docker-push

# License

This project is distributed under GPL v3 or any later version.


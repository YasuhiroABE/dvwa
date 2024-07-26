
DOCKER_CMD = podman

NAME = sccp-dvwa
DOCKER_IMAGE = sccp-dvwa
DOCKER_IMAGE_VERSION = latest
IMAGE_NAME = $(DOCKER_IMAGE):$(DOCKER_IMAGE_VERSION)

DOCKER_FILE = Dockerfile

REGISTRY_SERVER = docker.io
REGISTRY_LIBRARY = yasuhiroabe
PROD_IMAGE_NAME = $(REGISTRY_SERVER)/$(REGISTRY_LIBRARY)/$(IMAGE_NAME)

.PHONY: all
all:
	@echo "Please specify a target following the make command."

.PHONY: docker-build
docker-build:
	$(DOCKER_CMD) build . -f $(DOCKER_FILE) --pull --tag $(DOCKER_IMAGE):latest

.PHONY: docker-build-prod
docker-build-prod:
	$(DOCKER_CMD) build . -f $(DOCKER_FILE) --pull --tag $(IMAGE_NAME) --no-cache

.PHONY: docker-tag
docker-tag:
	$(DOCKER_CMD) tag $(IMAGE_NAME) $(PROD_IMAGE_NAME)

.PHONY: docker-push
docker-push:
	$(DOCKER_CMD) push $(PROD_IMAGE_NAME)

.PHONY: docker-stop
docker-stop:
	$(DOCKER_CMD) stop $(NAME)

.PHONY: clean
clean:
	find . -name '*~' -type f -exec rm {} \; -print

.PHONY: docker-exec
docker-exec:
	$(DOCKER_CMD) exec -it $(NAME) bash

.PHONY: docker-run
docker-run:
	$(DOCKER_CMD) run -it --rm  -d \
		--env DVWA_DB_SERVER=10.1.1.1 \
		--env DVWA_DBNAME=dvwa \
		--env DVWA_DBUSERNAME=dvwa \
		--env DVWA_DBPASSWORD=f3538c7cc848 \
		-p 8080:80 \
		--name $(NAME) \
		$(DOCKER_IMAGE):latest

.PHONY: docker-mysql-run
docker-mysql-run:
	$(DOCKER_CMD) run -it --rm -d \
		--env MYSQL_ROOT_PASSWORD=$(shell openssl rand -hex 8) \
		--env MYSQL_USER=dvwa \
		--env MYSQL_PASSWORD=f3538c7cc848 \
		--env MYSQL_DATABASE=dvwa \
		-p 3306:3306 \
		--name dvwa-mysql \
		docker.io/library/mysql:9

.PHONY: docker-mysql-stop
docker-mysql-stop:
	$(DOCKER_CMD) stop dvwa-mysql

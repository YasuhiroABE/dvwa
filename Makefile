
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
	$(DOCKER_CMD) run -it --rm  \
		--env DVWA_DB_SERVER=192.168.1.1 \
		--env DVWA_DBNAME=dvwa \
		--env DVWA_DBUSERNAME=dvwa \
		--env DVWA_DBPASSWORD=f3538c7cc848 \
		-p 8080:80 \
		--name $(NAME) \
		$(DOCKER_IMAGE):latest

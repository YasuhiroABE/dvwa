
K8S_NAMESPACE = ${K8S_NAMESPACE:-dvwa}

.PHONY: all
all:
	@echo "Please read the task of Makefile"

.PHONY: setup-secrets
setup-secrets:
	kubectl -n $(K8S_NAMESPACE) create secret generic mysql-secret \
		--from-literal=admin-password=$(shell openssl rand -hex 16) \
		--from-literal=username=$(shell openssl rand -hex 8) \
		--from-literal=password=$(shell openssl rand -hex 16) \
		--from-literal=dvwa-admin-password=$(shell openssl rand -hex 16)

.PHONY: extract-secrets
extract-secrets:
	@echo -n "root-password:\t"
	@kubectl -n $(K8S_NAMESPACE) get secret mysql-secret -o jsonpath={.data.admin-password} | base64 -d && echo ""
	@echo -n "username:\t"
	@kubectl -n $(K8S_NAMESPACE) get secret mysql-secret -o jsonpath={.data.username} | base64 -d && echo ""
	@echo -n "password:\t"
	@kubectl -n $(K8S_NAMESPACE) get secret mysql-secret -o jsonpath={.data.password} | base64 -d && echo ""
	@echo -n "dvwa admin password:\t"
	@kubectl -n $(K8S_NAMESPACE) get secret mysql-secret -o jsonpath={.data.dvwa-admin-password} | base64 -d && echo ""

.PHONY: delete-secrets
delete-secrets:
	kubectl -n $(K8S_NAMESPACE) delete secret mysql-secret

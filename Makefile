DOCKER_TAG = latest
REMOTE_ACCOUNT = $(shell aws sts get-caller-identity --output json | jq -r .Account)
REMOTE_REGION = us-east-2
WORKSPACE=prod

all: docker apply

.PHONY: docker
docker:
	$(MAKE) -e TAG=$(DOCKER_TAG) REMOTE_ACCOUNT=$(REMOTE_ACCOUNT) REMOTE_REGION=$(REMOTE_REGION) -C docker all

.PHONY: apply
apply:
	$(MAKE) -e TAG=$(TAG) REMOTE_ACCOUNT=$(REMOTE_ACCOUNT) REMOTE_REGION=$(REMOTE_REGION) -C terraform/manifests apply

.PHONY: apply-apps
apply-apps:
	$(MAKE) -e TAG=$(TAG) REMOTE_ACCOUNT=$(REMOTE_ACCOUNT) REMOTE_REGION=$(REMOTE_REGION) -C terraform/manifests apply-apps

.PHONY: destroy
destroy:
	$(MAKE) -e TAG=$(TAG) REMOTE_ACCOUNT=$(REMOTE_ACCOUNT) REMOTE_REGION=$(REMOTE_REGION) -C terraform/manifests destroy

.PHONY: destroy-apps
destroy-apps:
	$(MAKE) -e TAG=$(TAG) REMOTE_ACCOUNT=$(REMOTE_ACCOUNT) REMOTE_REGION=$(REMOTE_REGION) -C terraform/manifests destroy-apps

apps: docker apply-apps

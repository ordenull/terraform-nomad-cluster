TAG = latest
REMOTE_ACCOUNT = $(shell aws sts get-caller-identity --output json | jq -r .Account)
REMOTE_REGION = us-east-2

all: build push

.PHONY: build
build:
	$(MAKE) -e TAG=$(TAG) REMOTE_ACCOUNT=$(REMOTE_ACCOUNT) REMOTE_REGION=$(REMOTE_REGION) -C hello build
	
.PHONY: push
push:
	$(MAKE) -e TAG=$(TAG) REMOTE_ACCOUNT=$(REMOTE_ACCOUNT) REMOTE_REGION=$(REMOTE_REGION) -C hello push

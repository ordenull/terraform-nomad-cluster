REPO = xeraweb/hello
TAG = latest
BUILD_OPTS =
REMOTE_HOST = $(REMOTE_ACCOUNT).dkr.ecr.$(REMOTE_REGION).amazonaws.com

all: build push

build:
	docker build $(BUILD_OPTS) -t $(REPO):$(TAG) .

push: auth
	docker tag $(REPO):$(TAG) $(REMOTE_HOST)/$(REPO):$(TAG)
	docker push $(REMOTE_HOST)/$(REPO):$(TAG)

test: build
	docker run -it --rm -p 8080:8080 $(REPO):$(TAG)

auth:
	$(info Authenticating with ECS)
	eval $$(aws ecr get-login --region $(REMOTE_REGION) --no-include-email)

.PHONY: all build push test auth

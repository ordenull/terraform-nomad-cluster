WORKSPACE=dev

all: vpc_apply nomad_apply app-hello_apply
apply: vpc_apply nomad_apply app-hello_apply
apply-apps: app-hello_apply
destroy: app-hello_destroy nomad_destroy vpc_destroy
destroy-apps: app-hello_destroy

## VPC
#################################################################
.PHONY: vpc_apply
vpc_apply:
	$(MAKE) -e WORKSPACE=$(WORKSPACE) -C vpc apply

.PHONY: vpc_destroy
vpc_destroy:
	$(MAKE) -e WORKSPACE=$(WORKSPACE) -C vpc destroy

## Nomad Cluster
#################################################################
.PHONY: nomad_apply
nomad_apply:
	$(MAKE) -e WORKSPACE=$(WORKSPACE) -C nomad apply

.PHONY: nomad_destroy
nomad_destroy:
	$(MAKE) -e WORKSPACE=$(WORKSPACE) -C nomad destroy

## Hello World Service
#################################################################
.PHONY: app-hello_apply
app-hello_apply:
	$(MAKE) -e WORKSPACE=$(WORKSPACE) -C app-hello apply

.PHONY: app-hello_destroy
app-hello_destroy:
	$(MAKE) -e WORKSPACE=$(WORKSPACE) -C app-hello destroy

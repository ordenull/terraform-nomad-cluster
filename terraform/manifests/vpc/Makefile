APPLY_OPTIONS=
	#-auto-approve
WORKSPACE=dev

all: apply

.terraform:
	terraform init

terraform.tfstate.d/$(WORKSPACE): .terraform
	terraform workspace new $(WORKSPACE)

.PHONY: apply
apply: terraform.tfstate.d/$(WORKSPACE)
	terraform workspace select $(WORKSPACE)
	terraform apply $(APPLY_OPTIONS)

.PHONY: destroy
destroy: terraform.tfstate.d/$(WORKSPACE)
	terraform destroy $(APPLY_OPTIONS)

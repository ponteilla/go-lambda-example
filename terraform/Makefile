.PHONY: default init plan apply destroy clean

ENV ?= dev

default: plan

init:
	terraform init -backend=true -backend-config="key=$(ENV).tfstate"
	terraform get

plan:
	terraform plan

apply:
	terraform apply

destroy:
	terraform destroy

clean:
	rm -rf .terraform terraform.tfstate terraform.tfstate.backup

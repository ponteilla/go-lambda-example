.PHONY: default init plan apply destroy clean

ENV ?= dev

default: plan

init:
	terraform init -backend=true -backend-config="key=$(ENV).tfstate"
	terraform get

plan: init
	terraform plan

apply: init
	terraform apply

destroy: init
	terraform destroy

clean:
	rm -rf .terraform terraform.tfstate terraform.tfstate.backup

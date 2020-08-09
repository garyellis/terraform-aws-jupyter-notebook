NAME=terraform-aws-jupyter-notebook
VERSION=v0.1.0
REPO=https://github.com/garyellis/teraform-aws-jupyter-notebook.git
RELEASE_BRANCH=master
BRANCH=$$(git rev-parse --abbrev-ref HEAD | sed 's@[\/]@-@g')

export NAME VERSION REPO RELEASE_BRANCH BRANCH

export ENV := $$PWD/examples/env.sh
export PATH := $$PWD/bin:$(PATH)

.PHONY: help terraform-lint
	.DEFAULT_GOAL := help

help: ## show this message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

dependencies: ## installs project dependencies
	./scripts/terraform-helpers.sh tfenv
	./scripts/terraform-helpers.sh tflint

install-git-hooks: ## installs git hooks to .git/hooks
	./scripts/helpers.sh install_pre_commit_hook

terraform-lint: ## runs tflint static code analysis
        # https://github.com/terraform-linters/tflint#exit-statuses
	. $(ENV) && terraform init && tflint --module --deep

terraform-init: ## loads environment and runs terraform init
	source $(ENV) && cd examples && terraform init

terraform-plan: terraform-init ## runs terraform plan
	source $(ENV) && cd examples && terraform plan

terraform-apply: terraform-init ## runs terraform apply
	source $(ENV) && cd examples && terraform apply -auto-approve

terraform-output: terraform-init ## runs terraform output on the module
	source $(ENV) && cd examples && terraform output

terraform-destroy: terraform-init ## runs terraform destroy to teardown infrastructure
	source $(ENV) && cd examples && terraform destroy -auto-approve


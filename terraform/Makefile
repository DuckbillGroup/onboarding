MIN_TERRAFORM_VERSION := 0.12

TERRAFORM_VERSION := $$(terraform -version | grep "^Terraform v" | cut -dv -f2)

cmd-exists-%:
	@hash $(*) > /dev/null 2>&1 || \
		(echo "ERROR: '$(*)' must be installed and available on your PATH."; exit 1)

terraform-version: cmd-exists-terraform
	@printf '%s\n%s\n' $(MIN_TERRAFORM_VERSION) $(TERRAFORM_VERSION) | sort --check=quiet --version-sort || \
		(echo "ERROR: Terraform $(MIN_TERRAFORM_VERSION) or newer is required. Found $(TERRAFORM_VERSION)"; exit 1)

init: terraform-version
	@[ -d .terraform ] || terraform init

plan: init
	@terraform plan -out terraform.tfplan

apply:
	@[ -f terraform.tfplan ] || $(MAKE) plan
	@terraform apply terraform.tfplan

destroy:
	@[ -f terraform.tfstate ] && terraform destroy

fmt:
	@terraform fmt

fmtcheck:
	@terraform fmt -check -diff

clean:
	@rm -rf terraform.* && rm -rf .terraform

lint: terraform-version fmtcheck fmtcheck
	@echo "terraform fmt ok"

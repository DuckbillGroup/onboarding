cmd-exists-%:
	@hash $(*) > /dev/null 2>&1 || \
		(echo "ERROR: '$(*)' must be installed and available on your PATH."; exit 1)

terraform-version: cmd-exists-terraform
	@if [ $$(terraform -version | grep "^Terraform v" | cut -d. -f2) -lt 12 ]; then \
		echo "ERROR: Terraform 0.12 or newer is required. Found $$(terraform -version | grep "^Terraform v")" && exit 1; fi

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

cmd-exists-%:
	@hash $(*) > /dev/null 2>&1 || \
		(echo "ERROR: '$(*)' must be installed and available on your PATH."; exit 1)

terraform-version: cmd-exists-terraform
	@if [ $$(terraform -version | grep "^Terraform v" | cut -d. -f2) -lt 12 ]; then \
		echo "ERROR: Terraform 0.12 or newer is required. Found $$(terraform -version | grep "^Terraform v")" && exit 1; fi

init-%: terraform-version
	@[ -d $(*)/.terraform ] || (cd $(*) && terraform init)

plan-%: init-%
	@cd $(*) && terraform plan -out terraform.tfplan

apply-%:
	@[ -f $(*)/terraform.tfplan ] || $(MAKE) plan-$(*)
	@cd $(*) && terraform apply terraform.tfplan

destroy-%:
	@[ -f $(*)/terraform.tfstate ] && cd $(*) && terraform destroy

fmt-%:
	@cd $(*) && terraform fmt

fmt-%: fmt-cfa fmt-cop

fmtcheck-%:
	@cd $(*) && terraform fmt -check -diff

clean-%:
	@cd $(*) && rm -rf terraform.* && rm -rf .terraform

lint: terraform-version fmtcheck-cfa fmtcheck-cop
	@echo "terraform fmt ok"

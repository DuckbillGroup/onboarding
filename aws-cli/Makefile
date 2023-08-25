cmd-exists-%:
	@hash $(*) > /dev/null 2>&1 || \
		(echo "ERROR: '$(*)' must be installed and available on your PATH."; exit 1)

create: cmd-exists-aws
	@./create-resources.sh

delete: cmd-exists-aws
	@./delete-resources.sh

lint-shell: cmd-exists-shellcheck
	@shellcheck *.sh && echo "shellcheck ok"

lint-json-%: cmd-exists-python
	@python -m json.tool $* > /dev/null && echo $* ok

lint: lint-shell
lint: lint-json-assume-role-trust-policy.json.template
lint: lint-json-billing-policy.json
lint: lint-json-cur-ingest-pipeline-policy.json.template

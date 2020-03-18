cmd-exists-%:
	@hash $(*) > /dev/null 2>&1 || \
		(echo "ERROR: '$(*)' must be installed and available on your PATH."; exit 1)

lint: cmd-exists-cfn-lint
	@cfn-lint **/*.yml && echo "cfn-lint ok"

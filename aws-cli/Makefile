cmd-exists-%:
	@hash $(*) > /dev/null 2>&1 || \
		(echo "ERROR: '$(*)' must be installed and available on your PATH."; exit 1)

create-%: cmd-exists-aws
	@cd $(*) && ./create-resources.sh

lint: cmd-exists-shellcheck
	@shellcheck **/*.sh && echo "shellcheck ok"

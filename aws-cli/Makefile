deps:
	@hash aws > /dev/null 2>&1 || \
		(echo "ERROR: 'aws' not found. AWS CLI needs to be installed and available on your PATH."; exit 1)

create-%: deps
	@cd $(*) && ./create-resources.sh

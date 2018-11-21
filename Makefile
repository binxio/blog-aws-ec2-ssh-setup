.PHONY: help init clean validate mock create delete info deploy
.DEFAULT_GOAL := help
environment = "example"

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

create: ## create env
	@sceptre launch-env $(environment)

delete: ## delete env
	@sceptre delete-env $(environment)

info: ## describe resources
	@sceptre describe-stack-outputs $(environment) vpc

show-private-key: ## show the private key
	aws ssm get-parameter --name /bastion/default/private-key --with-decryption | jq -r '.Parameter.Value'

copy-private-key: ## copy the private key to the pasteboard (clipboard)
	aws ssm get-parameter --name /bastion/default/private-key --with-decryption | jq -r '.Parameter.Value' | pbcopy

write-private-key: ## write the private key to bastion.pem
	@aws ssm get-parameter --name /bastion/default/private-key --with-decryption | jq -r '.Parameter.Value' > bastion.pem
	@chmod 600 bastion.pem

ssh: write-private-key ## open an ssh session
	@ssh -i bastion.pem ec2-user@$(shell sceptre --output json describe-stack-outputs example vpc | jq -r '.[] | select(.OutputKey=="BastionHostPublicDnsName") | .OutputValue')

shell: ssh ## open an ssh session
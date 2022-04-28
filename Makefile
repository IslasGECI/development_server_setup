devserver: init create_server setup_server setup_users

.PHONY: \
	create_server \
	destroy_server \
	devserver \
	init \
	linter \
	setup_server \
	setup_users

create_server:
	cd src && terraform apply -auto-approve -var "do_token=$${DO_PAT}" -var "pvt_key=$${HOME}/.ssh/id_rsa"

destroy_server:
	cd src && terraform destroy -auto-approve -var "do_token=$${DO_PAT}" -var "pvt_key=$${HOME}/.ssh/id_rsa"

init:
	cd src && terraform init

format:
	cd src && terraform fmt

linter:
	ansible-lint development.yml

setup_server:
	ansible-playbook development.yml

setup_users:
	ansible-playbook setup_users.yml

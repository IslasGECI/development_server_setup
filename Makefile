all: init create_server sleep host_known setup_server setup_users setup_guests

.PHONY: \
	all \
	check \
	create_server \
	destroy_server \
	format \
	host_known \
	init \
	setup_guests \
	setup_server \
	setup_users \
	sleep

clean:
	rm --force --recursive src/.terraform
	rm --force src/.terraform.lock.hcl
	rm --force src/terraform.tfstate*

create_server:
	cd src && terraform apply -auto-approve -var "do_token=$${DO_PAT}" -var "pvt_key=$${HOME}/.ssh/id_rsa"

destroy_server:
	cd src && terraform destroy -auto-approve -var "do_token=$${DO_PAT}" -var "pvt_key=$${HOME}/.ssh/id_rsa"

host_known:
	ssh-keyscan "islasgeci.dev" > "$${HOME}/.ssh/known_hosts"

init:
	cd src && terraform init

format:
	cd src && terraform fmt

check:
	ansible-lint ansible/development.yml ansible/setup_users.yml
	cd src && terraform fmt -check

setup_server:
	cd src && \
	export DEVSERVER_IP=$$(terraform output -raw devserver_ip) && \
	ansible-playbook ansible/development.yml

setup_users:
	cd src && \
	export DEVSERVER_IP=$$(terraform output -raw devserver_ip) && \
	ansible-playbook ansible/setup_users.yml

sleep:
	@echo "Waiting to avoid conflicts with APT. 😴 💤 😪"
	sleep 100

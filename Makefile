all: create_server sleep host_known setup_server setup_users

.PHONY: \
	all \
	check \
	clean \
	create_server \
	destroy_server \
	format \
	host_known \
	init \
	setup_server \
	setup_users \
	sleep

check:
	ansible-lint ansible/development.yml ansible/setup_users.yml
	cd src && terraform fmt -check

clean:
	rm --force --recursive src/.terraform
	rm --force src/.terraform.lock.hcl
	rm --force src/terraform.tfstate*

create_server: init
	cd src && terraform apply -auto-approve

destroy_server: init
	cd src && terraform destroy -auto-approve -target=aws_instance.devserver

format:
	cd src && terraform fmt

host_known:
	cd src && \
	ssh-keyscan "$$(terraform output -raw devserver_ip_aws)" > "$${HOME}/.ssh/known_hosts"

init:
	cd src && \
	az login --username $${AZURE_USERNAME} --password $${AZURE_PASSWORD} && \
	az account set --subscription "Old subscription" && \
	terraform init

setup_server:
	cd src && \
	export DEVSERVER_IP=$$(terraform output -raw devserver_ip_aws) && \
	ansible-galaxy collection install community.general && \
	ansible-playbook /workdir/ansible/development.yml

setup_users:
	cd src && \
	export DEVSERVER_IP=$$(terraform output -raw devserver_ip_aws) && \
	ansible-playbook /workdir/ansible/setup_users.yml

sleep:
	@echo "Waiting to avoid conflicts with APT. 😴 💤 😪"
	sleep 100

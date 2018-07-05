#!/bin/bash

function install_docker() 
{
	yum remove docker \
                docker-client \
                docker-client-latest \
                docker-common \
                docker-latest \
                docker-latest-logrotate \
                docker-logrotate \
                docker-selinux \
                docker-engine-selinux \
                docker-engine

	yum install -y yum-utils \
		device-mapper-persistent-data \
		lvm2

	yum-config-manager -y \
    		--add-repo \
	    	https://download.docker.com/linux/centos/docker-ce.repo

	yum -y install docker-ce

	systemctl enable docker
	systemctl start docker
}

function install_ansible()
{
	yum -y install ansible python-docker-py.noarch
}

function _create_ssh_folder ()
{
	local _user=$1
	local _home_folder=$2
	mkdir $_home_folder/.ssh/
	chown -R ${_user}:${_user} $_home_folder/.ssh/
}

function _generate_and_copy_key ()
{
	local _home_folder=$1
	ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
	cat ~/.ssh/id_rsa.pub >> $_home_folder/.ssh/authorized_keys
}



function _configure_ssh()
{
	local _user=$1
	local _home_folder=$(grep ${_user} /etc/passwd | awk -F: '{print $6}')
	_create_ssh_folder $_user $_home_folder
	_generate_and_copy_key $_home_folder

	
}


function add_ansible_user()
{
	local _user=$1
	useradd $_user
	usermod -a -G docker $_user
	echo $_user | passwd --stdin $_user
	echo "$_user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$_user
	_configure_ssh $_user
}

install_docker
install_ansible
add_ansible_user "develop"

#!/bin/bash

install_utilities(){
echo
echo 'TASK - Install utilities (python, sshpass, ...)'
sudo apt-get update -qq 2>&1 >/dev/null
sudo apt-get install -y -qq vim tree net-tools telnet git python3-pip sshpass nfs-common 2>&1 >/dev/null
sudo echo "autocmd filetype yaml setlocal ai ts=2 sw=2 et" > /home/vagrant/.vimrc
}

install_docker(){
echo
echo 'TASK - Install docker'
curl -fsSL https://get.docker.com -o get-docker.sh 2>&1 >/dev/null
sudo sh get-docker.sh 2>&1 >/dev/null
sudo usermod -aG docker vagrant
sudo service docker start
}

configure_ssh_for_ansible(){
echo
echo 'TASK - Configure SSH for Ansible'
sed -i 's/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/g' /etc/ssh/sshd_config
sudo systemctl restart sshd
}

install_utilities
install_docker
configure_ssh_for_ansible
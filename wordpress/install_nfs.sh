#!/bin/bash

# install nfs server

IP_RANGE=$(dig +short wphaproxy | sed s/".[0-9]*$"/.0/g) # 192.168.8.0

prepare_directories(){
echo
echo 'TASK - prepare directories'
sudo mkdir -p /srv/wordpress/{db,files}
sudo chmod 777 -R /srv/wordpress/
}

install_nfs(){
echo
echo 'TASK - install NFS'
sudo apt-get install -y nfs-kernel-server 2>&1 > /dev/null
}

set_nfs(){
echo
echo 'TASK - set NFS'
sudo echo "/srv/wordpress/db ${IP_RANGE}/24(rw,sync,no_root_squash,no_subtree_check)">/etc/exports
sudo echo "/srv/wordpress/files ${IP_RANGE}/24(rw,sync,no_root_squash,no_subtree_check)">>/etc/exports
}

run_nfs(){
echo
echo 'TASK - run NFS'
sudo systemctl restart nfs-server rpcbind
sudo exportfs -a
}

prepare_directories
install_nfs
set_nfs
run_nfs
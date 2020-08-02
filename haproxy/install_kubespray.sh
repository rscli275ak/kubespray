#!/bin/bash

# Install kubespray to initialize a k8s cluster

IP_HAPROXY=$(dig +short haproxy)
IP_KMASTER=$(dig +short kmaster)

prepare_kubespray(){

echo
echo "TASK - Download kubespray"
rm -Rf /home/vagrant/kubespray
git clone https://github.com/kubernetes-sigs/kubespray.git 2>&1 >/dev/null
chown -R vagrant:vagrant /home/vagrant/kubespray

echo "TASK - Install requirements"
pip3 install --quiet -r kubespray/requirements.txt

echo "TASK - Ansible - Create inventory"
cp -rfp kubespray/inventory/sample kubespray/inventory/cluster
cat /etc/hosts | grep km | awk '{print $2" ansible_host="$1" ip="$1" etcd_member_name=etcd"NR}'>kubespray/inventory/cluster/inventory.ini
cat /etc/hosts | grep kn | awk '{print $2" ansible_host="$1" ip="$1}'>>kubespray/inventory/cluster/inventory.ini

echo "[kube-master]">>kubespray/inventory/cluster/inventory.ini
cat /etc/hosts | grep km | awk '{print $2}'>>kubespray/inventory/cluster/inventory.ini

echo "[etcd]">>kubespray/inventory/cluster/inventory.ini
cat /etc/hosts | grep km | awk '{print $2}'>>kubespray/inventory/cluster/inventory.ini

echo "[kube-node]">>kubespray/inventory/cluster/inventory.ini
cat /etc/hosts | grep kn | awk '{print $2}'>>kubespray/inventory/cluster/inventory.ini

echo "[calico-rr]">>kubespray/inventory/cluster/inventory.ini
echo "[k8s-cluster:children]">>kubespray/inventory/cluster/inventory.ini
echo "kube-master">>kubespray/inventory/cluster/inventory.ini
echo "kube-node">>kubespray/inventory/cluster/inventory.ini
echo "calico-rr">>kubespray/inventory/cluster/inventory.ini
}

install_loadbalancer(){
echo
echo "TASK - Ansible - Activate external LB"
sed -i s/"## apiserver_loadbalancer_domain_name: \"elb.some.domain\""/"apiserver_loadbalancer_domain_name: \"elb.kub\""/g kubespray/inventory/cluster/group_vars/all/all.yml
sed -i s/"# loadbalancer_apiserver:"/"loadbalancer_apiserver:"/g kubespray/inventory/cluster/group_vars/all/all.yml
sed -i s/"#   address: 1.2.3.4"/"  address: ${IP_HAPROXY}"/g kubespray/inventory/cluster/group_vars/all/all.yml
sed -i s/"#   port: 1234"/"  port: 6443"/g kubespray/inventory/cluster/group_vars/all/all.yml
}

create_ssh_keys(){
echo
echo 'TASK - Create SSH private key and push public key'
sudo -u vagrant bash -c "ssh-keygen -b 2048 -t rsa -f .ssh/id_rsa -q -N ''"
for srv in $(cat /etc/hosts | grep km | awk '{print $2}'); do 
cat /home/vagrant/.ssh/id_rsa.pub | sshpass -p 'vagrant' ssh -o StrictHostKeyChecking=no vagrant@$srv -T 'tee -a >>/home/vagrant/.ssh/authorized_keys'
done
for srv in $(cat /etc/hosts | grep kn | awk '{print $2}'); do 
cat /home/vagrant/.ssh/id_rsa.pub | sshpass -p 'vagrant' ssh -o StrictHostKeyChecking=no vagrant@$srv -T 'tee -a >>/home/vagrant/.ssh/authorized_keys'
done
}

install_kubespray(){
echo
echo "TASK - Ansible - Install kubespray"
sudo su - vagrant bash -c "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i kubespray/inventory/cluster/inventory.ini -b -u vagrant kubespray/cluster.yml"
}

install_kubectl(){
echo
echo "TASK - Install kubectl"
sudo apt-get update -qq && sudo apt-get install apt-transport-https 2>&1 >/dev/null
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - 2>&1 >/dev/null
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update -qq 2>&1 >/dev/null
sudo apt-get install -y -qq kubectl 2>&1 >/dev/null
mkdir -p /home/vagrant/.kube
chown -R vagrant:vagrant /home/vagrant/.kube

echo
echo "TASK - Copy kubectl cert"
ssh -o StrictHostKeyChecking=no -i /home/vagrant/.ssh/id_rsa vagrant@${IP_KMASTER} "sudo cat /etc/kubernetes/admin.conf" >/home/vagrant/.kube/config
}

prepare_kubespray
install_loadbalancer
create_ssh_keys
install_kubespray
install_kubectl
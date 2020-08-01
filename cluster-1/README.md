# Kubespray

Une des manières les plus simples d'installer un cluster Kubernetes

## VagrantFile

Le [VagrantFile](VagrantFile) ne permet que de déclarer les VMs. Pas d'initialisation du cluster.

## Installation du cluster

Les commandes doivent se faire sur le noeud `deploykub`

    $ vagrant ssh deploykub

### Installer Ansible

    $ sudo yum install -y epel-release
    $ sudo yum install -y ansible

### Cloner le dépôt git

    $ git clone https://github.com/kubernetes-sigs/kubespray.git
    $ cd kubespray

### Installer les prérequis

    $ sudo pip3 install -r requirements.txt

### Spécifier la configuration Ansible `ansible.cfg`

    [privilege_escalation]
    become=True
    become_method=sudo
    become_user=root
    become_ask_pass=False

### Déclarer l'inventaire des machines

    $ cp -rfp inventory/sample inventory/cluster
    $ declare -a IPS=(192.168.6.121 192.168.6.122 192.168.6.123 192.168.6.124 192.168.6.125)
    $ CONFIG_FILE=inventory/cluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}

Modifier le fichier `inventory/cluster/hosts.yaml` :

    all:
        hosts:
            node01:
            ansible_host: 192.168.6.121
            ip: 192.168.6.121
            access_ip: 192.168.6.121
            node02:
            ansible_host: 192.168.6.122
            ip: 192.168.6.122
            access_ip: 192.168.6.122
            node03:
            ansible_host: 192.168.6.123
            ip: 192.168.6.123
            access_ip: 192.168.6.123
            node04:
            ansible_host: 192.168.6.124
            ip: 192.168.6.124
            access_ip: 192.168.6.124
            node05:
            ansible_host: 192.168.6.125
            ip: 192.168.6.125
            access_ip: 192.168.6.125
        children:
            kube-master:
            hosts:
                node01:
                node02:
                node03:
            kube-node:
            hosts:
                node04:
                node05:
            etcd:
            hosts:
                node01:
                node02:
                node03:
            k8s-cluster:
            children:
                kube-master:
                kube-node:
            calico-rr:
            hosts: {}


### Lancer l'installation du cluster

    $ ansible-playbook -i inventory/cluster -u vagrant -k -b cluster.yml

### Installer kubectl

    $ sudo cat <<EOF > /etc/yum.repos.d/kubernetes.repo
      [kubernetes]
      name=Kubernetes
      baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
      enabled=1
      gpgcheck=1
      repo_gpgcheck=1
      gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
    EOF
    
    $ sudo yum install -y kubectl

### Récupérer les certificats

Se connecter à un node master :

    $ vagrant ssh node01
    $ cat /etc/kubernetes/admin.conf

Copier le certificat sur la vm `deploykub` :

    $ mkdir -p ~/.kube
    $ vim ~/.kube/config

### Test cluster-info

    $ kubectl cluster-info

### Autocomplétion

    $ echo "source <(kubectl completion bash)" >> ~/.bashrc
    $ source ~/.bashrc

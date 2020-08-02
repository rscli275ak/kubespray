# Kubespray

Une des manières les plus simples d'installer un cluster Kubernetes

## VagrantFile

Le [VagrantFile](VagrantFile) ne permet que de déclarer les VMs. Pas d'initialisation du cluster.

## Installation du cluster

Les commandes doivent se faire sur le noeud `kdeploykub`

    $ vagrant ssh kdeploykub

### Installer Ansible

    [vagrant@kdeploykub ]$ sudo yum install -y epel-release
    [vagrant@kdeploykub ]$ sudo yum install -y ansible

Ou

    [vagrant@kdeploykub ]$ pip3 install --user ansible

### Cloner le dépôt git

    [vagrant@kdeploykub ]$ git clone https://github.com/kubernetes-sigs/kubespray.git
    [vagrant@kdeploykub ]$ cd kubespray

### Installer les prérequis

    [vagrant@kdeploykub ]$ pip3 install --user -r requirements.txt

### Spécifier la configuration Ansible `ansible.cfg`

    [privilege_escalation]
    become=True
    become_method=sudo
    become_user=root
    become_ask_pass=False

### Déclarer l'inventaire des machines

    [vagrant@kdeploykub ]$ cp -rfp inventory/sample inventory/cluster
    [vagrant@kdeploykub ]$ declare -a IPS=(192.168.7.121 192.168.7.122 192.168.7.123)
    [vagrant@kdeploykub ]$ CONFIG_FILE=inventory/cluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}

Modifier le fichier `inventory/cluster/hosts.yaml` :

    all:
        hosts:
        kmaster01:
        ansible_host: 192.168.7.121
        ip: 192.168.7.121
        access_ip: 192.168.7.121
        kmaster02:
        ansible_host: 192.168.7.122
        ip: 192.168.7.122
        access_ip: 192.168.7.122
        knode01:
        ansible_host: 192.168.7.123
        ip: 192.168.7.123
        access_ip: 192.168.7.123
        children:
            kube-master:
            hosts:
              kmaster01:
              kmaster02:
            kube-node:
            hosts:
              knode01:
            etcd:
            hosts:
              kmaster01:
              kmaster02:
              knode01:
            k8s-cluster:
            children:
              kube-master:
              kube-node:
            calico-rr:
            hosts: {}


### Déclarer le LoadBalancer local :

Modifier le fichier `inventory/cluster/group_vars/all/all.yml` :

    apiserver_loadbalancer_domain_name: "elb.kub"
    loadbalancer_apiserver:
        address: 192.168.7.130
        port: 6443

### Lancer l'installation du cluster

    [vagrant@kdeploykub ]$ ansible-playbook -i inventory/cluster -u vagrant -k -b cluster.yml

### Installer kubectl

    [vagrant@kdeploykub ]$ sudo cat <<EOF > /etc/yum.repos.d/kubernetes.repo
      [kubernetes]
      name=Kubernetes
      baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
      enabled=1
      gpgcheck=1
      repo_gpgcheck=1
      gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
    EOF
    
    [vagrant@kdeploykub ]$ sudo yum install -y kubectl

### Récupérer les certificats

Se connecter à un node master :

    $ vagrant ssh kmaster01
    [vagrant@kmaster01 ]$ sudo cat /etc/kubernetes/admin.conf

Copier le certificat sur la vm `kdeploykub` :

    [vagrant@kdeploykub ]$ mkdir -p ~/.kube
    [vagrant@kdeploykub ]$ vim ~/.kube/config

### Test cluster-info

    [vagrant@kdeploykub ]$ kubectl cluster-info

### Autocomplétion

    [vagrant@kdeploykub ]$ echo "source <(kubectl completion bash)" >> ~/.bashrc
    [vagrant@kdeploykub ]$ source ~/.bashrc

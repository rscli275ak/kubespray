# Kubespray

Une des manières les plus simples d'installer un cluster Kubernetes
L'installation du cluster dure entre 20 et 30 minutes

Prérequis :
    - 8 CPU
    - 16 Go RAM
    - Virtualbox 6.1.x
    - Vagrant 2.2

## VagrantFile

Le [VagrantFile](VagrantFile) ne permet que de déclarer les VMs. Pas d'initialisation du cluster.

## Installation du cluster

    $ vagrant up

### Test cluster-info

    [vagrant@kdeploy ~]$ kubectl cluster-info
    [vagrant@kdeploy ~]$ kubectl get nodes -o wide

### Ingress

    [vagrant@kdeploy ~]$ kubectl get ns
    [vagrant@kdeploy ~]$ kubectl get all -n ingress-nginx

    curl 192.168.7.120

Ou http://192.168.7.120:9000/stats




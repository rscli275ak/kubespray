# Ingress

## Flux

HAProxy 80/443 >> knodeXX >> pod/daemonset nginx >> ingress >> service >> pods

## Test :

    curl 192.168.7.120/hw1
    echo "192.168.7.120    hw2.kub">>/etc/hosts
    curl hw2.cub
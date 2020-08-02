# Ingress

## Flux

HAProxy 80/443 >> knodeXX >> pod/daemonset nginx >> ingress >> service >> pods

## Test :

Ajouter la ligne suivante dans le fichier `/etc/hosts` de l'hôte :

    192.168.8.120   wordpress.kub
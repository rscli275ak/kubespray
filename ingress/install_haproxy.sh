#!/bin/bash

# Install and set haproxy LB for k8s

install_haproxy(){
echo
echo 'TASK - Install HAPROXY'
sudo apt-get install -y -qq haproxy 2>&1 >/dev/null
}

configure_haproxy(){
echo
echo "TASK - Configure HAPROXY"
echo "
global
    log         127.0.0.1 local2

    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        haproxy
    group       haproxy
    daemon
    stats socket /var/lib/haproxy/stats

defaults
    mode                    http
    log                     global
    option                  httplog
    option                  dontlognull
    option http-server-close
    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 3000

listen stats
    bind *:9000
    stats enable
    stats uri /stats
    stats refresh 2s
    stats auth admin:password

listen kubernetes-apiserver-https
    bind *:6443
    mode tcp
    option log-health-checks
    timeout client 3h
    timeout server 3h
    server kmaster kmaster:6443 check check-ssl verify none inter 10000
    balance roundrobin

listen kubernetes-ingress
    bind *:80
    mode tcp
    option log-health-checks" > /etc/haproxy/haproxy.cfg

for srv in $(cat /etc/hosts | grep kn | awk '{print $2}'); do echo "    server "$srv" "$srv":80 check" >>/etc/haproxy/haproxy.cfg
done

}

restart_haproxy(){
    
echo
echo 'TASK - Restart HAPROXY'
systemctl restart haproxy
}

install_haproxy
configure_haproxy
restart_haproxy
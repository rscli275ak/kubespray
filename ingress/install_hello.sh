#!/bin/bash

prepare_dir(){
echo
echo 'TASK - Prepare directory'
sudo mkdir /home/vagrant/demo-ingress
sudo chown vagrant -R /home/vagrant/demo-ingress
}

prepare_files(){

echo
echo "TASK - Prepare files"

echo "
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-one
spec:
  replicas: 1
  selector:
    matchLabels:
      app: hello-one
  template:
    metadata:
      labels:
        app: hello-one
    spec:
      containers:
      - name: hello-kubernetes
        image: paulbouwer/hello-kubernetes:1.7
        ports:
        - containerPort: 8080
        env:
        - name: MESSAGE
          value: Hello world! I am the One!
">/home/vagrant/demo-ingress/hello1.yml

echo "
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-two
spec:
  replicas: 3
  selector:
    matchLabels:
      app: hello-two
  template:
    metadata:
      labels:
        app: hello-two
    spec:
      containers:
      - name: hello-kubernetes
        image: paulbouwer/hello-kubernetes:1.7
        ports:
        - containerPort: 8080
        env:
        - name: MESSAGE
          value: Hello world! I am the TWO!
">/home/vagrant/demo-ingress/hello2.yml

echo "
---
apiVersion: v1
kind: Service
metadata:
  name: hello-one
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 8080
  selector:
    app: hello-one
---
apiVersion: v1
kind: Service
metadata:
  name: hello-two
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 8080
  selector:
    app: hello-two
">/home/vagrant/demo-ingress/services.yml
}

echo "
---
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: hello-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - http:
      paths:
      - path: /hw1
        backend:
          serviceName: hello-one
          servicePort: 80
  - host: hw2.kub
    http:
      paths:
      - path: /
        backend:
          serviceName: hello-two
          servicePort: 80
">/home/vagrant/demo-ingress/ingress.yml
}

apply_ingress(){
echo
echo 'TASK - Apply ingress'
sudo su -vagrant bash -c "kubectl apply -f /home/vagrant/demo-ingress/hello1.yml"
sudo su -vagrant bash -c "kubectl apply -f /home/vagrant/demo-ingress/hello2.yml"
sudo su -vagrant bash -c "kubectl apply -f /home/vagrant/demo-ingress/services.yml"
sudo su -vagrant bash -c "kubectl apply -f /home/vagrant/demo-ingress/ingress.yml"
}

prepare_dir
prepare_files
apply_ingress
# Go Api with Gin

## Overview

This repository contains a simple golang service which serves a single endpoint: `/:id`. For each call to this endpoint, the service increments a counter, and returns the number of times the endpoint has been called for the given ID. State for the application is stored in and retrieved from redis, where the data is stored simply with `id` as the key, and the count as the value.

In your solution, include a readme containing the necessary steps to set up the environment, as well as to build, package and deploy the application. Also detail and explain your chosen architecture, as well as what tools were used in the deployment process.

## Tools used

- Helm to package the kubernetes resources
- Kubernetes to host the microservices
  - ingress to handle traffic into the cluster
  - service to route the traffic through the cluster
  - deployment to manage deployment of the pods
  - HPA to handle autoscalling
  - secrets to handle sensitive data (redis password)
- Minikube for local Kubernetes development
- Docker to build and publish the images

## Notes

## Building and pushing the docker image

```bash
docker build . -t <name:tag>
docker push <name:tag>
```

## Run on existing cluster

```bash
kubectl create namespace api --dry-run=client -o yaml | kubectl apply -f -

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server
helm repo update metrics-server

helm install redis bitnami/redis -n api
helm upgrade --install api ./infra/api -n api
```

## Run on minikube

Tested on minikube v1.27.1, Darwin 12.4, Kubernetes v1.25.2, Docker 20.10.18

```bash
minikube start
minikube addons enable ingress
minikube addons enable ingress-dns
minikube ip

kubectl create namespace api --dry-run=client -o yaml | kubectl apply -f -

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server
helm repo update metrics-server

helm install redis bitnami/redis -n api
helm upgrade --install api ./infra/api -n api
```

## Running on docker dev pod

```bash
docker run --rm -it --name dev-env \
  -e PORT=9000 \
  -e REDIS_PASSWORD=$REDIS_PASSWORD \
  -e PORT=9000 \
  -e REDIS_HOST=127.0.0.1 \
  -e REDIS_PORT=6379 \
  -e REDIS_DB=0 \
  -e GO111MODULE=on \
  -p 9000:9000 \
  -v $PWD:/app/server \
  --network=host \
  -w /app/server \
  golang:1.14 

go mod download && \
go build 

./devops-techtask 
```

## General notes

Get the redis password:

```bash
export REDIS_PASSWORD=$(kubectl get secret --namespace redis my-release-redis -o jsonpath="{.data.redis-password}" | base64 -d)
kubectl port-forward --namespace default svc/my-release-redis-master 6379:6379 &
    REDISCLI_AUTH="$REDIS_PASSWORD" redis-cli -h 127.0.0.1 -p 6379
```

redis client:

```bash
apt update  -y && \
apt install lsb-release  -y && \
curl -fsSL https://packages.redis.io/gpg | gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg && \
echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/redis.list && \
apt-get update  -y && \
apt-get install redis -y
```

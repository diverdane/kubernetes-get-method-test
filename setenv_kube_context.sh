#!/bin/bash

export KUBE_GET_RESOURCE="pod"
export KUBE_API_URL=$(kubectl cluster-info | awk '/Kubernetes master.*is running at/{print $NF}' | sed 's/.*https/https/' | sed 's/.*//')
export KUBE_SERVICE_ACCOUNT_SECRET="$(kubectl get secret -n default | awk '/default-token/{print $1}' | head -n 1)"
export KUBE_SERVICE_ACCOUNT_TOKEN="$(kubectl get secret -n default $KUBE_SERVICE_ACCOUNT_SECRET -o json | jq -r .data.token | base64 -d)"
export KUBE_CA_CERT_FILE_PATH="/home/dane/temp/kubernetes_ca.crt"
export KUBE_CA_CERT="$(kubectl get secret -n default $KUBE_SERVICE_ACCOUNT_SECRET -o json | jq -r '.data["ca.crt"]' | base64 -d)"
echo $KUBE_CA_CERT > $KUBE_CA_CERT_FILE_PATH

echo KUBE_GET_RESOURCE: $KUBE_GET_RESOURCE
echo KUBE_API_URL: $KUBE_API_URL
echo KUBE_SERVICE_ACCOUNT_TOKEN: $SERVICE_ACCOUNT_TOKEN
echo KUBE_CA_CERT: $KUBE_CA_CERT

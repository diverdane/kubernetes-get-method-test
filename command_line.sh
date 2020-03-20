#!/bin/bash

export KUBE_GET_RESOURCE=pod
docker run --env KUBE_SERVICE_ACCOUNT_TOKEN --env KUBE_CA_CERT --env KUBE_API_URL --env KUBE_GET_RESOURCE diverdane/kubernetes-get-method:3.1.2

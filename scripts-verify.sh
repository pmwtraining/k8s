#!/bin/bash
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

kubectl get nodes
kubectl get namespaces
kubectl get pods -A

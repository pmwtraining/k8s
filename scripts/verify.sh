#!/bin/bash
set -e
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

echo "=== Nodes ==="
kubectl get nodes

echo "=== Namespaces ==="
kubectl get ns

echo "=== Deployments ==="
kubectl get deploy -A

echo "=== Pods ==="
kubectl get pods -A

echo "=== Services ==="
kubectl get svc -A

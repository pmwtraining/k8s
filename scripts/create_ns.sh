#!/usr/bin/env bash

set -euo pipefail

CLUSTER_NAME="pmwi"

echo "========================================"
echo "Deploying Kubernetes Training Platform"
echo "Cluster : ${CLUSTER_NAME}"
echo "========================================"

echo
echo "Creating namespaces..."
kubectl apply -f kubernetes/namespaces/

echo
echo "Applying ResourceQuotas..."
kubectl apply -f kubernetes/quotas/

echo
echo "Applying LimitRanges..."
kubectl apply -f kubernetes/limits/

echo
echo "Creating ConfigMaps..."
kubectl apply -f kubernetes/configmaps/

echo
echo "Creating Secrets..."
kubectl apply -f kubernetes/secrets/

echo
echo "Deploying applications..."
kubectl apply -f kubernetes/deployments/

echo
echo "Creating Services..."
kubectl apply -f kubernetes/services/

echo
echo "Creating Ingress resources..."
kubectl apply -f kubernetes/ingress/

echo
echo "Waiting for deployments..."

kubectl wait \
    --for=condition=Available \
    deployment/training-web \
    --all-namespaces \
    --timeout=300s

echo
echo "========================================"
echo "Platform deployment complete"
echo "Cluster : ${CLUSTER_NAME}"
echo "========================================"

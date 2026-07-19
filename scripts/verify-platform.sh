#!/usr/bin/env bash

set -euo pipefail

CLUSTER_NAME="pmwi"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAIL=0

pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    PASS=$((PASS+1))
}

fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    FAIL=$((FAIL+1))
}

info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

echo
echo "======================================="
echo "PMWI Platform Verification"
echo "Cluster : ${CLUSTER_NAME}"
echo "======================================="
echo

#######################################################
# kubectl
#######################################################

if command -v kubectl >/dev/null 2>&1; then
    pass "kubectl installed"
else
    fail "kubectl not installed"
    exit 1
fi

#######################################################
# Cluster connectivity
#######################################################

if kubectl cluster-info >/dev/null 2>&1; then
    pass "Connected to Kubernetes cluster"
else
    fail "Cannot connect to Kubernetes cluster"
    echo
    echo "Hint:"
    echo "export KUBECONFIG=/etc/rancher/k3s/k3s.yaml"
    exit 1
fi

#######################################################
# Nodes
#######################################################

NODE_COUNT=$(kubectl get nodes --no-headers | wc -l)

if [ "$NODE_COUNT" -ge 1 ]; then
    pass "$NODE_COUNT node(s) found"
else
    fail "No Kubernetes nodes found"
fi

#######################################################
# Metrics Server
#######################################################

if kubectl get deployment metrics-server -n kube-system >/dev/null 2>&1; then
    pass "Metrics Server installed"
else
    fail "Metrics Server missing"
fi

#######################################################
# NGINX Ingress
#######################################################

if kubectl get deployment -n ingress-nginx >/dev/null 2>&1; then
    pass "NGINX Ingress installed"
else
    fail "NGINX Ingress missing"
fi

#######################################################
# Manifest directories
#######################################################

for dir in \
namespaces \
quotas \
limits \
configmaps \
secrets \
deployments \
services \
ingress
do

    if [ -d kubernetes/$dir ]; then
        pass "$dir directory exists"
    else
        fail "$dir directory missing"
    fi

done

#######################################################
# YAML validation
#######################################################

COUNT=$(find kubernetes -name "*.yaml" | wc -l)

if [ "$COUNT" -gt 0 ]; then
    pass "$COUNT manifest(s) found"
else
    fail "No manifests found"
fi

#######################################################
# Namespace manifests
#######################################################

EXPECTED=12
FOUND=$(ls kubernetes/namespaces/*.yaml 2>/dev/null | wc -l)

if [ "$FOUND" -eq "$EXPECTED" ]; then
    pass "12 namespace manifests present"
else
    fail "Expected 12 namespace manifests, found $FOUND"
fi

#######################################################
# Test deployment
#######################################################

info "Deploying namespaces..."

kubectl apply -f kubernetes/namespaces >/dev/null

FOUND=$(kubectl get ns | grep '^s[0-9]' | wc -l)

if [ "$FOUND" -eq 12 ]; then
    pass "Namespaces successfully deployed"
else
    fail "Namespace deployment failed"
fi

#######################################################
# Resource Quotas
#######################################################

kubectl apply -f kubernetes/quotas >/dev/null

FOUND=$(kubectl get resourcequota -A --no-headers | wc -l)

if [ "$FOUND" -eq 12 ]; then
    pass "ResourceQuotas deployed"
else
    fail "ResourceQuotas deployment failed"
fi

#######################################################
# LimitRanges
#######################################################

kubectl apply -f kubernetes/limits >/dev/null

FOUND=$(kubectl get limitrange -A --no-headers | wc -l)

if [ "$FOUND" -eq 12 ]; then
    pass "LimitRanges deployed"
else
    fail "LimitRanges deployment failed"
fi

#######################################################
# ConfigMaps
#######################################################

kubectl apply -f kubernetes/configmaps >/dev/null

FOUND=$(kubectl get configmap -A --no-headers | grep training-config | wc -l)

if [ "$FOUND" -eq 12 ]; then
    pass "ConfigMaps deployed"
else
    fail "ConfigMaps deployment failed"
fi

#######################################################
# Secrets
#######################################################

kubectl apply -f kubernetes/secrets >/dev/null

FOUND=$(kubectl get secret -A --no-headers | grep training-secret | wc -l)

if [ "$FOUND" -eq 12 ]; then
    pass "Secrets deployed"
else
    fail "Secrets deployment failed"
fi

echo
echo "======================================="
echo "Verification Summary"
echo "======================================="
echo

echo "Passed : $PASS"
echo "Failed : $FAIL"

echo

if [ "$FAIL" -eq 0 ]; then
    echo -e "${GREEN}Platform verification successful.${NC}"
else
    echo -e "${RED}Platform verification failed.${NC}"
    exit 1
fi

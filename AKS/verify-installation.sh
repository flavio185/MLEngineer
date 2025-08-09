#!/bin/bash

# Verification script for KServe installation
# This script checks if all KServe components are properly installed and running

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting KServe installation verification...${NC}"

# Function to check if pods are running
check_pods() {
    local namespace=$1
    local label=$2
    local component=$3
    
    echo -e "${YELLOW}Checking $component...${NC}"
    
    local running_pods=$(kubectl get pods -n $namespace -l $label --no-headers 2>/dev/null | grep "Running" | wc -l)
    local total_pods=$(kubectl get pods -n $namespace -l $label --no-headers 2>/dev/null | wc -l)
    
    if [ $running_pods -gt 0 ] && [ $running_pods -eq $total_pods ]; then
        echo -e "${GREEN}✓ $component is running ($running_pods/$total_pods pods)${NC}"
        return 0
    else
        echo -e "${RED}✗ $component is not running ($running_pods/$total_pods pods)${NC}"
        return 1
    fi
}

# Function to check deployment status
check_deployment() {
    local namespace=$1
    local deployment=$2
    
    echo -e "${YELLOW}Checking deployment $deployment in namespace $namespace...${NC}"
    
    local ready=$(kubectl get deployment $deployment -n $namespace -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
    local desired=$(kubectl get deployment $deployment -n $namespace -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "1")
    
    if [ "$ready" == "$desired" ] && [ "$ready" != "0" ]; then
        echo -e "${GREEN}✓ $deployment is ready ($ready/$desired replicas)${NC}"
        return 0
    else
        echo -e "${RED}✗ $deployment is not ready ($ready/$desired replicas)${NC}"
        return 1
    fi
}

# Function to check service
check_service() {
    local namespace=$1
    local service=$2
    
    echo -e "${YELLOW}Checking service $service in namespace $namespace...${NC}"
    
    if kubectl get service $service -n $namespace --no-headers 2>/dev/null | grep -q "ClusterIP\|LoadBalancer"; then
        echo -e "${GREEN}✓ $service service is available${NC}"
        return 0
    else
        echo -e "${RED}✗ $service service is not available${NC}"
        return 1
    fi
}

# Function to check CRDs
check_crd() {
    local crd=$1
    
    echo -e "${YELLOW}Checking CRD $crd...${NC}"
    
    if kubectl get crd $crd --no-headers 2>/dev/null | grep -q "True"; then
        echo -e "${GREEN}✓ $crd CRD is installed${NC}"
        return 0
    else
        echo -e "${RED}✗ $crd CRD is not installed${NC}"
        return 1
    fi
}

# Main verification function
verify_installation() {
    local all_good=true
    
    echo -e "${GREEN}=== KServe Installation Verification ===${NC}"
    
    # Check Istio components
    echo -e "\n${YELLOW}--- Istio Components ---${NC}"
    check_deployment "istio-system" "istiod" || all_good=false
    check_deployment "istio-system" "istio-ingressgateway" || all_good=false
    check_service "istio-system" "istiod" || all_good=false
    
    # Check Knative components
    echo -e "\n${YELLOW}--- Knative Components ---${NC}"
    check_deployment "knative-serving" "controller" || all_good=false
    check_deployment "knative-serving" "webhook" || all_good=false
    check_deployment "knative-serving" "activator" || all_good=false
    check_deployment "knative-serving" "autoscaler" || all_good=false
    
    # Check cert-manager components
    echo -e "\n${YELLOW}--- cert-manager Components ---${NC}"
    check_deployment "cert-manager" "cert-manager" || all_good=false
    check_deployment "cert-manager" "cert-manager-cainjector" || all_good=false
    check_deployment "cert-manager" "cert-manager-webhook" || all_good=false
    
    # Check KServe components
    echo -e "\n${YELLOW}--- KServe Components ---${NC}"
    check_deployment "kserve" "kserve-controller-manager" || all_good=false
    check_service "kserve" "kserve-webhook-server-service" || all_good=false
    
    # Check CRDs
    echo -e "\n${YELLOW}--- Custom Resource Definitions ---${NC}"
    check_crd "inferenceservices.serving.kserve.io" || all_good=false
    check_crd "trainedmodels.serving.kserve.io" || all_good=false
    check_crd "clusterservingruntimes.serving.kserve.io" || all_good=false
    
    # Summary
    echo -e "\n${GREEN}=== Verification Summary ===${NC}"
    if [ "$all_good" = true ]; then
        echo -e "${GREEN}✓ All KServe components are properly installed and running${NC}"
        echo -e "${GREEN}You can now create InferenceServices to serve your ML models${NC}"
    else
        echo -e "${RED}✗ Some components are not properly installed${NC}"
        echo -e "${YELLOW}Please check the failed components above${NC}"
    fi
    
    return $all_good
}

# Function to check sample deployment
check_sample_deployment() {
    echo -e "\n${YELLOW}--- Sample Deployment Check ---${NC}"
    
    if kubectl get inferenceservice sklearn-iris --no-headers 2>/dev/null; then
        echo -e "${GREEN}✓ Sample InferenceService 'sklearn-iris' exists${NC}"
        
        local status=$(kubectl get inferenceservice sklearn-iris -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}')
        if [ "$status" == "True" ]; then
            echo -e "${GREEN}✓ Sample InferenceService is ready${NC}"
            
            local url=$(kubectl get inferenceservice sklearn-iris -o jsonpath='{.status.url}')
            echo -e "${GREEN}Service URL: $url${NC}"
        else
            echo -e "${YELLOW}⚠ Sample InferenceService is not ready yet${NC}"
        fi
    else
        echo -e "${YELLOW}ℹ No sample InferenceService found${NC}"
    fi
}

# Function to display cluster info
display_cluster_info() {
    echo -e "\n${GREEN}=== Cluster Information ===${NC}"
    
    echo -e "${YELLOW}Cluster:${NC} $(kubectl config current-context)"
    echo -e "${YELLOW}Kubernetes Version:${NC} $(kubectl version --short --client | grep Client | cut -d' ' -f3)"
    echo -e "${YELLOW}Node Count:${NC} $(kubectl get nodes --no-headers | wc -l)"
    echo -e "${YELLOW}Node Sizes:${NC}"
    kubectl get nodes -o custom-columns=NAME:.metadata.name,SIZE:.metadata.labels.kubernetes\\.azure\\.com/node-image-version --no-headers
    
    echo -e "\n${YELLOW}Resource Usage:${NC}"
    kubectl top nodes 2>/dev/null || echo "Metrics server not available"
}

# Main execution
main() {
    verify_installation
    
    # Optional checks
    if [ "$1" == "--with-sample" ]; then
        check_sample_deployment
    fi
    
    if [ "$1" == "--with-info" ] || [ "$1" == "--with-sample" ]; then
        display_cluster_info
    fi
}

# Execute main function with arguments
main "$@"

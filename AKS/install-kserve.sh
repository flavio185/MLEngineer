#!/bin/bash

# KServe Installation Script for AKS Cluster
# This script installs KServe with all required dependencies on your AKS cluster

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
RESOURCE_GROUP="MLProjects"
CLUSTER_NAME="aks-cluster-datamaster"
LOCATION="westus3"
NAMESPACE="kserve"

echo -e "${GREEN}Starting KServe installation on AKS cluster: $CLUSTER_NAME${NC}"

# Function to check prerequisites
check_prerequisites() {
    echo -e "${YELLOW}Checking prerequisites...${NC}"
    
    # Check Azure CLI
    if ! command -v az &> /dev/null; then
        echo -e "${RED}Azure CLI not found. Please install it first.${NC}"
        exit 1
    fi
    
    # Check kubectl
    if ! command -v kubectl &> /dev/null; then
        echo -e "${RED}kubectl not found. Installing...${NC}"
        az aks install-cli
    fi
    
    # Check Helm
    if ! command -v helm &> /dev/null; then
        echo -e "${RED}Helm not found. Installing...${NC}"
        curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    fi
    
    echo -e "${GREEN}Prerequisites check complete${NC}"
}

# Function to configure kubectl
configure_kubectl() {
    echo -e "${YELLOW}Configuring kubectl access...${NC}"
    
    # Get credentials
    az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --overwrite-existing
    
    # Verify connection
    kubectl cluster-info
    
    echo -e "${GREEN}kubectl configured successfully${NC}"
}

# Function to check cluster resources
check_cluster_resources() {
    echo -e "${YELLOW}Checking cluster resources...${NC}"
    
    # Get node information
    NODE_COUNT=$(kubectl get nodes --no-headers | wc -l)
    NODE_SIZE=$(kubectl get nodes -o jsonpath='{.items[0].metadata.labels.kubernetes\.azure\.com/node-image-version}' | cut -d'_' -f2)
    
    echo "Current cluster has $NODE_COUNT node(s)"
    echo "Node size: $NODE_SIZE"
    
    # Check if we need to scale up
    if [[ "$NODE_SIZE" == *"Standard_B2s"* ]]; then
        echo -e "${YELLOW}Warning: Standard_B2s might be undersized for KServe${NC}"
        echo -e "${YELLOW}Consider scaling up to Standard_D4s_v3 or adding more nodes${NC}"
        echo -e "${YELLOW}Continue with current setup? (y/n)${NC}"
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            echo "Please scale up your cluster first:"
            echo "az aks nodepool scale --resource-group $RESOURCE_GROUP --cluster-name $CLUSTER_NAME --name nodepool1 --node-count 2 --node-vm-size Standard_D4s_v3"
            exit 1
        fi
    fi
}

# Function to install Istio
install_istio() {
    echo -e "${YELLOW}Installing Istio service mesh...${NC}"
    
    # Download Istio
    curl -L https://github.com/istio/istio/releases/download/1.27.1/istio-1.27.1-linux-amd64.tar.gz | tar xz
    cd istio-1.27.1
    export PATH=$PWD/bin:$PATH
    
    # Install Istio
    istioctl install --set values.pilot.resources.requests.memory=512Mi --skip-confirmation
    
    # Enable Istio injection in default namespace
    kubectl label namespace default istio-injection=enabled
    
    # Verify installation
    kubectl get pods -n istio-system
    
    cd ..
    echo -e "${GREEN}Istio installed successfully${NC}"
}

# Function to install Knative Serving
install_knative() {
    echo -e "${YELLOW}Installing Knative Serving...${NC}"
    
    # Install Knative CRDs
    kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.19.0/serving-crds.yaml
    
    # Install Knative Serving core components
    kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.19.0/serving-core.yaml
    
    # Install Knative Istio integration
    kubectl apply -f https://github.com/knative/net-istio/releases/download/knative-v1.19.0/net-istio.yaml
    
    # Wait for Knative to be ready
    kubectl wait --for=condition=available --timeout=600s deployment/controller -n knative-serving
    
    echo -e "${GREEN}Knative Serving installed successfully${NC}"
}

# Function to install cert-manager
install_cert_manager() {
    echo -e "${YELLOW}Installing cert-manager...${NC}"
    
    # Install cert-manager
    kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.18.2/cert-manager.yaml
    
    # Wait for cert-manager to be ready
    kubectl wait --for=condition=available --timeout=600s deployment/cert-manager -n cert-manager
    kubectl wait --for=condition=available --timeout=600s deployment/cert-manager-cainjector -n cert-manager
    kubectl wait --for=condition=available --timeout=600s deployment/cert-manager-webhook -n cert-manager
    
    echo -e "${GREEN}cert-manager installed successfully${NC}"
}

# Function to install KServe
install_kserve() {
    echo -e "${YELLOW}Installing KServe...${NC}"
    
    # Create kserve namespace
    kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
    
    # Install KServe
    kubectl apply -f https://github.com/kserve/kserve/releases/download/v0.15.2/kserve.yaml
    
    # Install KServe built-in serving runtimes
    kubectl apply -f https://github.com/kserve/kserve/releases/download/v0.15.2/kserve-runtimes.yaml
    
    # Wait for KServe to be ready
    kubectl wait --for=condition=available --timeout=600s deployment/kserve-controller-manager -n kserve
    
    echo -e "${GREEN}KServe installed successfully${NC}"
}

# Function to verify installation
verify_installation() {
    echo -e "${YELLOW}Verifying installation...${NC}"
    
    echo "Checking pods in istio-system namespace:"
    kubectl get pods -n istio-system
    
    echo "Checking pods in knative-serving namespace:"
    kubectl get pods -n knative-serving
    
    echo "Checking pods in cert-manager namespace:"
    kubectl get pods -n cert-manager
    
    echo "Checking pods in kserve namespace:"
    kubectl get pods -n kserve
    
    echo -e "${GREEN}Installation verification complete${NC}"
}

# Function to create sample deployment
create_sample_deployment() {
    echo -e "${YELLOW}Creating sample KServe deployment...${NC}"
    
    cat <<EOF > sample-model.yaml
apiVersion: serving.kserve.io/v1beta1
kind: InferenceService
metadata:
  name: sklearn-iris
spec:
  predictor:
    model:
      modelFormat:
        name: sklearn
      storageUri: "gs://kfserving-examples/models/sklearn/1.0/model"
EOF
    
    kubectl apply -f sample-model.yaml
    
    echo -e "${GREEN}Sample deployment created. Check status with: kubectl get inferenceservices${NC}"
}

# Main execution
main() {
    check_prerequisites
    configure_kubectl
    check_cluster_resources
    
    echo -e "${GREEN}Starting KServe installation...${NC}"
    
    install_istio
    install_knative
    install_cert_manager
    install_kserve
    
    verify_installation
    
    echo -e "${GREEN}KServe installation complete!${NC}"
    echo -e "${YELLOW}You can now create InferenceServices to serve your ML models${NC}"
    
    # Optional: create sample deployment
    echo -e "${YELLOW}Would you like to create a sample deployment? (y/n)${NC}"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        create_sample_deployment
    fi
}

# Execute main function
main

#!/bin/bash

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI not found. Please install it to proceed."
    exit 1
fi

# Variables
RESOURCE_GROUP="MLProjects"
CLUSTER_NAME="aks-cluster-datamaster"
LOCATION="eastus"
KUBERNETES_VERSION="1.33.2"
NODE_SIZE="Standard_DS2_v2"
NODE_COUNT=3
OUTPUT_FILE="az_aks_output.log"
> "$OUTPUT_FILE"

# Usage instructions
if [ -z "$1" ]; then
  echo "Usage: $0 [createrg|createaks|getcreds|deleteaks|deleterg]"
  exit 1
fi

# Create resource group
if [ "$1" == "createrg" ]; then
  echo "📦 Creating resource group $RESOURCE_GROUP in $LOCATION" | tee -a "$OUTPUT_FILE"
  if ! az group create --name "$RESOURCE_GROUP" --location "$LOCATION" 2>&1 | tee -a "$OUTPUT_FILE"; then
    echo "❌ Failed to create resource group" | tee -a "$OUTPUT_FILE"
    exit 1
  fi
fi

# Create AKS cluster
if [ "$1" == "createaks" ]; then
  echo "🚀 Creating AKS cluster $CLUSTER_NAME in $LOCATION" | tee -a "$OUTPUT_FILE"
  if ! az aks create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$CLUSTER_NAME" \
    --node-count "$NODE_COUNT" \
    --node-vm-size "$NODE_SIZE" \
    --enable-managed-identity \
    --generate-ssh-keys \
    >> "$OUTPUT_FILE"; then
    echo "❌ Failed to create AKS cluster" | tee -a "$OUTPUT_FILE"
    exit 1
  fi
fi

# Get AKS credentials
if [ "$1" == "getcreds" ]; then
  echo "🔑 Getting AKS credentials for $CLUSTER_NAME" | tee -a "$OUTPUT_FILE"
  sleep 2
  if ! az aks get-credentials --resource-group "$RESOURCE_GROUP" --name "$CLUSTER_NAME" | tee -a "$OUTPUT_FILE"; then
    echo "❌ Failed to get AKS credentials" | tee -a "$OUTPUT_FILE"
    exit 1
  fi
  export KUBECONFIG=/home/flavio185/.kube/config
fi

# Delete AKS cluster
if [ "$1" == "deleteaks" ]; then
  echo "⚠️ Deleting AKS cluster $CLUSTER_NAME" | tee -a "$OUTPUT_FILE"
  read -p "Are you sure you want to delete the AKS cluster '$CLUSTER_NAME'? (y/N): " confirm
  if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    if ! az aks delete --name "$CLUSTER_NAME" --resource-group "$RESOURCE_GROUP" --yes | tee -a "$OUTPUT_FILE"; then
      echo "❌ Failed to delete AKS cluster" | tee -a "$OUTPUT_FILE"
      exit 1
    fi
  else
    echo "❌ Deletion aborted by user." | tee -a "$OUTPUT_FILE"
  fi
fi

# Delete resource group
if [ "$1" == "deleterg" ]; then
  echo "⚠️ Deleting resource group $RESOURCE_GROUP" | tee -a "$OUTPUT_FILE"
  read -p "Are you sure you want to delete the resource group '$RESOURCE_GROUP'? (y/N): " confirm
  if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    if ! az group delete --name "$RESOURCE_GROUP" --yes --no-wait | tee -a "$OUTPUT_FILE"; then
      echo "❌ Failed to delete resource group" | tee -a "$OUTPUT_FILE"
      exit 1
    fi
  else
    echo "❌ Deletion aborted by user." | tee -a "$OUTPUT_FILE"
  fi
fi

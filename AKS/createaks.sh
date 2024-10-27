

#!/bin/bash

# Check if Azure CLI is installed
if ! command -v az &> /dev/null
then
    echo "Azure CLI could not be found. Please install it to proceed."
    exit 1
fi

# login
# az login --scope https://management.core.windows.net//.default

# Variables
RESOURCE_GROUP="DataMaster2024"
CLUSTER_NAME="aks-cluster-datamaster"
LOCATION="eastus"
NODE_SIZE="Standard_B2s"
NODE_COUNT=1

OUTPUT_FILE="az_aks_output.log"
> $OUTPUT_FILE

if [ "$1" == "" ]; then
  echo "Usage: $0 [createrg|createaks|getcreds]"
  exit 1
fi
# Create a resource group if option createrg is passed to the script
if [ "$1" == "createrg" ]; then
  echo "Creating resource group $RESOURCE_GROUP in $LOCATION" >> $OUTPUT_FILE
  if ! az group create --name $RESOURCE_GROUP --location $LOCATION  2>&1 | tee -a $OUTPUT_FILE; then
    echo "Failed to create resource group" >> $OUTPUT_FILE
    exit 1
  fi
fi

# Create an AKS cluster
if [ "$1" == "createaks" ]; then
  echo "Creating AKS cluster $CLUSTER_NAME in $LOCATION" >> $OUTPUT_FILE
  if ! az aks create \
    --resource-group $RESOURCE_GROUP \
    --name $CLUSTER_NAME \
    --node-count $NODE_COUNT \
    --node-vm-size $NODE_SIZE \
    --enable-managed-identity \
    --generate-ssh-keys \
    >> $OUTPUT_FILE; then
    echo "Failed to create AKS cluster"  2>&1 | tee -a $OUTPUT_FILE
    exit 1
  fi
fi

# Get AKS credentials
if [ "$1" == "getcreds" ]; then
  echo "Getting AKS credentials for $CLUSTER_NAME" | tee -a $OUTPUT_FILE
  sleep 2
  if ! az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME 2>&1 | tee -a $OUTPUT_FILE; then
    echo "Failed to get AKS credentials" | tee -a $OUTPUT_FILE
    exit 1
  fi
fi
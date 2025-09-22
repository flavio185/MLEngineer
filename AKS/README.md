# 1
aks_cluster_manager.sh createaks
aks_cluster_manager.sh getcreds
# 2
auto-install-kserve.sh

kubectl create namespace ml-default-payment-model-ns
kubectl label namespace ml-default-payment-model-ns istio-injection=enabled

# 3 
install mlflow

# 4
Install ray serve

# Train model.

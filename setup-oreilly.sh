#1 - Spin up a aks cluster
az aks create \
--resource-group $resource \
--name MLWork \
--node-count 3 \
--generate-ssh-keys

az aks get-credentials --resource-group $resource --name MLWork

#2 - Install Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

#3 - Clone git
	
#4 - Apply helm template
cd helm-chart/mlflow-chart
helm install mlflow . --namespace mlflow-ns --create-namespace 

kubectl config set-context --current --namespace=mlflow-ns
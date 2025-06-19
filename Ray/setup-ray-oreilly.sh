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


helm repo add kuberay https://ray-project.github.io/kuberay-helm/
helm repo update
#Install Operator
# Install both CRDs and KubeRay operator v1.3.0.
helm install kuberay-operator kuberay/kuberay-operator --version 1.3.0 --namespace ray-ns --create-namespace 


#Install a ray job:
#https://docs.ray.io/en/latest/cluster/kubernetes/getting-started/rayjob-quick-start.html#step-3-install-a-rayjob
#Run a test job.
kubectl create namespace app-ns
kubectl config set-context --current --namespace=app-ns

#https://docs.ray.io/en/latest/cluster/kubernetes/getting-started/raycluster-quick-start.html
# Step 3: Deploy a RayCluster custom resource
# Once the KubeRay operator is running, you’re ready to deploy a RayCluster. Create a RayCluster Custom Resource (CR) in the default namespace.

helm install raycluster kuberay/ray-cluster --version 1.3.0 --namespace app-ns


kubectl apply -f https://raw.githubusercontent.com/ray-project/kuberay/v1.3.0/ray-operator/config/samples/ray-job.shutdown.yaml -n app-ns
kubectl apply -f https://raw.githubusercontent.com/ray-project/kuberay/v1.3.0/ray-operator/config/samples/ray-job.sample.yaml -n app-ns

kubectl get raycluster -n app-ns


kubectl port-forward service/rayjob-sample-pararell-raycluster-rmzmb-head-svc 8265:8265 > /dev/null &
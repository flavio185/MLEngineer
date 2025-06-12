helm repo add kuberay https://ray-project.github.io/kuberay-helm/
helm repo update
#Install Operator
# Install both CRDs and KubeRay operator v1.3.0.
helm install kuberay-operator kuberay/kuberay-operator --version 1.3.0 --namespace ray-ns --create-namespace 

#https://docs.ray.io/en/latest/cluster/kubernetes/getting-started/raycluster-quick-start.html
# Step 3: Deploy a RayCluster custom resource
# Once the KubeRay operator is running, you’re ready to deploy a RayCluster. Create a RayCluster Custom Resource (CR) in the default namespace.

helm install raycluster kuberay/ray-cluster --version 1.3.0 --namespace ray-ns

#Install a ray job:
#https://docs.ray.io/en/latest/cluster/kubernetes/getting-started/rayjob-quick-start.html#step-3-install-a-rayjob
#Run a test job.
kubectl create namespace app-ns
kubectl apply -f https://raw.githubusercontent.com/ray-project/kuberay/v1.3.0/ray-operator/config/samples/ray-job.shutdown.yaml -n app-ns

kubectl get raycluster -n app-ns
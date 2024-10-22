podman machine init
podman machine start

set NO_PROXY=localhost,127.0.0.1,10.96.0.0/12,192.168.59.0/24,192.168.49.0/24,192.168.39.0/24

minikube start

minikube kubectl -- get pods --namespace mlflow

minikube kubectl -- describe pod mlflow-58df7895bf-tztxh -n mlflow
minikube kubectl -- logs mlflow-58df7895bf-tztxh -n mlflow
kubectl get configmap -n mlflow
kubectl get secret -n mlflow
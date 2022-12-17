https://itsmetommy.com/2021/07/30/kubernetes-install-grafana-prometheus-on-gke-using-helm-bitnami/

helm install grafana bitnami/grafana -f grafana/custom_values.yaml 



Pegar senha para conexão.
echo "Password: $(kubectl get secret grafana-admin \
-o jsonpath="{.data.GF_SECURITY_ADMIN_PASSWORD}" | base64 --decode)"

helm install prometheus \
  -n monitoring \
  -f custom_values.yaml \
  --version 6.1.4 \
  bitnami/kube-prometheus


helm install my-release bitnami/argo-cd

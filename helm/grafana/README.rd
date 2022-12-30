https://itsmetommy.com/2021/07/30/kubernetes-install-grafana-prometheus-on-gke-using-helm-bitnami/


helm repo add bitnami https://charts.bitnami.com/bitnami


helm install grafana bitnami/grafana -f grafana_values.yaml
#helm install grafana bitnami/grafana --set service.type=LoadBalancer --set=admin.password="admin"


Pegar senha para conexão.
echo "Password: $(kubectl get secret grafana-admin \
-o jsonpath="{.data.GF_SECURITY_ADMIN_PASSWORD}" | base64 --decode)"


helm install prometheus \
  -n monitoring \
  bitnami/kube-prometheus
  --version 6.1.4 \

  #-f custom_values.yaml \

helm install my-release bitnami/argo-cd

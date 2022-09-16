# MLEngineer

Start jenkins-get-started-vm na azure.

### Train model.
Login to Jenkins: http://20.121.252.249:8080/

Run ModelTrainAndSave on Jenkins.

Pass git project as parameter: https://github.com/flavio185/ml-salary-predict.git

Check Logs.

### Validate model.

Open Azure ML Studio. https://ml.azure.com/?tid=51fb973d-85c3-4d97-9707-645e645454a4&wsid=/subscriptions/0888be57-ee47-4ba5-be90-b464e3daebf6/resourceGroups/DataMasters/providers/Microsoft.MachineLearningServices/workspaces/data-masters-workspace

Go to Jobs.

### Create GKE structure.

 - 

Go to Jenkins.

Create GKE - Google Kubernetes Engine.

Go to GKE to validate.:
https://console.cloud.google.com/kubernetes/list/overview?project=mlopscase

Criado GKE Cluster.

Criado 3 nodes conforme padrão GKE.

### Deploy Model Endpoint.

Go to Jenkins

conteinerizeMLModel - Deixa o modelo preparado para deploy onde for necessário.

deloy_to_gke - Envia imagem para gke e faz o deploy 

Accesso ao workspace para validação. https://console.cloud.google.com/kubernetes/workload/overview?project=mlopscase

Get service ip for testing.

### Test



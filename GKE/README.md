###Criação de docker com Terraform, Kubectl e gcloud sdk.
sudo docker build -t terraform_gcloud_sdk .

#gcloud config Gerar key.json com a service account para login no gcloud

gcloud auth activate-service-account mlops-service-account@mlopscase.iam.gserviceaccount.com \
 --key-file=key.json --project=mlopscase

export GOOGLE_APPLICATION_CREDENTIALS=key.json


#Habilitar api Service Usage API
console.
#babilitar gcloud google_compute_network vpc
gcloud services enable 
google_compute_network 
vpc
google_container_cluster
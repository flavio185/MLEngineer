# Learn Terraform - Provision a GKE Cluster

This repo is a companion repo to the [Provision a GKE Cluster learn guide](https://learn.hashicorp.com/terraform/kubernetes/provision-gke-cluster), containing Terraform configuration files to provision an GKE cluster on GCP.

This sample repo also creates a VPC and subnet for the GKE cluster. This is not
required but highly recommended to keep your GKE cluster isolated.

##################################

#gcloud config Gerar key.json com a service account para login no gcloud

gcloud auth activate-service-account mlops-service-account@mlopscase.iam.gserviceaccount.com \
 --key-file=key.json --project=mlopscase

export GOOGLE_APPLICATION_CREDENTIALS=key.json


#Habilitar api Service Usage API
console.
#habilitar gcloud 
#
Compute Engine API
Cloud Monitoring API
Kubernetes Engine API
Service Usage API
#script to configure kubectl command line.

WORKSPACE_NAME='data-masters-workspace'
RESOURCE_GROUP='DataMasters'
REGION='us-central1'
PROJECT_ID='mlopscase'
REPOSITORY='mlopscase'

configure_kubectl (){
    echo "Build step: Configurando kubectl para o projeto."
    CLUSTER_NAME=mlopscase-gke
    #
    gcloud container clusters \
    get-credentials $CLUSTER_NAME \
    --region $REGION
}
configure_kubectl


#Script de deploy no GKE utilizado no jenkins

echo "Build step: Clonando projeto e setando variaveis de build"
git clone $GIT_PROJECT
export PROJECT_DIR=$(echo $GIT_PROJECT | awk -F/ '{print $NF}'| sed 's/.git//g')
cd $PROJECT_DIR
export APP=$PROJECT_DIR
export GITHUB_SHA=$(git rev-parse HEAD)
#set vars
export CPU="200m"
export MEM="512m"
export PROBE_CONTEXT="/health"
export REGION=us-central1
export PROJECT_ID=mlopscase
export REPOSITORY=mlopscase
export IMAGE=$PROJECT_DIR
export CONTAINER_IMAGE="$REGION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY/$IMAGE:$GITHUB_SHA"

gcloud_login () {
  echo "Build step: Autenticando ao  Google Cloud"
  echo $CPU
  cp $GKE_KEY_JSON $WORKSPACE/key.json
  GCLOUD_LOGIN_INFO=mlops-service-account@mlopscase.iam.gserviceaccount.com
  GCLOUD_PROJECT=mlopscase
  #
  gcloud auth activate-service-account $GCLOUD_LOGIN_INFO \
  --key-file=$WORKSPACE/key.json --project=$GCLOUD_PROJECT
  #
  export GOOGLE_APPLICATION_CREDENTIALS=$WORKSPACE/key.json
}
gcloud_login

build_image () {
  echo "Build step: Fazendo build da imagem"
  #
  cd $WORKSPACE/$PROJECT_DIR/FastAPI
  #
  sudo docker build --no-cache --tag "$CONTAINER_IMAGE" .
}
build_image

create_set_google_artifactory_repo () {
  echo "Build step: Criando repositório no Google Artifact repository e configurando no docker."
  if ( ! gcloud artifacts repositories  list | grep "$REPOSITORY" )  ; then  
    echo "Criando repositorio"
    gcloud artifacts repositories create $REPOSITORY \
    --repository-format=docker --location=$REGION \
    --description="Docker repository"
  else
    echo "Repositorio $REPOSITORY existe"
  fi
  echo "Configurando repositório para push"
  gcloud auth configure-docker $REGION-docker.pkg.dev --quiet
}
create_set_google_artifactory_repo

publish_image () {
  echo "Build step: Publicando a imagem no Google Artifact Registry."  
  # Push the Docker image to Google Artifact Registry
  sudo docker push "$CONTAINER_IMAGE"
}
publish_image

configure_kubectl (){
  echo "Build step: Configurando kubectl para o projeto."  
  CLUSTER_NAME=mlopscase-gke
  #
  gcloud container clusters \
  get-credentials $CLUSTER_NAME \
  --region $REGION
}
configure_kubectl

configure_deployment_yaml () {   
  echo "Build step: Deploy the Docker image no GKE cluster."
  cd $WORKSPACE/$PROJECT_DIR/manifest
  cat deployment.yaml | 
  yq e ".metadata.name = \"${APP}\""  - |
  yq e ".metadata.labels.app = \"${APP}\""  - |
  yq e ".spec.selector.matchLabels.app = \"${APP}\""  - |
  yq e ".spec.template.metadata.labels.app = \"${APP}\""  - |
  yq e ".spec.template.spec.containers[].name = \"${APP}\""  - |
  yq e ".spec.template.spec.containers[].image = \"${CONTAINER_IMAGE}\""  - |
  yq e ".spec.template.spec.containers[].resources.requests.cpu = \"${CPU}\""  - |
  yq e ".spec.template.spec.containers[].resources.requests.memory = \"${MEM}\""  - |
  yq e ".spec.template.spec.containers[].livenessProbe.httpGet.path = \"${PROBE_CONTEXT}\""  - |
  yq e ".spec.template.spec.containers[].startupProbe.httpGet.path = \"${PROBE_CONTEXT}\""  - \
  > deployment_tmp.yaml
  cp deployment_tmp.yaml deployment.yaml
  rm -rf deployment_tmp.yaml; 
}
configure_deployment_yaml


configure_service_yaml () {   
  echo "Build step: Deploy the Docker image no GKE cluster."
  cd $WORKSPACE/$PROJECT_DIR/manifest
  cat service_lb.yaml | 
  yq e ".metadata.name = \"${APP}\""  - |
  yq e ".metadata.labels.app = \"${APP}\""  - |
  yq e ".spec.selector.app = \"${APP}\""  - \
  > service_lb_tmp.yaml
  cp service_lb_tmp.yaml service_lb.yaml
  rm -rf service_lb_tmp.yaml 
}
configure_service_yaml


echo "Build step: Deploy the Docker image no GKE cluster."
apply_deployment () {
  echo "Build step: Aplicando configuração de deployment para o cluster GKE."   
  kubectl apply -f $WORKSPACE/$PROJECT_DIR/manifest/deployment.yaml 
}
apply_deployment

echo "Build step: Deploy the Docker image no GKE cluster."
apply_service () {
  echo "Build step: Aplicando configuração de deployment para o cluster GKE."   
  kubectl apply -f $WORKSPACE/$PROJECT_DIR/manifest/service_lb.yaml 
}
apply_service

start_kubernetes_deploymentrollout () {
  echo "Build step: Aplicando configuração de deployment para o cluster GKE."   
  kubectl rollout restart deployment  $APP
}
#start_kubernetes_deploymentrollout


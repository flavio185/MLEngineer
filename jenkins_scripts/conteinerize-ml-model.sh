
#Clone project
git clone $GIT_PROJECT
export PROJECT_DIR=$(echo $GIT_PROJECT | awk -F/ '{print $NF}'| sed 's/.git//g')
#Download model artifacts.
git clone https://github.com/flavio185/MLEngineer.git
sudo docker run \
    -e AZURE_CLIENT_SECRET=$AZURE_CLIENT_SECRET \
    -e AZURE_CLIENT_ID=$AZURE_CLIENT_ID \
    -e RESOURCE_GROUP=$RESOURCE_GROUP \
    -e WORKSPACE_NAME=$WORKSPACE_NAME \
    -e AZURE_SUBSCRIPTION_ID=$AZURE_SUBSCRIPTION_ID \
    -e AZURE_TENANT_ID=$AZURE_TENANT_ID \
    -e AZURE_STORAGE_ACCOUNT=$AZURE_STORAGE_ACCOUNT \
    -v $PWD/MLEngineer/jenkins_scripts/azure-experiment:/azure-experiment \
    python-az \
    /bin/bash -c "cd /azure-experiment && \
    python downloadModel.py model_name=$PROJECT_DIR version=$MODEL_VERSION
    "

sudo mv MLEngineer/jenkins_scripts/azure-experiment/output $PROJECT_DIR/API/app 
sudo rm -rf MLEngineer

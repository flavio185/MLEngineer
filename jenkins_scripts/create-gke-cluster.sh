git clone https://github.com/flavio185/MLEngineer.git
cp $GCLOUD_KEY_JSON MLEngineer/GKE/Terraform/key.json
chmod +x MLEngineer/GKE/Terraform/*.sh

#Copia estado se ja existe.
if [ -f /var/lib/jenkins/Terraform_Artifacts/create_gke_terraform.tfstate ]; then
  cp /var/lib/jenkins/Terraform_Artifacts/create_gke_terraform.tfstate ${WORKSPACE}/MLEngineer/GKE/Terraform/terraform.tfstate
fi

sudo docker run  -v ${WORKSPACE}/MLEngineer/GKE/Terraform:/Terraform terraform_gcloud_sdk /bin/bash -c "cd /Terraform; ./gcloud-auth.sh && export GOOGLE_APPLICATION_CREDENTIALS=key.json ; terraform init && terraform plan && terraform ${FUNCAO} -auto-approve "
 
cp ${WORKSPACE}/MLEngineer/GKE/Terraform/terraform.tfstate /var/lib/jenkins/Terraform_Artifacts/create_gke_terraform.tfstate

#build local jenkins
docker run -p 8080:8080 -p 50000:50000 -v /Users/t720370/Documents/jenkinsfiles:/home/jenkins_home --restart=on-failure jenkins/jenkins:lts-jdk11

#Create service principal name in Azure for connection with jenkins
#az ad sp create-for-rbac --name myServicePrincipalName

#List:
#az ad sp list --display-name myServicePrincipalName

pipeline {
  agent any
  environment {
    AZURE_SUBSCRIPTION_ID='0888be57-ee47-4ba5-be90-b464e3daebf6'
    AZURE_TENANT_ID='51fb973d-85c3-4d97-9707-645e645454a4'
    AZURE_STORAGE_ACCOUNT='teste3112268159'
  }
  stages {
    stage('Build') {
      steps {
        sh 'rm -rf *'
        sh 'mkdir text'
        sh 'echo Hello Azure Storage from Jenkins > ./text/hello.txt'
        sh 'date > ./text/date.txt'
      }

      post {
        success {
          withCredentials([usernamePassword(credentialsId: 'azuresp', 
                          passwordVariable: 'AZURE_CLIENT_SECRET', 
                          usernameVariable: 'AZURE_CLIENT_ID')]) {
            sh '''
              echo $container_name
              # Login to Azure with ServicePrincipal
              az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET -t $AZURE_TENANT_ID
              # Set default subscription
              az account set --subscription $AZURE_SUBSCRIPTION_ID
              # Execute upload to Azure
              az storage container create --account-name $AZURE_STORAGE_ACCOUNT --name nomedocontainer --auth-mode login
              az storage blob upload-batch --destination nomedocontainer --source ./text --account-name $AZURE_STORAGE_ACCOUNT
              # Logout from Azure
              az logout
            '''
          }
        }
      }
    }
  }
}

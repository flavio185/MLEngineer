GCLOUD_LOGIN_INFO=mlops-service-account@mlopscase.iam.gserviceaccount.com
GCLOUD_PROJECT=mlopscase

gcloud auth activate-service-account $GCLOUD_LOGIN_INFO \
 --key-file=key.json --project=$GCLOUD_PROJECT

 export GOOGLE_APPLICATION_CREDENTIALS=key.json

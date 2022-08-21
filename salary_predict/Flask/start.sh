#!/bin/bash
app="flask_prediction"
#No mac adicionar --platform linux/x86_64 
docker build -t ${app} .
docker run  -d -p 8080:80 \
  -v $PWD/app:/app ${app}
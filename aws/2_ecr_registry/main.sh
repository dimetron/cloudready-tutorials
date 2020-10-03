#!/bin/sh

echo "Creating ECR"
cd ./terraform

#initialize terraform plugins
terraform init

#create plan 
terraform plan -out plan.out

echo "Waiting 10 sec .."
sleep 10

#apply plan from previously created plan
terraform  apply  -auto-approve plan.out
terraform  output -json | jq

#get repo URL
ECRURL=$(terraform  output -json | jq '.repository_url.value' -r)

#login local docker
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin $ECRURL

#build image and push to the registry
export TAG=2.22
docker tag devops-cli:$TAG $ECRURL:$TAG
docker push $ECRURL:$TAG

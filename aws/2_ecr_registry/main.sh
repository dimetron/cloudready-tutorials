#!/bin/sh

echo "Creating ECR"
cd ./terraform

#initialize terraform plugins
terraform init

#create plan 
terraform plan -out plan.out

echo "Waiting 3 sec .."
sleep 3

#apply plan from previously created plan
terraform  apply  -auto-approve plan.out
terraform  output -json | jq

#get repo URL
ECRURL=$(terraform  output -json | jq '.repository_url.value' -r)
ECRURL_CLI=$(terraform  output -json | jq '.repository_url_cli.value' -r)
ECRURL_IMG=$(terraform  output -json | jq '.repository_url_img.value' -r)

#login local docker
echo $ECRURL
echo $ECRURL_CLI
echo $ECRURL_IMG
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin $ECRURL

#build image and push to the registry
set +x

export TAG=2.24
docker tag devops-cli:$TAG $ECRURL_CLI:$TAG
docker push $ECRURL_CLI:$TAG

docker pull amazonlinux:latest
docker push amazonlinux:latest $ECRURL_IMG:$TAG

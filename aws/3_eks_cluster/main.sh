#!/bin/sh

echo "Creating EKS"
cd ./terraform

#initialize terraform plugins
terraform init

#create plan 
terraform plan -out plan.out

echo "Waiting 30 sec .."
sleep 30

#apply plan from previously created plan
terraform  apply  -auto-approve plan.out
terraform  output -json | jq

#get repo URL
EKSURL=$(terraform  output -json)
#ECRURL_CLI=$(terraform  output -json | jq '.repository_url_cli.value' -r)
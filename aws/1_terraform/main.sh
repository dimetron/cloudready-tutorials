#!/bin/bash

export RG=eu-west-1
export OW=099720109477  #099720109477 owner canonical
export OW2=137112412989


#get list of regions in eu
if [ ! -f ./reference/describe_ec2_regions.json ]; then
	aws ec2 describe-regions --filters "Name=endpoint,Values=*eu*" > ./reference/describe_ec2_regions.json
fi

#get list of AZ in Ireland
if [ ! -f ./reference/describe-availability-zones_eu.json ]; then
	aws ec2 describe-availability-zones > ./reference/describe-availability-zones_eu.json
fi

#get list of AMI
if [ ! -f ./reference/describe-images.json ]; then
	aws ec2 describe-images --region  $RG --owners $OW --filters \
			Name=is-public,Values=true \
			Name=root-device-type,Values=ebs \
			Name=state,Values=available \
            Name=name,Values='*ubuntu-bionic-18.04-amd64-server-20180912' \
            Name=architecture,Values=x86_64  > ./reference/describe-images.json
    
    aws ec2 describe-images --region  $RG  --filters \
			Name=is-public,Values=true \
			Name=root-device-type,Values=ebs \
			Name=state,Values=available \
            Name=name,Values='*amzn2-ami-hvm*' \
            Name=architecture,Values=x86_64  > ./reference/describe-images-amzn2.json

 	aws ec2 describe-images --region  $RG --owners $OW2 --filters \
			Name=is-public,Values=true \
			Name=state,Values=available \
			Name=root-device-type,Values=ebs \
            Name=architecture,Values=x86_64  > ./reference/describe-images-all.json
	#to get custom tags
	#aws ec2 describe-images --filters Name=tag-key,Values=Custom Name=tag-value,Values=Linux1,Ubuntu1 --query 'Images[*].{ID:ImageId}'
fi

# output list of images
echo '@Regions'
cat ./reference/describe_ec2_regions.json | jq '.Regions[].RegionName'

echo '@ZoneName'
cat ./reference/describe-availability-zones_eu.json | jq '.AvailabilityZones[].ZoneName'

echo '@Images'
cat ./reference/describe-images.json | jq '.Images[].Description'

echo "Creating STAGE ENV"
cd ./environments/stage/

#initialize terraform plugins
terraform init

#create plan 
terraform plan -out plan.out

echo "Waiting 10 sec .."
sleep 10

#apply plan from previously created plan
terraform  apply  -auto-approve plan.out
terraform  output -json | jq

#get machine IP
export PUBLIC_IP=`terraform output  -json |  jq -r '.public_ip.value'`
echo Using PUBLIC_ID=$PUBLIC_IP

#test access
echo "++++++++++++++++++++++++"
nmap -Pn -p22,8080 $PUBLIC_IP
echo "++++++++++++++++++++++++"
#curl http://$PUBLIC_IP:8080
echo "++++++++++++++++++++++++"
echo "Dont forget to destroy - terraform destroy -force -auto-approve"
echo "Using: ssh ssh ec2-user@$PUBLIC_IP"
ssh -o ServerAliveInterval=60 ec2-user@$PUBLIC_IP

echo "All resource will be destroyed 5 sec ...";sleep 5
terraform  destroy -force -auto-approve 
sleep 5
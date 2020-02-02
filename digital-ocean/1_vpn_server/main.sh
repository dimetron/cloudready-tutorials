#!/bin/bash

#DOCUMENTATION 
#https://www.terraform.io/docs/providers/do/index.html

cd ./environments/vpn/

#cehck providers 
terraform providers


#initialize terraform plugins
terraform init

#create plan 
terraform plan -out plan.out

retVal=$?
if [ $retVal -ne 0 ]; then
    echo "Error in terraform plan."
    exit $retVal
fi

echo "Waiting 3 sec .."
sleep 3

#apply plan from previously created plan
terraform  apply  -auto-approve plan.out
terraform  output -json | jq

#get machine IP
export PUBLIC_IP=`terraform output  -json |  jq -r '.public_ip.value'`
echo Using PUBLIC_ID=$PUBLIC_IP

#test access
echo "-----------------------------------"
echo "Waiting for host to prepare ENV ..."

for retry in {1..10}
do
  #test ssh and wait for all tools to install
  ssh -oStrictHostKeyChecking=no root@$PUBLIC_IP hostname  > /dev/null 2>&1
  if [ $? -eq 0 ]
  then    
    ssh -oStrictHostKeyChecking=no root@$PUBLIC_IP hostname 
    break
    #install zsh for root
    #ssh root@$PUBLIC_IP 'apt-get install zsh'
    #ssh root@$PUBLIC_IP 'bash -c "sudo chsh -s /usr/bin/zsh root"'
    #ssh root@$PUBLIC_IP 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended'
  fi
  #echo -e "-- retry $retry --"
  #ssh -oStrictHostKeyChecking=no root@$PUBLIC_IP ps -ef | grep apt | grep -v refused
  sleep 30
done
echo "-----------------------------------"
doctl compute droplet list --format "ID,Name,PublicIPv4"
echo "-----------------------------------"

#curl http://$PUBLIC_IP:8080
echo "Dont forget to destroy - terraform destroy -force -auto-approve"
echo "Using: ssh root@$PUBLIC_IP"
echo "-----------------------------------"
echo "sed -i 's/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"agnoster\"/g' /root/.zshrc"

ssh -o ServerAliveInterval=60 root@$PUBLIC_IP

read -p "Destroy VM ? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
  echo "All resource will be destroyed 5 sec ... Ctrl+C to cancel ...";sleep 5
  sleep 5
  #terraform  destroy -force -auto-approve
fi
#!/bin/bash

#Please set your configuration here
CONFIG=(
btcpay_host:btcpay.hypergori.com
region:us-west1
zone:us-west1-a
vmtype:e2-medium
linuxType:ubuntu-2004-lts
diskSizeGb:500
diskType:pd-balanced
bitcoin-core-network:mainnet
crypt-1:btc
crypt-2: 
lightning-server:lnd
letsencrypt-email:hypergori@gmail.com
lightning-alias:
)

#convert config array to delimited string as properies for deployment-manager command
CONFIGS=$(IFS=, eval 'echo "${CONFIG[*]}"')
#find host name from config
for element in "${CONFIG[@]}"
do
    if [[ $element =~ btcpay_host ]]; then
        deployment_host="${element/btcpay_host:/}"
    fi
done

deployment_id=${deployment_host//./-}
domain_array=(${deployment_host//./ })
deployment_domain=${domain_array[1]}.${domain_array[2]}
domain_zone=${deployment_domain//./-}
vm_name=${deployment_id}-vm

echo "host name: $deployment_host"
echo "host domain: $deployment_domain"
echo "domain zone: $domain_zone"
echo "deployment id: $deployment_id"
echo "vm name: $vm_name"
echo on
echo "The information above looks correct [y/n]?"
read answer
if [[ ${answer^} != "Y" ]]; then
  echo "Sorry. Please fix host name or me! Exit."
  exit
fi
# check GCP project is set
if [ -z "${GOOGLE_CLOUD_PROJECT}"]; then
  echo "Please set GCP project."
  echo "for example, gcloud config set project PROJECT_NAME"
  exit
fi

echo "start deployment"
gcloud deployment-manager deployments describe  $deployment_id &> /dev/null
if [ $? -eq 0 ]; then
  echo "deleting existing deployment: $deployment_id"
  gcloud deployment-manager deployments delete  $deployment_id
fi

echo "creating deployment"
gcloud deployment-manager deployments create  $deployment_id --template vm.jinja --properties $CONFIGS

deployment_zone=`gcloud compute instances list --filter="NAME=$vm_name" | grep -Po 'ZONE: \K(.*)'`
echo "your vm's zone is $deployment_zone"

staticip=`gcloud compute instances describe $vm_name --zone=$deployment_zone | grep -Po 'natIP: \K(.*)'`
echo "your vm's ip address is $staticip"

echo "mapping the ip address to your DNS A record of deployment_host"
gcloud dns record-sets describe $deployment_host. --type=A  --zone=$domain_zone  &> /dev/null
if [ $? -eq 1 ]; then
  echo "creating A record"
  gcloud dns record-sets  create  $deployment_host.  --type=A --zone=$domain_zone --rrdatas=$staticip
else
  echo "updating A record"
  gcloud dns record-sets  update  $deployment_host.  --type=A --zone=$domain_zone --rrdatas=$staticip
fi
echo "$deployment_id-vm was deployed. Try to access the url  https://$deployment_host"
echo "Ihe SSL setup process would take a few minutes. please try again, if you cannot access the site."
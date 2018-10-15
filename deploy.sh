#!/bin/bash
if [ -z "$1" ]
  then
    echo "Specify the name of deployment as an argument .e.g.  deploy.sh btcpaytest1"
    exit 1
fi
export deploymentname=$1
gcloud deployment-manager deployments create  $deploymentname --config main.btcpay.yaml
echo "$deploymentname-vm was deployed." 
sleep 5
export staticip="`gcloud compute instances describe $deploymentname-vm | grep -Po 'natIP: \K(.*)'`"
if [[ ! -z "$staticip" ]]; then
    echo 'Congratulations! BtcPay Deployment is completed.'
    echo 'Now, do DNS mapping with static IP:' $staticip
    echo 'then, run change-domain.sh via ssh'
fi

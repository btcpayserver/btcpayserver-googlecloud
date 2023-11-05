#!/bin/bash
if [ -z "$1" ]
  then
    echo "Specify the host name of deployment as an argument .e.g. ./undeploy.sh  btcpay.hypergori.com "
    exit 1
fi
deployment_id=${1//./-}
gcloud deployment-manager deployments delete  $1
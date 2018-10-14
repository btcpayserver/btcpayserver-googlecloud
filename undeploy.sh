#!/bin/bash
if [ -z "$1" ]
  then
    echo "Specify the name of deployment as an argument .e.g.  undeploy.sh btcpaytest1"
    exit 1
fi
gcloud deployment-manager deployments delete  $1
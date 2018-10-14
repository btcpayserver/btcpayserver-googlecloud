Param(
    [parameter()]$deploymentname
)
If ($deploymentname -eq $null) {
    'Specify the name of deployment as an argument .e.g.  .\undeploy.ps1 btcpaytest1'
  }  Else {
    gcloud deployment-manager deployments delete  $deploymentname
} 

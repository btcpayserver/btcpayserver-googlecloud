Param(
    [parameter()]$deploymentname
)
If ($deploymentname -eq $null) {
    'Specify the name of deployment as an argument .e.g.  .\deploy.ps1 btcpaytest1'
  }  Else {
    gcloud deployment-manager deployments create  $deploymentname --config main.btcpay.yaml
    $staticip = gcloud compute instances describe $deploymentname-vm | select-string -Pattern 'natIP: (.*)' | ForEach-Object{ $_.Matches[0].Groups[1].Value}
    If ($staticip -ne $null){
        Write-Host 'Congratulations! BtcPay Deployment is completed.' -ForegroundColor red -BackgroundColor white  
        Write-Host 'Now, do DNS mapping with static IP:' -ForegroundColor red -BackgroundColor white  -NoNewline
        Write-Host  $staticip -ForegroundColor green -BackgroundColor red
        Write-Host 'then, run change-domain.sh via ssh' -ForegroundColor red -BackgroundColor white
    }
} 

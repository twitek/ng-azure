param (
  [string]$testno = ""
)

New-AzureRmResourceGroup -Name bam-t$testno -Location westeurope

$deployment = New-AzureRmResourceGroupDeployment -Name test$testno -ResourceGroupName bam-t$testno -TemplateParameterFile .\test${testno}.params.json -TemplateUri "https://raw.githubusercontent.com/bartekmo/ng-azure/ngf2/marketplace-barracuda-ngf/MainTemplate.json"

if ( $deployment.Outputs -ne $null ) {
  Write-Host "looks good!" -ForegroundColor "green"
} else {
  Write-Host "DUPA!" -ForegroundColor "red"
}

param (
  [string]$testno = ""
)

#(get-content -raw -path tests.json | convertfrom-json ).tests | ? run


# in case we're going to check the web ui...
add-type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
        ServicePoint srvPoint, X509Certificate certificate,
        WebRequest request, int certificateProblem) {
        return true;
    }
}
"@
$AllProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
[System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

$mytest=(get-content -raw -path tests.json | convertfrom-json).tests | ? indx -eq $testno
Write-Host '----------------------------------------------------------------------------------'
Write-Host "TEST: " -ForegroundColor "cyan" -nonewline
Write-Host $mytest.description -ForegroundColor "cyan"
Write-Host '----------------------------------------------------------------------------------'


$rg=Get-AzureRmResourceGroup -Name bam-t$testno -ErrorAction silentlycontinue -errorvariable rmNotFound
if ( $rmNotFound ) {
  Write-Host "Resource Group not found. deploying..."

  New-AzureRmResourceGroup -Name bam-t$testno -Location westeurope
  $deployment = New-AzureRmResourceGroupDeployment -Name test$testno -ResourceGroupName bam-t$testno -TemplateParameterFile .\test${testno}.params.json -TemplateUri "https://raw.githubusercontent.com/bartekmo/ng-azure/ngf2/marketplace-barracuda-ngf/MainTemplate.json"

  if ( $deployment.Outputs -ne $null ) {
    Write-Host "[+] " -ForegroundColor "green" -nonewline
    Write-Host "provisioned successfully. So far so good..."
  } else {
    Write-Host "[-] FAILED deployment!" -ForegroundColor "red"
    exit
  }

} else {
  $curr=get-AzureRmResourceGroupDeployment -name test$testno -resourcegroupname bam-t$testno
  if ( $curr.ProvisioningState -eq "Succeeded" ) {
    Write-Host -ForegroundColor "green" -nonewline "[+] "
    Write-Host "Provisioning already done :)"
  } else {
    Write-Host -ForegroundColor "red" -nonewline "[-] "
    Write-Host "Provisioning state", $curr.ProvisioningState
    exit
  }
}

$cmd = [ScriptBlock]::Create( $mytest.expectCmd )

for ( $i=0 ; $i -lt 10 ; $i++ ) {
  #$rest=Invoke-RestMethod -Uri $resturi -ContentType 'application/json' -Headers $apitoken
  $res = Invoke-Command -ScriptBlock $cmd
  if ( $res -eq $mytest.expectTest ) {
    Write-Host ''
    Write-Host -ForegroundColor "green" -nonewline "[+] "
    Write-Host $mytest.expect
    Write-Host -ForegroundColor "green" -nonewline "[+] "
    Write-Host "SUCCESS. Cleaning up" -ForegroundColor "green"
    Remove-AzureRmResourceGroup -name bam-t$testno -force
    Write-Host '""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""' -ForegroundColor "green"
    Write-Host
    exit
  } else {
    Start-Sleep -s 20
    Write-Host -nonewline '.'
  }
}
Write-Host -ForegroundColor 'red' "[-] " -nonewline
Write-Host 'test failed'

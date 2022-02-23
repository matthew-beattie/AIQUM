Param(
   [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
   [ValidateNotNullOrEmpty()]
   [String]$Server,
   [Parameter(Mandatory = $True, HelpMessage = "The Object Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
   [String]$ObjectID,
   [Parameter(Mandatory = $True, HelpMessage = "The Object Type to enumerate metrics for")]
   [ValidateSet("aggregate", "cluster", "ethernet_port", "fc_interface", "fc_port", "ip_interface", "lun", "node", "volume", "svm")]
   [String]$ObjectType,
   [Parameter(Mandatory = $True, HelpMessage = "The time range for the data")]
   [ValidateSet("1h", "12h", "1d", "2d", "3d", "15d", "1w", "1m", "2m", "3m", "6m")]
   [String]$Interval,
   [Parameter(Mandatory = $True, HelpMessage = "The Credential to authenticate to AIQUM")]
   [ValidateNotNullOrEmpty()]
   [System.Management.Automation.PSCredential]$Credential
)
#'------------------------------------------------------------------------------
#'Import the AIQUM Module.
#'------------------------------------------------------------------------------
Import-Module .\AIQUM.psm1
Write-Host "Imported Module .\AIQUM.psm1"
#'------------------------------------------------------------------------------
#'Set the certificate policy and TLS version.
#'------------------------------------------------------------------------------
Add-Type @"
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
[System.Net.ServicePointManager]::SecurityProtocol  = [System.Net.SecurityProtocolType]'Tls12'
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
#'------------------------------------------------------------------------------
#'Set the command to enumerate the Object Metrics.
#'------------------------------------------------------------------------------
[String]$command = "Get-UMObjectMetrics -Server $Server -ObjectID '$ObjectID' -ObjectType $ObjectType -Interval $Interval -Credential `$Credential -ErrorAction Stop"
#'------------------------------------------------------------------------------
#'Enumerate the Object Metrics.
#'------------------------------------------------------------------------------
Try{
   $objectMetrics = Invoke-Expression -Command $command -ErrorAction Stop
   Write-Host "Executed Command`: $command" -ForegroundColor Cyan
}Catch{
   Write-Warning -Message $("Failed Executing Command`: $command. Error " + $_.Exception.Message)
}
$objectMetrics.samples
#'------------------------------------------------------------------------------

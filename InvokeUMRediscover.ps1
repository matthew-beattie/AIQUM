Param(
   [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
   [ValidateNotNullOrEmpty()]
   [String]$Server,
   [Parameter(Mandatory = $False, HelpMessage = "The Cluster Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
   [String]$ClusterId,
   [Parameter(Mandatory = $False, HelpMessage = "The Cluster Name")]
   [String]$ClusterName,
   [Parameter(Mandatory = $False, HelpMessage = "The maximum timeout in seconds to wait for the job to complete. Default is 300 seconds")]
   [Int]$Timeout = 30,
   [Parameter(Mandatory = $False, HelpMessage = "The maximum number of seconds to wait inbetween checking the job status. Default is 3 seconds")]
   [ValidateRange(1, 60)]
   [Int]$WaitInterval = 3,
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
[String]$command = "Invoke-UMRediscover -Server $Server "
If($ClusterId){
   [String]$command += "-ClusterId '$ClusterId' "
}
If($ClusterName){
   [String]$command += "-ClusterName $ClusterName "
}
[String]$command += "-Credential `$Credential -ErrorAction Stop"
#'------------------------------------------------------------------------------
#'Rediscover the cluster and display the job ID.
#'------------------------------------------------------------------------------
Try{
   $rediscover = Invoke-Expression -Command $command -ErrorAction Stop
   Write-Host "Executed Command`: $command" -ForegroundColor Cyan
}Catch{
   Write-Warning -Message $("Failed Executing Command`: $command. Error " + $_.Exception.Message)
}
#'------------------------------------------------------------------------------
#'Rediscover the cluster and display the job ID.
#'------------------------------------------------------------------------------
If($Null -ne $rediscover){
   [String]$jobId = $rediscover.operationId
   [String]$command = "Wait-UMRediscover -Server $Server -JobID $jobId "
   If($Timeout){
      [String]$command += "-Timeout $Timeout "
   }
   If($WaitInterval){
      [String]$command += "-WaitInterval $WaitInterval "
   }
   [String]$command += "-Credential `$Credential -ErrorAction Stop"
   Try{
      [Bool]$waited = Invoke-Expression -Command $command -ErrorAction Stop
   }Catch{
      Write-Warning -Message $("Failed Executing Command`: $command. Error " + $_.Exception.Message)
   }
}Else{
   [Bool]$waited = $False;
}
#'------------------------------------------------------------------------------
#'Display the rediscovery status for the cluster.
#'------------------------------------------------------------------------------
If($rediscover -And $waited){
   If($ClusterName){
      Write-Host "Successfully completed rediscovery for Cluster ""$ClusterName"" on Server ""$Server"""
   }Else{
      Write-Host "Successfully completed rediscovery for Cluster ID ""$ClusterID"" on Server ""$Server"""
   }
}Else{
   If($ClusterName){
      Write-Warning -Message "Failed rediscovery for Cluster ""$ClusterName"" on Server ""$Server"""
   }Else{
      Write-Warning -Message "Failed rediscovery for Cluster ID ""$ClusterID"" on Server ""$Server"""
   }
}
#'------------------------------------------------------------------------------

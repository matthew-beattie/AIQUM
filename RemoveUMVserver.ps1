Param(
   [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
   [ValidateNotNullOrEmpty()]
   [String]$Server,
   [Parameter(Mandatory = $False, HelpMessage = "The Cluster Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
   [String]$ClusterId,
   [Parameter(Mandatory = $False, HelpMessage = "The Cluster Name")]
   [String]$ClusterName,
   [Parameter(Mandatory = $False, HelpMessage = "The Vserver Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
   [String]$VserverId,
   [Parameter(Mandatory = $False, HelpMessage = "The Vserver Name")]
   [String]$VserverName,
   [Parameter(Mandatory = $False, HelpMessage = "If Set to true, SVM objects will be deleted and data volumes will be offline and deleted")]
   [Bool]$Force,
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
If($ClusterName -And $ClusterID){
   Write-Warning -Message "Please enter either the ""ClusterName"" or ""ClusterID"" paramater"
   Break;
}
If($VserverName -And $VserverID){
   Write-Warning -Message "Please enter either the ""VserverName"" or ""VserverID"" paramater"
   Break;
}
[String]$command = "Remove-UMVserver -Server $Server "
If($ClusterId -And (-Not($ClusterName))){
   [String]$command += "-ClusterId '$ClusterId' "
}
If($ClusterName -And (-Not($ClusterId))){
   [String]$command += "-ClusterName $ClusterName "
}
If($VserverId -And (-Not($VserverName))){
   [String]$command += "-VserverId '$VserverId' "
}
If($VserverName -And (-Not($VserverID))){
   [String]$command += "-VserverName $VserverName "
}
If($Force){
   [String]$command += $("-Force `$" + $Force.ToString() + "")
}
[String]$command += "-Credential `$Credential -ErrorAction Stop"
#'------------------------------------------------------------------------------
#'Delete the vserver.
#'------------------------------------------------------------------------------
Try{
   $response = Invoke-Expression -Command $command -ErrorAction Stop
   Write-Host "Executed Command`: $command" -ForegroundColor Cyan
}Catch{
   Write-Warning -Message $("Failed Executing Command`: $command. Error " + $_.Exception.Message)
}
#'------------------------------------------------------------------------------

Param(
   [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
   [ValidateNotNullOrEmpty()]
   [String]$Server,
   [Parameter(Mandatory = $False, HelpMessage = "The IGroup Name")]
   [String]$IGroupName,
   [Parameter(Mandatory = $False, HelpMessage = "The IGroup Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
   [String]$IGroupID,
   [Parameter(Mandatory = $False, HelpMessage = "The Cluster Name")]
   [String]$ClusterName,
   [Parameter(Mandatory = $False, HelpMessage = "The Vserver Name")]
   [String]$VserverName,
   [Parameter(Mandatory = $True, HelpMessage = "The IGroup Name")]
   [Array]$Initiators,
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
#'Set the command to remove the initiators from the IGroup.
#'------------------------------------------------------------------------------
[String]$command = "Remove-UMIGroupInitiators -Server $Server "
If($IGroupID){
   [String]$command += "-IGroupID '$IGroupID' -Initiators `$Initiators -Credential `$Credential -ErrorAction Stop"
}Else{
   [String]$command += "-IGroupName $IGroupName -ClusterName $ClusterName -VserverName $VserverName -Initiators `$Initiators -Credential `$Credential -ErrorAction Stop"
}
#'------------------------------------------------------------------------------
#'Remove the initiators from the IGroup.
#'------------------------------------------------------------------------------
Try{
   $i = Invoke-Expression -Command $command -ErrorAction Stop
   Write-Host "Executed Command`: $command" -ForegroundColor Cyan
   $i.records
}Catch{
   Write-Warning -Message $("Failed Executing Command`: $command. Error " + $_.Exception.Message)
   $i
}
#'------------------------------------------------------------------------------

Param(
   [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
   [ValidateNotNullOrEmpty()]
   [String]$Server,
   [Parameter(Mandatory = $True, HelpMessage = "The LUN resource key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
   [String]$LunName,
   [Parameter(Mandatory = $True, HelpMessage = "The IGroup Operating System Type. Valid values are 'aix', 'hpux', 'hyper_v', 'linux', 'netware', 'openvms', 'solaris', 'vmware', 'windows' and 'xen'")]
   [ValidateSet("aix","hpux","hyper_v","linux","netware","openvms","solaris","vmware","windows","xen")]
   [String]$OsType,
   [Parameter(Mandatory = $True, HelpMessage = "The LUN Size in GigaBytes")]
   [Int]$SizeGB,
   [Parameter(Mandatory = $False, HelpMessage = "The LUN Logical Unit Number")]
   [ValidateRange(0, 4095)]
   [Int]$ID,
   [Parameter(Mandatory = $False, HelpMessage = "The IGroup resource key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
   [String]$IGroupID,
   [Parameter(Mandatory = $False, HelpMessage = "The IGroup Name")]
   [String]$IGroupName,
   [Parameter(Mandatory = $False, HelpMessage = "The Performance Service Level resource key. The syntax is: '<uuid>'")]
   [String]$ServiceLevelID,
   [Parameter(Mandatory = $False, HelpMessage = "The Performance Service Level resource key. The syntax is: '<uuid>'")]
   [String]$ServiceLevelName,
   [Parameter(Mandatory = $False, HelpMessage = "The Storage Efficiency Policy resource key. The syntax is: '=<uuid>'")]
   [String]$EfficiencyPolicyID,
   [Parameter(Mandatory = $False, HelpMessage = "The Storage Efficiency Policy Name")]
   [String]$EfficiencyPolicyName,
   [Parameter(Mandatory = $False, HelpMessage = "The Volume resource key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
   [String]$VolumeID,
   [Parameter(Mandatory = $False, HelpMessage = "The Volume Name")]
   [String]$VolumeName,
   [Parameter(Mandatory = $False, HelpMessage = "The Vserver resource key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
   [String]$VserverID,
   [Parameter(Mandatory = $False, HelpMessage = "The Vserver Name")]
   [String]$VserverName,
   [Parameter(Mandatory = $False, HelpMessage = "The Cluster Name")]
   [String]$ClusterName,
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
#'Set the command to create the LUN.
#'------------------------------------------------------------------------------
[String]$command = "New-UMLun -Server $Server "
If($LunName){
   [String]$command += "-LunName '$LunName' "
}
If($OsType){
   [String]$command += "-OsType '$OsType' "
}
If($SizeGB){
   [String]$command += "-SizeGB $SizeGB "
}
If($ID){
   [String]$command += "-ID $ID "
}
If($IGroupID){
   [String]$command += "-IGroupID '$IGroupID' "
}
If($IGroupName){
   [String]$command += "-IGroupName '$IGroupName' "
}
If($ServiceLevelID){
   [String]$command += "-ServiceLevelID '$ServiceLevelID' "
}
If($ServiceLevelName){
   [String]$command += "-ServiceLevelName '$ServiceLevelName' "
}
If($EfficiencyPolicyID){
   [String]$command += "-EfficiencyPolicyID '$EfficiencyPolicyID' "
}
If($EfficiencyPolicyName){
   [String]$command += "-EfficiencyPolicyName '$EfficiencyPolicyName' "
}
If($VolumeName){
   [String]$command += "-VolumeName '$VolumeName' "
}
If($VserverID){
   [String]$command += "-VserverID '$VserverID' "
}
If($VserverName){
   [String]$command += "-VserverName '$VserverName' "
}
If($ClusterName){
   [String]$command += "-ClusterName '$ClusterName' "
}
[String]$command += "-Credential `$Credential -ErrorAction Stop"
#'------------------------------------------------------------------------------
#'Create the LUN.
#'------------------------------------------------------------------------------
Try{
   $lun = Invoke-Expression -Command $command -ErrorAction Stop
   Write-Host "Executed Command`: $command" -ForegroundColor Cyan
}Catch{
   Write-Warning -Message $("Failed Executing Command`: $command. Error " + $_.Exception.Message)
}
$lun.records
#'------------------------------------------------------------------------------

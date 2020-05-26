Param(
   [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
   [ValidateNotNullOrEmpty()]
   [String]$Server,
   [Parameter(Mandatory = $False, HelpMessage = "The Cluster Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
   [String]$ClusterID,
   [Parameter(Mandatory = $False, HelpMessage = "The Cluster SNMP location")]
   [String]$Location,
   [Parameter(Mandatory = $False, HelpMessage = "The Cluster name")]
   [String]$Name,
   [Parameter(Mandatory = $False, HelpMessage = "The Cluster UUID")]
   [String]$Uuid,
   [Parameter(Mandatory = $False, HelpMessage = "The Cluster SNMP contact")]
   [String]$Contact,
   [Parameter(Mandatory = $False, HelpMessage = "The Cluster management FQDN or IP Address")]
   [String]$IPAddress,
   [Parameter(Mandatory = $False, HelpMessage = "The ONTAP Major version number")]
   [Int]$Major,
   [Parameter(Mandatory = $False, HelpMessage = "The ONTAP Minor version number")]
   [Int]$Minor,
   [Parameter(Mandatory = $False, HelpMessage = "The ONTAP Micro version number")]
   [Int]$Micro,
   [Parameter(Mandatory = $False, HelpMessage = "The ONTAP version number. Syntax is '<major>.<minor>.<micro>'. Example '9.6.0'")]
   [String]$Version,
   [Parameter(Mandatory = $False, HelpMessage = "The Start index for the records to be returned")]
   [Int]$Offset,
   [Parameter(Mandatory = $False, HelpMessage = "The Maximum number of records to be returned")]
   [Int]$MaxRecords,
   [Parameter(Mandatory = $False, HelpMessage = "The Sort Order. Default is 'asc'")]
   [ValidateSet("asc","desc")]
   [String]$OrderBy,
   [Parameter(Mandatory = $True, HelpMessage = "The Credential to authenticate to AIQUM")]
   [ValidateNotNullOrEmpty()]
   [System.Management.Automation.PSCredential]$Credential
)
#'------------------------------------------------------------------------------
#'Import the AIQUM PowerShell Module.
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
[String]$command = "Get-UMCluster -Server $Server "
If($ClusterID){
   [String]$command += "-ClusterID '$ClusterID' "
}
If($Location){
   [String]$command += "-Location $Location "
}
If($Name){
   [String]$command += "-Name $Name "
}
If($Uuid){
   [String]$command += "-Uuid $Uuid "
}
If($Contact){
   [String]$command += "-Contact $Contact "
}
If($IPAddress){
   [String]$command += "-IPAddress $IPAddress "
}
If($Major){
   [String]$command += "-Major $Major "
}
If($Minor){
   [String]$command += "-Minor $Minor "
}
If($Micro){
   [String]$command += "-Micro $Micro "
}
If($Version){
   [String]$command += "-Version $Version "
}
If($Offset){
   [String]$command += "-Offset $Offset "
}
If($MaxRecords){
   [String]$command += "-MaxRecords $MaxRecords "
}
If($OrderBy){
   [String]$command += "-OrderBy $OrderBy "
}
[String]$command += "-Credential `$Credential -ErrorAction Stop"
#'------------------------------------------------------------------------------
#'Query the clusters.
#'------------------------------------------------------------------------------
Try{
   $clusters = Invoke-Expression -Command $command -ErrorAction Stop
   Write-Host "Executed Command`: $command" -ForegroundColor Cyan
   $clusters.records
}Catch{
   Write-Warning -Message $("Failed Executing Command`: $command. Error " + $_.Exception.Message)
   $clusters
}
#'------------------------------------------------------------------------------

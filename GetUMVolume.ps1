Param(
   [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
   [ValidateNotNullOrEmpty()]
   [String]$Server,
   [Parameter(Mandatory = $False, HelpMessage = "The Volume Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
   [String]$VolumeID,
   [Parameter(Mandatory = $False, HelpMessage = "The Volume Type")]
   [ValidateSet("rw","dp")]
   [String]$VolumeType,
   [Parameter(Mandatory = $False, HelpMessage = "The Volume Name")]
   [String]$VolumeName,
   [Parameter(Mandatory = $False, HelpMessage = "The Volume Space Avaialble")]
   [Int]$SpaceAvailableGB,
   [Parameter(Mandatory = $False, HelpMessage = "The Volume Space Used")]
   [Int]$SpaceUsedGB,
   [Parameter(Mandatory = $False, HelpMessage = "The Volume Autosize mode")]
   [ValidateSet("off","grow","grow_shrink")]
   [String]$AutosizeMode,
   [Parameter(Mandatory = $False, HelpMessage = "The Volume Autosize Maximum in GigaBytes")]
   [Int]$AutosizeMaximumGB,
   [Parameter(Mandatory = $False, HelpMessage = "The Volume creation Date")]
   [DateTime]$DateCreated,
   [Parameter(Mandatory = $False, HelpMessage = "The Volume State")]
   [ValidateSet("online","offline")]
   [String]$State,
   [Parameter(Mandatory = $False, HelpMessage = "The Volume Security Style")]
   [ValidateSet("flexvol","flexgroup")]
   [String]$Style,
   [Parameter(Mandatory = $False, HelpMessage = "The Volume UUID")]
   [String]$VolumeUuid,
   [Parameter(Mandatory = $False, HelpMessage = "The Cluster Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
   [String]$ClusterID,
   [Parameter(Mandatory = $False, HelpMessage = "The Cluster name")]
   [String]$ClusterName,
   [Parameter(Mandatory = $False, HelpMessage = "The Cluster UUID")]
   [String]$ClusterUuid,
   [Parameter(Mandatory = $False, HelpMessage = "The Vserver Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
   [String]$VserverID,
   [Parameter(Mandatory = $False, HelpMessage = "The Vserver name")]
   [String]$VserverName,
   [Parameter(Mandatory = $False, HelpMessage = "The Vserver UUID")]
   [String]$VserverUuid,
   [Parameter(Mandatory = $False, HelpMessage = "The Aggregate Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
   [String]$AggregateID,
   [Parameter(Mandatory = $False, HelpMessage = "The Aggregate name")]
   [String]$AggregateName,
   [Parameter(Mandatory = $False, HelpMessage = "The Aggregate UUID")]
   [String]$AggregateUuid,
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
[String]$command = "Get-UMVolume -Server $Server "

If($VolumeID){
   [String]$command += "-VolumeID '$VolumeID' "
}
If($VolumeType){
   [String]$command += "-VolumeType '$VolumeType' "
}
If($VolumeName){
   [String]$command += "-VolumeName '$VolumeName' "
}
If($SpaceAvailableGB){
   [String]$command += "-SpaceAvailableGB $SpaceAvailableGB "
}
If($SpaceUsedGB){
   [String]$command += "-SpaceUsedGB $SpaceUsedGB "
}
If($AutosizeMode){
   [String]$command += "-AutosizeMode '$AutosizeMode' "
}
If($AutosizeMode){
   [String]$command += "-AutosizeMaximumGB $AutosizeMaximumGB "
}
If($DateCreated){
   [String]$command += "-DateCreated `$DateCreated "
}
If($State){
   [String]$command += "-State '$State' "
}
If($Style){
   [String]$command += "-Style '$Style' "
}
If($VolumeUuid){
   [String]$command += "-VolumeUuid '$VolumeUuid' "
}
If($ClusterID){
   [String]$command += "-ClusterID '$ClusterID' "
}
If($ClusterName){
   [String]$command += "-ClusterName '$ClusterName' "
}
If($ClusterUuid){
   [String]$command += "-ClusterUuid '$ClusterUuid' "
}
If($VserverID){
   [String]$command += "-VserverID '$VserverID' "
}
If($VserverName){
   [String]$command += "-VserverName '$VserverName' "
}
If($VserverUuid){
   [String]$command += "-VserverUuid '$VserverUuid' "
}
If($AggregateID){
   [String]$command += "-AggregateID '$AggregateID' "
}
If($AggregateName){
   [String]$command += "-AggregateName '$AggregateName' "
}
If($AggregateUuid){
   [String]$command += "-AggregateUuid '$AggregateUuid' "
}
If($Offset){
   [String]$command += "-Offset $Offset "
}
If($MaxRecords){
   [String]$command += "-MaxRecords $MaxRecords "
}
If($OrderBy){
   [String]$command += "-OrderBy '$OrderBy' "
}
[String]$command += "-Credential `$Credential -ErrorAction Stop"
#'------------------------------------------------------------------------------
#'Enumerate the volumes.
#'------------------------------------------------------------------------------
Try{
   $volumes = Invoke-Expression -Command $command -ErrorAction Stop
   Write-Host "Executed Command`: $command" -ForegroundColor Cyan
}Catch{
   Write-Warning -Message $("Failed Executing Command`: $command. Error " + $_.Exception.Message)
}
$volumes.records
#'------------------------------------------------------------------------------

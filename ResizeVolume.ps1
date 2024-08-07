Param(
   [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
   [String]$Server,
   [Parameter(Mandatory = $True, HelpMessage = "The Volume Name")]
   [String]$VolumeName,
   [Parameter(Mandatory = $True, HelpMessage = "The Vserver Name")]
   [String]$VserverName,
   [Parameter(Mandatory = $True, HelpMessage = "The Volume Size in GigaBytes")]
   [Int]$SizeGB,
   [Parameter(Mandatory = $True, HelpMessage = "The Credential to authenticate to AIQUM")]
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
If(-Not("TrustAllCertsPolicy" -As [Type])){
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
}
[System.Net.ServicePointManager]::SecurityProtocol  = [System.Net.SecurityProtocolType]'Tls12'
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
#'------------------------------------------------------------------------------
#'Enumerate the Volume.
#'------------------------------------------------------------------------------
Try{
   $volume = Get-UMVolume -Server $Server -VolumeName $VolumeName -VserverName $VserverName -Credential $credential -ErrorAction Stop
}Catch{
   Write-Warning -Message $("Failed Enumerating Volume ""$VolumeName"" on vserver ""$VserverName"" on Server ""$Server"". Error " + $_.Exception.Message)
   Exit -1
}
#'------------------------------------------------------------------------------
#'Enumerate the Volume UUID.
#'------------------------------------------------------------------------------
If($Null -ne $volume){
   [String]$volumeID     = $volumes.records.uuid
   [String]$dataSourceID = $volumes.records.cluster.uuid
   Write-Host $volumes.records
   Write-Host "Volume ID`: $volumeID"
   Write-Host "DataSource ID`: $dataSourceID"
}Else{
   Write-Warning -Message "The Volume ""$VolumeName"" on vserver ""$VserverName"" was not found on Server ""$Server"""
   Exit -1
}
#'------------------------------------------------------------------------------
#'Set the Volume Size via the Gateway API.
#'------------------------------------------------------------------------------
$body = @{};
$body.Add("size", "$($SizeGB * 1073741824)")
$item = $body | ConvertTo-Json
Write-Host "JSON Payload`: $item"
Try{
   $result = Set-UMGatewayItem -Server $Server -DatasourceID $dataSourceID -ApiPath "storage/volumes/$volumeID" -Item $item -Credential $credential -ErrorAction Stop
   Write-Host "Resized Volume ""$VolumeName"" to $SizeGB GigaBytes on vserver ""$VserverName"" on Server ""$Server"""
}Catch{
   Write-Warning -Message $("Failed Resizing Volume ""$VolumeName"" on vserver ""$VserverName"" on Server ""$Server"". Error " + $_.Exception.Message)
   Exit -1
}
Write-Host $result | Format-List
#'------------------------------------------------------------------------------

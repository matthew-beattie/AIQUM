<#'-----------------------------------------------------------------------------
'Script Name : AIQUM.psm1  
'Author      : Matthew Beattie
'Email       : mbeattie@netapp.com
'Created     : 2020-05-26
'Description : This code provides Functions for invoking NetApp AIQUM REST API's.
'Link        : https://www.netapp.com/us/documentation/active-iq-unified-manager.aspx
'Disclaimer  : THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR
'            : IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
'            : WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
'            : PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR 
'            : ANYDIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
'            : DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
'            : GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
'            : INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
'            : WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
'            : NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
'            : THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
'-----------------------------------------------------------------------------#>
#'Active IQ Unified Manager REST API Functions.
#'------------------------------------------------------------------------------
Function Get-UMAuthorization{
   [Alias("Get-UMAuth")]
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The Credential to authenticate to AIQUM")]
      [ValidateNotNullOrEmpty()]
      [System.Management.Automation.PSCredential]$Credential
   )
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{
      "Authorization" = "Basic $auth"
      "Accept"        = "application/json"
      "Content-Type"  = "application/json"
   }
   Return $headers;
}#'End Function Get-UMAuthorization
#'------------------------------------------------------------------------------
Function Get-UMCluster{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $False, HelpMessage = "The Cluster Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$ClusterID,
      [Parameter(Mandatory = $False, HelpMessage = "The Cluster SNMP location")]
      [String]$Location,
      [Parameter(Mandatory = $False, HelpMessage = "The Cluster name")]
      [String]$ClusterName,
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
      [Parameter(Mandatory = $False, HelpMessage = "The ONTAP full version name")]
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
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{"Authorization" = "Basic $auth"}
   #'---------------------------------------------------------------------------
   #'Set the URI to enumerate the clusters.
   #'---------------------------------------------------------------------------
   [String]$uri = "https://$Server/api/datacenter/cluster/clusters?"
   [Bool]$query = $False;
   If($ClusterID){
      [String]$uri += "&key=$ClusterID"
      [Bool]$query = $True
   }
   If($Location){
      [String]$uri += "&location=$Location"
      [Bool]$query = $True
   }
   If($ClusterName){
      [String]$uri += "&name=$ClusterName"
      [Bool]$query = $True
   }
   If($Uuid){
      [String]$uri += "&uuid=$Uuid"
      [Bool]$query = $True
   }
   If($Contact){
      [String]$uri += "&contact=$Contact"
      [Bool]$query = $True
   }
   If($IPAddress){
      [String]$uri += "&management_ip=$IPAddress"
      [Bool]$query = $True
   }
   If($Major){
      [String]$uri += "&version.minor=$Major"
      [Bool]$query = $True
   }
   If($Minor){
      [String]$uri += "&version.major=$Minor"
      [Bool]$query = $True
   }
   If($Micro){
      [String]$uri += "&version.generation=$Micro"
      [Bool]$query = $True
   }
   If($Version){
      [String]$uri += "&version.full=$Version"
      [Bool]$query = $True
   }
   If($Offset){
      [String]$uri += "&offset=$Offset"
   }
   If($OrderBy){
      [String]$uri += "&order_by=$OrderBy"
   }
   If($MaxRecords){
      [String]$uri += "&max_records=$MaxRecords"
   }
   If(-Not($query)){
      [String]$uri = $uri.SubString(0, ($uri.Length -1))
   }Else{
      [String]$uri = $uri.Replace("?&", "?")
   }
   #'---------------------------------------------------------------------------
   #'Enumerate the clusters.
   #'---------------------------------------------------------------------------
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers -ErrorAction Stop
      Write-Host "Enumerated Clusters on Server ""$Server"" using URI ""$uri"""
   }Catch{
      Write-Warning -Message $("Failed enumerating Clusters on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
   }
   Return $response;
}#'End Function Get-UMCluster.
#'------------------------------------------------------------------------------
Function Get-UMClusterID{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $False, HelpMessage = "The Cluster Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$ResourceKey,
      [Parameter(Mandatory = $True, HelpMessage = "The Credential to authenticate to AIQUM")]
      [ValidateNotNullOrEmpty()]
      [System.Management.Automation.PSCredential]$Credential
   )
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{"Authorization" = "Basic $auth"}
   #'---------------------------------------------------------------------------
   #'Enumerate the cluster.
   #'---------------------------------------------------------------------------
   [String]$uri = "https://$Server/api/datacenter/cluster/clusters/$ClusterID"
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers -ErrorAction Stop
      Write-Host "Enumerated Cluster ID ""$ClusterID"" on Server ""$Server"" using URI ""$uri"""
   }Catch{
      Write-Warning -Message $("Failed enumerating Cluster ID ""$ClusterID"" on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
   }
   Return $response;
}#'End Function Get-UMClusterID.
#'------------------------------------------------------------------------------
Function Get-UMNode{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $False, HelpMessage = "The Node Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$NodeID,
      [Parameter(Mandatory = $False, HelpMessage = "The Node SNMP location")]
      [String]$Location,
      [Parameter(Mandatory = $False, HelpMessage = "The Node name")]
      [String]$NodeName,
      [Parameter(Mandatory = $False, HelpMessage = "The Node Serial Number")]
      [String]$SerialNumber,
      [Parameter(Mandatory = $False, HelpMessage = "The ONTAP Major version number")]
      [Int]$Major,
      [Parameter(Mandatory = $False, HelpMessage = "The ONTAP Minor version number")]
      [Int]$Minor,
      [Parameter(Mandatory = $False, HelpMessage = "The ONTAP Micro version number")]
      [Int]$Micro,
      [Parameter(Mandatory = $False, HelpMessage = "The ONTAP version number. Syntax is '<major>.<minor>.<micro>'. Example '9.6.0'")]
      [String]$Version,
      [Parameter(Mandatory = $False, HelpMessage = "The Node UUID")]
      [String]$Uuid,
      [Parameter(Mandatory = $False, HelpMessage = "The Node Model Number")]
      [String]$Model,
      [Parameter(Mandatory = $False, HelpMessage = "The Node Uptime")]
      [Int64]$Uptime,
      [Parameter(Mandatory = $False, HelpMessage = "The Node Cluster Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$ClusterID,
      [Parameter(Mandatory = $False, HelpMessage = "The Node Cluster name")]
      [String]$ClusterName,
      [Parameter(Mandatory = $False, HelpMessage = "The Node Cluster UUID")]
      [String]$ClusterUuid,
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
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{"Authorization" = "Basic $auth"}
   #'---------------------------------------------------------------------------
   #'Set the URI to enumerate the nodes.
   #'---------------------------------------------------------------------------
   [String]$uri = "https://$Server/api/datacenter/cluster/nodes?"
   [Bool]$query = $False;
   If($NodeID){
      [String]$uri += "&key=$NodeID"
      [Bool]$query = $True
   }
   If($Location){
      [String]$uri += "&location=$Location"
      [Bool]$query = $True
   }
   If($NodeName){
      [String]$uri += "&name=$NodeName"
      [Bool]$query = $True
   }
   If($Major){
      [String]$uri += "&version.minor=$Major"
      [Bool]$query = $True
   }
   If($Minor){
      [String]$uri += "&version.major=$Minor"
      [Bool]$query = $True
   }
   If($Micro){
      [String]$uri += "&version.generation=$Micro"
      [Bool]$query = $True
   }
   If($Version){
      [String]$uri += "&version.full=$Version"
      [Bool]$query = $True
   }
   If($SerialNumber){
      [String]$uri += "&serial_number=$SerialNumber"
      [Bool]$query = $True
   }
   If($Uuid){
      [String]$uri += "&uuid=$Uuid"
      [Bool]$query = $True
   }
   If($Model){
      [String]$uri += "&model=$Model"
      [Bool]$query = $True
   }
   If($Uptime){
      [String]$uri += "&uptime=$Uptime"
      [Bool]$query = $True
   }
   If($ClusterID){
      [String]$uri += "&cluster.key=$ClusterID"
      [Bool]$query = $True
   }
   If($ClusterName){
      [String]$uri += "&cluster.name=$ClusterName"
      [Bool]$query = $True
   }
   If($ClusterUuid){
      [String]$uri += "&cluster.uuid=$ClusterUuid"
      [Bool]$query = $True
   }
   If($Offset){
      [String]$uri += "&offset=$Offset"
   }
   If($OrderBy){
      [String]$uri += "&order_by=$OrderBy"
   }
   If($MaxRecords){
      [String]$uri += "&max_records=$MaxRecords"
   }
   If(-Not($query)){
      [String]$uri = $uri.SubString(0, ($uri.Length -1))
   }Else{
      [String]$uri = $uri.Replace("?&", "?")
   }
   #'---------------------------------------------------------------------------
   #'Enumerate the nodes.
   #'---------------------------------------------------------------------------
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers -ErrorAction Stop
      Write-Host "Enumerated Nodes on Server ""$Server"" using URI ""$uri"""
   }Catch{
      Write-Warning -Message $("Failed enumerating Nodes on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
   }
   Return $response;
}#'End Function Get-UMNode.
#'------------------------------------------------------------------------------
Function Get-UMNodeID{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $False, HelpMessage = "The Node Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$NodeID,
      [Parameter(Mandatory = $True, HelpMessage = "The Credential to authenticate to AIQUM")]
      [ValidateNotNullOrEmpty()]
      [System.Management.Automation.PSCredential]$Credential
   )
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{"Authorization" = "Basic $auth"}
   #'---------------------------------------------------------------------------
   #'Enumerate the Node.
   #'---------------------------------------------------------------------------
   [String]$uri = "https://$Server/api/datacenter/cluster/nodes/$NodeID"
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers -ErrorAction Stop
      Write-Host "Enumerated Node ID ""$NodeID"" on Server ""$Server"" using URI ""$uri"""
   }Catch{
      Write-Warning -Message $("Failed enumerating Node ID ""$NodeID"" on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
   }
   Return $response;
}#'End Function Get-UMNodeID.
#'------------------------------------------------------------------------------
Function Get-UMCifsShare{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $False, HelpMessage = "The CIFS Share Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$ShareID,
      [Parameter(Mandatory = $False, HelpMessage = "The CIFS Share Comment")]
      [String]$Comment,
      [Parameter(Mandatory = $False, HelpMessage = "The CIFS Share Path")]
      [String]$JunctionPath,
      [Parameter(Mandatory = $False, HelpMessage = "The CIFS Share Name")]
      [String]$ShareName,
      [Parameter(Mandatory = $False, HelpMessage = "The Cluster Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$ClusterID,
      [Parameter(Mandatory = $False, HelpMessage = "The Cluster name")]
      [String]$ClusterName,
      [Parameter(Mandatory = $False, HelpMessage = "The Cluster UUID")]
      [String]$ClusterUuid,
      [Parameter(Mandatory = $False, HelpMessage = "The Vserver Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$VserverID,
      [Parameter(Mandatory = $False, HelpMessage = "The Vserver Name")]
      [String]$VserverName,
      [Parameter(Mandatory = $False, HelpMessage = "The Vserver UUID")]
      [String]$VserverUuID,
      [Parameter(Mandatory = $False, HelpMessage = "The Volume Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$VolumeID,
      [Parameter(Mandatory = $False, HelpMessage = "The Volume Name")]
      [String]$VolumeName,
      [Parameter(Mandatory = $False, HelpMessage = "The Volume UUID")]
      [String]$VolumeUuID,
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
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{"Authorization" = "Basic $auth"}
   #'---------------------------------------------------------------------------
   #'Set the URI to enumerate the CIFS Share.
   #'---------------------------------------------------------------------------
   [String]$uri = "https://$Server/api/datacenter/protocols/cifs/shares?"
   [Bool]$query = $False;
   If($ShareID){
      [String]$uri += "&key=$ShareID"
      [Bool]$query = $True
   }
   If($Comment){
      [String]$uri += "&comment=$Comment"
      [Bool]$query = $True
   }
   If($JunctionPath){
      [String]$uri += "&path=$JunctionPath"
      [Bool]$query = $True
   }
   If($ShareName){
      [String]$uri += "&name=$ShareName"
      [Bool]$query = $True
   }
   If($ClusterID){
      [String]$uri += "&cluster.key=$ClusterID"
      [Bool]$query = $True
   }
   If($ClusterName){
      [String]$uri += "&cluster.name=$ClusterName"
      [Bool]$query = $True
   }
   If($ClusterUuid){
      [String]$uri += "&cluster.uuid=$ClusterUuid"
      [Bool]$query = $True
   }
   If($VserverID){
      [String]$uri += "&svm.key=$VserverID"
      [Bool]$query = $True
   }
   If($VserverName){
      [String]$uri += "&svm.name=$VserverName"
      [Bool]$query = $True
   }
   If($VserverUuid){
      [String]$uri += "&svm.uuid=$VserverUuid"
      [Bool]$query = $True
   }
   If($VolumeID){
      [String]$uri += "&volume.key=$VolumeID"
      [Bool]$query = $True
   }
   If($VolumeName){
      [String]$uri += "&volume.name=$VolumeName"
      [Bool]$query = $True
   }
   If($VolumeUuid){
      [String]$uri += "&volume.uuid=$VolumeUuid"
      [Bool]$query = $True
   }
   If($Offset){
      [String]$uri += "&offset=$Offset"
   }
   If($OrderBy){
      [String]$uri += "&order_by=$OrderBy"
   }
   If($MaxRecords){
      [String]$uri += "&max_records=$MaxRecords"
   }
   If(-Not($query)){
      [String]$uri = $uri.SubString(0, ($uri.Length -1))
   }Else{
      [String]$uri = $uri.Replace("?&", "?")
   }
   #'---------------------------------------------------------------------------
   #'Enumerate the CIFS Shares.
   #'---------------------------------------------------------------------------
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers -ErrorAction Stop
      Write-Host "Enumerated CIFS Shares on Server ""$Server"" using URI ""$uri"""
   }Catch{
      Write-Warning -Message $("Failed enumerating CIFS Shares on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
   }
   Return $response;
}#'End Function Get-UMCifsShare.
#'------------------------------------------------------------------------------
Function Get-UMCifsShareID{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $True, HelpMessage = "The CIFS Share Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$ShareID,
      [Parameter(Mandatory = $True, HelpMessage = "The Credential to authenticate to AIQUM")]
      [ValidateNotNullOrEmpty()]
      [System.Management.Automation.PSCredential]$Credential
   )
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{"Authorization" = "Basic $auth"}
   #'---------------------------------------------------------------------------
   #'Enumerate the CIFS Share.
   #'---------------------------------------------------------------------------
   [String]$uri = "https://$Server/api/datacenter/protocols/cifs/shares/$ShareID"
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers -ErrorAction Stop
      Write-Host "Enumerated CIFS Share ID ""$ShareID"" on Server ""$Server"" using URI ""$uri"""
   }Catch{
      Write-Warning -Message $("Failed enumerating CIFS Share ID ""$ShareID"" on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
   }
   Return $response;
}#'End Function Get-UMCifsShareID.
#'------------------------------------------------------------------------------
Function Get-UMExportPolicy{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $False, HelpMessage = "The Export Policy Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$ExportPolicyID,
      [Parameter(Mandatory = $False, HelpMessage = "The Export Policy Name")]
      [String]$PolicyName,
      [Parameter(Mandatory = $False, HelpMessage = "The Export Policy ID")]
      [Long]$PolicyID,
      [Parameter(Mandatory = $False, HelpMessage = "The Cluster Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$ClusterID,
      [Parameter(Mandatory = $False, HelpMessage = "The Cluster name")]
      [String]$ClusterName,
      [Parameter(Mandatory = $False, HelpMessage = "The Cluster UUID")]
      [String]$ClusterUuid,
      [Parameter(Mandatory = $False, HelpMessage = "The Vserver Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$VserverID,
      [Parameter(Mandatory = $False, HelpMessage = "The Vserver Name")]
      [String]$VserverName,
      [Parameter(Mandatory = $False, HelpMessage = "The Vserver UUID")]
      [String]$VserverUuID,
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
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{"Authorization" = "Basic $auth"}
   #'---------------------------------------------------------------------------
   #'Set the URI to enumerate the Export Policy.
   #'---------------------------------------------------------------------------
   [String]$uri = "https://$Server/api/datacenter/protocols/nfs/export-policies?"
   [Bool]$query = $False;
   If($ExportPolicyID){
      [String]$uri += "&key=$ExportPolicyID"
      [Bool]$query = $True
   }
   If($PolicyName){
      [String]$uri += "&name=$PolicyName"
      [Bool]$query = $True
   }
   If($PolicyId){
      [String]$uri += "&id=$PolicyId"
      [Bool]$query = $True
   }
   If($ClusterID){
      [String]$uri += "&cluster.key=$ClusterID"
      [Bool]$query = $True
   }
   If($ClusterName){
      [String]$uri += "&cluster.name=$ClusterName"
      [Bool]$query = $True
   }
   If($ClusterUuid){
      [String]$uri += "&cluster.uuid=$ClusterUuid"
      [Bool]$query = $True
   }
   If($VserverID){
      [String]$uri += "&svm.key=$VserverID"
      [Bool]$query = $True
   }
   If($VserverName){
      [String]$uri += "&svm.name=$VserverName"
      [Bool]$query = $True
   }
   If($VserverUuid){
      [String]$uri += "&svm.uuid=$VserverUuid"
      [Bool]$query = $True
   }
   If($Offset){
      [String]$uri += "&offset=$Offset"
   }
   If($OrderBy){
      [String]$uri += "&order_by=$OrderBy"
   }
   If($MaxRecords){
      [String]$uri += "&max_records=$MaxRecords"
   }
   If(-Not($query)){
      [String]$uri = $uri.SubString(0, ($uri.Length -1))
   }Else{
      [String]$uri = $uri.Replace("?&", "?")
   }
   #'---------------------------------------------------------------------------
   #'Enumerate the Export Policies.
   #'---------------------------------------------------------------------------
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers -ErrorAction Stop
      Write-Host "Enumerated Export Policies on Server ""$Server"" using URI ""$uri"""
   }Catch{
      Write-Warning -Message $("Failed enumerating Export Policies on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
   }
   Return $response;
}#'End Function Get-UMExportPolicy.
#'------------------------------------------------------------------------------
Function Get-UMExportPolicyID{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $False, HelpMessage = "The Export Policy Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$ExportPolicyID,
      [Parameter(Mandatory = $True, HelpMessage = "The Credential to authenticate to AIQUM")]
      [ValidateNotNullOrEmpty()]
      [System.Management.Automation.PSCredential]$Credential
   )
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{"Authorization" = "Basic $auth"}
   #'---------------------------------------------------------------------------
   #'Enumerate the Export Policy.
   #'---------------------------------------------------------------------------
   [String]$uri = "https://$Server/api/datacenter/protocols/nfs/export-policies/$ExportPolicyID"
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers -ErrorAction Stop
      Write-Host "Enumerated Export Policy ID ""$ExportPolicyID"" on Server ""$Server"" using URI ""$uri"""
   }Catch{
      Write-Warning -Message $("Failed enumerating Export Policy ID ""$ExportPolicyID"" on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
   }
   Return $response;
}#'End Function Get-UMExportPolicyID.
#'------------------------------------------------------------------------------
Function Get-UMIgroup{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $False, HelpMessage = "The IGroup Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$IGroupID,
      [Parameter(Mandatory = $False, HelpMessage = "The IGroup Name")]
      [String]$IGroupName,
      [Parameter(Mandatory = $False, HelpMessage = "The IGroup Operating System Type. Valid values are 'aix', 'hpux', 'hyper_v', 'linux', 'netware', 'openvms', 'solaris', 'vmware', 'windows' and 'xen'")]
      [ValidateSet("aix","hpux","hyper_v","linux","netware","openvms","solaris","vmware","windows","xen")]
      [String]$OsType,
      [Parameter(Mandatory = $False, HelpMessage = "The IGroup Protocol. Valid values are 'fcp', 'iscsi' and 'mixed'")]
      [ValidateSet("fcp","iscsi","mixed")]
      [String]$Protocol,
      [Parameter(Mandatory = $False, HelpMessage = "The IGroup UUID")]
      [String]$Uuid,
      [Parameter(Mandatory = $False, HelpMessage = "The Vserver Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$VserverID,
      [Parameter(Mandatory = $False, HelpMessage = "The Vserver Name")]
      [String]$VserverName,
      [Parameter(Mandatory = $False, HelpMessage = "The Vserver UUID")]
      [String]$VserverUuID,
      [Parameter(Mandatory = $False, HelpMessage = "The Cluster Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$ClusterID,
      [Parameter(Mandatory = $False, HelpMessage = "The Cluster name")]
      [String]$ClusterName,
      [Parameter(Mandatory = $False, HelpMessage = "The Cluster UUID")]
      [String]$ClusterUuid,
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
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{"Authorization" = "Basic $auth"}
   #'---------------------------------------------------------------------------
   #'Set the URI to enumerate the Igroups.
   #'---------------------------------------------------------------------------
   [String]$uri = "https://$Server/api/datacenter/protocols/san/igroups?"
   [Bool]$query = $False;
   If($IGroupID){
      [String]$uri += "&key=$IGroupID"
      [Bool]$query = $True
   }
   If($IGroupName){
      [String]$uri += "&name=$IGroupName"
      [Bool]$query = $True
   }
   If($OsType){
      [String]$uri += "&os_type=$OsType"
      [Bool]$query = $True
   }
   If($Protocol){
      [String]$uri += "&protocol=$Protocol"
      [Bool]$query = $True
   }
   If($Uuid){
      [String]$uri += "&uuid=$Uuid"
      [Bool]$query = $True
   }
   If($VserverID){
      [String]$uri += "&svm.key=$VserverID"
      [Bool]$query = $True
   }
   If($VserverName){
      [String]$uri += "&svm.name=$VserverName"
      [Bool]$query = $True
   }
   If($VserverUuid){
      [String]$uri += "&svm.uuid=$VserverUuid"
      [Bool]$query = $True
   }
   If($ClusterID){
      [String]$uri += "&cluster.key=$ClusterID"
      [Bool]$query = $True
   }
   If($ClusterName){
      [String]$uri += "&cluster.name=$ClusterName"
      [Bool]$query = $True
   }
   If($ClusterUuid){
      [String]$uri += "&cluster.uuid=$ClusterUuid"
      [Bool]$query = $True
   }
   If($Offset){
      [String]$uri += "&offset=$Offset"
   }
   If($OrderBy){
      [String]$uri += "&order_by=$OrderBy"
   }
   If($MaxRecords){
      [String]$uri += "&max_records=$MaxRecords"
   }
   If(-Not($query)){
      [String]$uri = $uri.SubString(0, ($uri.Length -1))
   }Else{
      [String]$uri = $uri.Replace("?&", "?")
   }
   #'---------------------------------------------------------------------------
   #'Enumerate the Igroups.
   #'---------------------------------------------------------------------------
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers -ErrorAction Stop
      Write-Host "Enumerated IGroups on Server ""$Server"" using URI ""$uri"""
   }Catch{
      Write-Warning -Message $("Failed enumerating IGroups on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
   }
   Return $response;
}#'End Function Get-UMIgroup.
#'------------------------------------------------------------------------------
Function Get-UMIgroupID{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $False, HelpMessage = "The IGroup Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$IGroupID,
      [Parameter(Mandatory = $True, HelpMessage = "The Credential to authenticate to AIQUM")]
      [ValidateNotNullOrEmpty()]
      [System.Management.Automation.PSCredential]$Credential
   )
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{"Authorization" = "Basic $auth"}
   #'---------------------------------------------------------------------------
   #'Enumerate the Igroup.
   #'---------------------------------------------------------------------------
   [String]$uri = "https://$Server/api/datacenter/protocols/san/igroups/$IGroupID"
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers -ErrorAction Stop
      Write-Host "Enumerated IGroup ID ""$IGroupID"" on Server ""$Server"" using URI ""$uri"""
   }Catch{
      Write-Warning -Message $("Failed enumerating IGroup ID ""$IGroupID"" on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
   }
   Return $response;
}#'End Function Get-UMIgroupID.
#'------------------------------------------------------------------------------
Function New-UMIgroup{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $True, HelpMessage = "The IGroup Name")]
      [String]$IgroupName,
      [Parameter(Mandatory = $False, HelpMessage = "The Vserver Name")]
      [String]$VserverName,
      [Parameter(Mandatory = $False, HelpMessage = "The Vserver Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$VserverID,
      [Parameter(Mandatory = $False, HelpMessage = "The Cluster Name")]
      [String]$ClusterName,
      [Parameter(Mandatory = $True, HelpMessage = "The IGroup Operating System Type. Valid values are 'aix', 'hpux', 'hyper_v', 'linux', 'netware', 'openvms', 'solaris', 'vmware', 'windows' and 'xen'")]
      [ValidateSet("aix","hpux","hyper_v","linux","netware","openvms","solaris","vmware","windows","xen")]
      [String]$OsType,
      [Parameter(Mandatory = $True, HelpMessage = "The IGroup Protocol. Valid values are 'fcp', 'iscsi' and 'mixed'")]
      [ValidateSet("fcp","iscsi","mixed")]
      [String]$Protocol,
      [Parameter(Mandatory = $False, HelpMessage = "The IGroup Initiators")]
      [Array]$Initiators,
      [Parameter(Mandatory = $True, HelpMessage = "The Credential to authenticate to AIQUM")]
      [ValidateNotNullOrEmpty()]
      [System.Management.Automation.PSCredential]$Credential
   )
   #'---------------------------------------------------------------------------
   #'Validate the input parameters.
   #'---------------------------------------------------------------------------
   If(-Not($VserverID)){
      If((-Not($VserverName)) -And (-Not($ClusterName))){
         Write-Warning -Message "The 'VserverName' and 'ClusterName' parameters must be provided if the 'VserverID' is not specified"
         Return $Null;
      }
   }
   #'---------------------------------------------------------------------------
   #'Enumerate the vserver resource key if not provided.
   #'---------------------------------------------------------------------------
   If(-Not($VserverID)){
      [String]$command = "Get-UMObjectID -Server $Server -ObjectType 'vserver' -ObjectName $VserverName -ClusterName $ClusterName -Credential `$Credential -ErrorAction Stop"
      Try{
         [String]$VserverID = Invoke-Expression -Command $command -ErrorAction Stop
         Write-Host "Executed Command`: $command" -ForegroundColor Cyan
      }Catch{
         Write-Warning -Message $("Failed Executing Command`: $command. Error " + $_.Exception.Message)
         Return $vserver;
      }
      If([String]::IsNullOrEmpty($VserverID)){
         Write-Warning -Message "Failed enumerating ID for Vserver ""$VserverName"" on Cluster ""$ClusterName"""
         Return $Null;
      }
   }
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{
      "Authorization" = "Basic $auth"
      "Accept"        = "application/json"
      "Content-Type"  = "application/json"
   }
   #'---------------------------------------------------------------------------
   #'Create a hashtable for the igroup body and convert it to JSON.
   #'---------------------------------------------------------------------------
   [String]$uri       = "https://$Server/api/datacenter/protocols/san/igroups"
   [HashTable]$igroup = @{};
   [Array]$iqns       = @();
   If($Initiators){
      ForEach($Initiator In $Initiators){
         [HashTable]$iqn = @{"name" = $Initiator};
         [Array]$iqns    += $iqn
      }
      [HashTable]$igroup.Add("initiators", $iqns)
   }
   [HashTable]$vserver = @{"key" = $VserverID}
   [HashTable]$igroup.Add("name",     $IgroupName)
   [HashTable]$igroup.Add("os_type",  $OsType)
   [HashTable]$igroup.Add("protocol", $Protocol)
   [HashTable]$igroup.Add("svm",      $vserver)
   $body = $igroup | ConvertTo-Json
   #'---------------------------------------------------------------------------
   #'Create the IGroup.
   #'---------------------------------------------------------------------------
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method POST -Body $body -Headers $headers -ErrorAction Stop
      If($Initiators){
         Write-Host $("Created IGroup ""$IGroupName"" of OS type ""$OsType"" Protocol ""$Protocol"" with initiators """ + $([String]::Join(",", $Initiators)) + """ on Vserver ID ""$VserverID"" Server ""$Server"" using URI ""$uri""")
      }Else{
         Write-Host $("Created IGroup ""$IGroupName"" of OS type ""$OsType"" Protocol ""$Protocol"" on Vserver ID ""$VserverID"" Server ""$Server"" using URI ""$uri""")
      }
   }Catch{
      If($Initiators){
         Write-Warning -Message $("Failed creating IGroup ""$IGroupName"" of OS type ""$OsType"" Protocol ""$Protocol"" with initiators """ + $([String]::Join(",", $Initiators)) + """ on Vserver ID ""$VserverID""  using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
      }Else{
         Write-Warning -Message $("Failed creating IGroup ""$IGroupName"" of OS type ""$OsType"" Protocol ""$Protocol"" on Vserver ID ""$VserverID""  using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
      }
   }
   Return $response;
}#'End Function New-UMIgroup.
#'------------------------------------------------------------------------------
Function Set-UMIgroup{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $False, HelpMessage = "The IGroup Name")]
      [String]$IGroupName,
      [Parameter(Mandatory = $False, HelpMessage = "The IGroup Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$IgroupID,
      [Parameter(Mandatory = $False, HelpMessage = "The IGroup Operating System Type. Valid values are 'aix', 'hpux', 'hyper_v', 'linux', 'netware', 'openvms', 'solaris', 'vmware', 'windows' and 'xen'")]
      [ValidateSet("aix","hpux","hyper_v","linux","netware","openvms","solaris","vmware","windows","xen")]
      [String]$OsType,
      [Parameter(Mandatory = $False, HelpMessage = "The IGroup Initiators")]
      [Array]$Initiators,
      [Parameter(Mandatory = $False, HelpMessage = "The Vserver Name")]
      [String]$VserverName,
      [Parameter(Mandatory = $False, HelpMessage = "The Cluster name")]
      [String]$ClusterName,
      [Parameter(Mandatory = $True, HelpMessage = "The Credential to authenticate to AIQUM")]
      [ValidateNotNullOrEmpty()]
      [System.Management.Automation.PSCredential]$Credential
   )
   #'---------------------------------------------------------------------------
   #'Validate the input parameters.
   #'---------------------------------------------------------------------------
   If(-Not($PSBoundParameters.ContainsKey("IGroupID"))){
      If(-Not(($PSBoundParameters.ContainsKey("IGroupName")) -And ($PSBoundParameters.ContainsKey("VserverName")) -And ($PSBoundParameters.ContainsKey("ClusterName")))){
         Write-Warning -Message "The 'IGroupName', 'VserverName' and 'ClusterName' parameters must be provided if the 'IGroupID' is not specified"
         Return $Null;
      }
   }
   #'---------------------------------------------------------------------------
   #'Enumerate the igroup if the resource key was not provided.
   #'---------------------------------------------------------------------------
   If(-Not($IGroupID)){
      [String]$command = "Get-UMObjectID -Server $Server -ObjectType 'igroup' -ObjectName $IGroupName -VserverName $VserverName -ClusterName $ClusterName -Credential `$Credential -ErrorAction Stop"
      Try{
         [String]$IgroupID = Invoke-Expression -Command $command -ErrorAction Stop
         Write-Host "Executed Command`: $command" -ForegroundColor Cyan
      }Catch{
         Write-Warning -Message $("Failed Executing Command`: $command. Error " + $_.Exception.Message)
         Return $Null;
      }
      If([String]::IsNullOrEmpty($IGroupID)){
         Write-Warning -Message "Failed enumerating ID for IGroup ""$IGroupName"" on Vserver ""$VserverName"" on Cluster ""$ClusterName"""
         Return $Null;
      }
   }
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{
      "Authorization" = "Basic $auth"
      "Accept"        = "application/json"
      "Content-Type"  = "application/json"
   }
   #'---------------------------------------------------------------------------
   #'Set the igroup URI. Create a hashtable for the body and covert to JSON.
   #'---------------------------------------------------------------------------
   [String]$uri       = "https://$Server/api/datacenter/protocols/san/igroups/$IgroupID"
   [HashTable]$igroup = @{};
   [Array]$iqns       = @();
   If($Initiators){
      ForEach($Initiator In $Initiators){
         [HashTable]$iqn = @{"name" = $Initiator};
         [Array]$iqns    += $iqn
      }
      [HashTable]$igroup.Add("initiators", $iqns)
   }
   [HashTable]$igroup.Add("name",     $IGroupName)
   [HashTable]$igroup.Add("os_type",  $OsType)
   $body = $igroup | ConvertTo-Json
   #'---------------------------------------------------------------------------
   #'Set the IGroup.
   #'---------------------------------------------------------------------------
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method PATCH -Body $body -Headers $headers -ErrorAction Stop
      If($Initiators){
         Write-Host $("Set IGroup ID ""$IGroupID"" of OS type ""$OsType"" with initiators """ + $([String]::Join(",", $Initiators)) + """ for IGroup ID ""$IGroupID"" on Server ""$Server"" using URI ""$uri""")
      }Else{
         Write-Host $("Set IGroup ""$IGroupID"" of OS type ""$OsType"" on Server ""$Server"" using URI ""$uri""")
      }
   }Catch{
      If($Initiators){
         Write-Warning -Message $("Failed setting IGroup ID ""$IGroupID"" of OS type ""$OsType"" with initiators """ + $([String]::Join(",", $Initiators)) + """ on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
      }Else{
         Write-Warning -Message $("Failed setting IGroup ID ""$IGroupID"" of OS type ""$OsType"" on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
      }
   }
   Return $response;
}#'End Function Set-UMIgroup.
#'------------------------------------------------------------------------------
Function Remove-UMIgroup{
   [CmdletBinding()]
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
      [Parameter(Mandatory = $True, HelpMessage = "The Credential to authenticate to AIQUM")]
      [ValidateNotNullOrEmpty()]
      [System.Management.Automation.PSCredential]$Credential
   )
   #'---------------------------------------------------------------------------
   #'Validate the input paramaters.
   #'---------------------------------------------------------------------------
   [Bool]$id = $False
   If(-Not($IGroupID)){
      If((-Not($IGroupName)) -And (-Not($ClusterName)) -And (-Not($VserverName))){
         Write-Warning -Message "The 'IGroupName', 'ClusterName' and 'VserverName' must be provided if the 'IGroupID' is not specified"
         Return $Null;
      }
   }Else{
      [Bool]$id = $True
   }
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{
      "Authorization" = "Basic $auth"
      "Accept"        = "application/json"
      "Content-Type"  = "application/json"
   }
   #'---------------------------------------------------------------------------
   #'Enumerate the IGroup by Name if the resource key is not provided.
   #'---------------------------------------------------------------------------
   If(-Not($id)){
      Try{
         $i = Get-UMIgroup -Server $Server -ClusterName $ClusterName -VserverName $VserverName -Name $IGroupName -Credential $Credential -ErrorAction Stop
      }Catch{
         Write-Warning "Failed enumerating IGroup ""$IGroupName"" on vserver ""$VserverName"" on cluster ""$ClusterName"""
      }
      If($Null -eq $i){
         Write-Warning -Message "The IGroup ""$IGroupName"" was not found on vserver ""$VserverName"" on cluster ""$ClusterName"""
         Return $Null;
      }
      [String]$IGroupID = $i.records.key
   }
   #'---------------------------------------------------------------------------
   #'Remove the IGroup.
   #'---------------------------------------------------------------------------
   [String]$uri = "https://$Server/api/datacenter/protocols/san/igroups/$IGroupID"
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method DELETE -Headers $headers -ErrorAction Stop
      If($id){
         Write-Host "Removed IGroup ID ""$IGroupID"" from Server ""$Server"" using URI ""$uri"""
      }Else{
         Write-Host "Removed IGroup ""$IGroupName"" ID ""$IGroupID"" from Vserver ""$VserverName"" Cluster ""$Cluster"" on server ""$Server"" using URI ""$uri"""
      }
   }Catch{
      If($id){
         Write-Warning -Message $("Failed removing IGroupID ""$IGroupID"" from Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
      }Else{
         Write-Warning -Message $("Failed removing IGroup ""$IGroupName"" ID ""$IGroupID"" from Vserver ""$VserverName"" Cluster ""$Cluster"" on server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
      }
   }
   Return $response;
}#'End Function Remove-UMIgroup.
#'------------------------------------------------------------------------------
Function Add-UMIGroupInitiators{
   [CmdletBinding()]
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
   #'---------------------------------------------------------------------------
   #'Validate the input paramaters.
   #'---------------------------------------------------------------------------
   If(-Not($IGroupID)){
      If((-Not($IGroupName)) -And (-Not($ClusterName)) -And (-Not($VserverName))){
         Write-Warning -Message "The 'IGroupName', 'ClusterName' and 'VserverName' must be provided if the 'IGroupID' is not specified"
         Return $Null;
      }
   }
   #'---------------------------------------------------------------------------
   #'Enumerate the IGroup by Name if the resource key is not provided.
   #'---------------------------------------------------------------------------
   [String]$id = $Null
   If(-Not($IgroupID)){
      [String]$command = "Get-UMObjectID -Server $Server -ObjectType 'igroup' -ObjectName $IGroupName -ClusterName $ClusterName -VserverName $VserverName -Credential `$Credential -ErrorAction Stop"
      Try{
         [String]$IGroupID = Invoke-Expression -Command $command -ErrorAction Stop
         Write-Host "Executed Command`: $command"
      }Catch{
         Write-Warning -Message $("Failed Executing Command`: $command. Error " + $_.Exception.Message)
         Return $Null;
      }
      If([String]::IsNullOrEmpty($IGroupID)){
         Write-Warning -Message "Failed enumerating ID for IGroup ""$IGroupName"" on Vserver ""$VserverName"" on Cluster ""$ClusterName"""
         Return $Null;
      }
   }
   #'---------------------------------------------------------------------------
   #'Enumerate the IGroup by ID to ensure the initiators list is the most current.
   #'---------------------------------------------------------------------------
   [String]$command = "Get-UMIgroupID -Server $Server -IGroupID '$IGroupID' -Credential `$Credential -ErrorAction Stop"
   Try{
      $ig = Invoke-Expression -Command $command -ErrorAction Stop
      Write-Host "Executed Command`: $command" -ForegroundColor Cyan
   }Catch{
      Write-Warning -Message $("Failed Executing Command`: $command. Error " + $_.Exception.Message)
      Return $Null;
   }
   #'---------------------------------------------------------------------------
   #'Add the IGroup Initiators to a Hashtable for comparision.
   #'---------------------------------------------------------------------------
   [HashTable]$iqns = @{};
   ForEach($iqn In $ig.initiators){
      If(-Not($iqns.ContainsKey($iqn.name))){
         [HashTable]$iqns.Add($iqn.name, "")
      }
   }
   #'---------------------------------------------------------------------------
   #'Compare the Array of Initiators to the Hashtable of existing IQN's.
   #'---------------------------------------------------------------------------
   [Bool]$update       = $False;
   [HashTable]$updates = @{};
   ForEach($iqn In $Initiators){
      If(-Not($iqns.ContainsKey($iqn))){
         [HashTable]$iqns.Add($iqn, $Null)
         [HashTable]$updates.Add($iqn, $Null)
         [Bool]$update = $True;
      }
   }
   #'---------------------------------------------------------------------------
   #'Add the Initiators to the IGroup if they are not already added.
   #'---------------------------------------------------------------------------
   If($update){
      [Array]$initiatorList = $iqns.GetEnumerator() | Sort-Object -Property Name | Select-Object -ExpandProperty Name
      [Array]$updateList    = $updates.GetEnumerator() | Sort-Object -Property Name | Select-Object -ExpandProperty Name
      [String]$command      = $("Set-UMIGroup -Server $Server -IGroupName " + $ig.name + " -IGroupID '" + $ig.key + "' -OsType " + $ig.os_type + " -Initiators `$initiatorList -Credential `$Credential -ErrorAction Stop")
      Try{
         $igroup = Invoke-Expression -Command $command -ErrorAction Stop
         Write-Host "Executed Command`: $command" -ForegroundColor Cyan
      }Catch{
         Write-Warning -Message $("Failed Executing Command`: $command. Error " + $_.Exception.Message)
         Return $igroup;
      }
      Write-Host $("Added Initiators """ + $([String]::Join(",", $updateList)) + """ to IGroup ""$IGroupName"" ID ""$IgroupID"" on Vserver ""$VserverName"" on Cluster ""$ClusterName""")
   }Else{
      Write-Host $("The Initiators """ + $([String]::Join(",", $Initiators)) + """ are already added to Igroup ""$IGroupName"" ID ""$IGroupID"" on Vserver ""$VserverName"" on Cluster ""$ClusterName""")
   }
   Return $Null;
}#'End Function Add-UMIGroupInitiators.
#'------------------------------------------------------------------------------
Function Remove-UMIGroupInitiators{
   [CmdletBinding()]
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
   #'---------------------------------------------------------------------------
   #'Validate the input paramaters.
   #'---------------------------------------------------------------------------
   If(-Not($IGroupID)){
      If((-Not($IGroupName)) -And (-Not($ClusterName)) -And (-Not($VserverName))){
         Write-Warning -Message "The 'IGroupName', 'ClusterName' and 'VserverName' must be provided if the 'IGroupID' is not specified"
         Return $Null;
      }
   }
   #'---------------------------------------------------------------------------
   #'Enumerate the IGroup by Name if the resource key is not provided.
   #'---------------------------------------------------------------------------
   If(-Not($IgroupID)){
      [String]$command = "Get-UMObjectID -Server $Server -ObjectType 'igroup' -ObjectName $IGroupName -ClusterName $ClusterName -VserverName $VserverName -Credential `$Credential -ErrorAction Stop"
      Try{
         [String]$IGroupID = Invoke-Expression -Command $command -ErrorAction Stop
         Write-Host "Executed Command`: $command"
      }Catch{
         Write-Warning -Message $("Failed Executing Command`: $command. Error " + $_.Exception.Message)
         Return $Null;
      }
      If([String]::IsNullOrEmpty($IGroupID)){
         Write-Warning -Message "Failed enumerating ID for IGroup ""$IGroupName"" on Vserver ""$VserverName"" on cluster ""$ClusterName"""
         Return $Null;
      }
   }
   #'---------------------------------------------------------------------------
   #'Enumerate the IGroup by ID to ensure the initiators list is the most current.
   #'---------------------------------------------------------------------------
   [String]$command = "Get-UMIgroupID -Server $Server -IGroupID '$IGroupID' -Credential `$Credential -ErrorAction Stop"
   Try{
      $ig = Invoke-Expression -Command $command -ErrorAction Stop
      Write-Host "Executed Command`: $command" -ForegroundColor Cyan
   }Catch{
      Write-Warning $("Failed Executing Command`: $command. Error " + $_.Exception.Message)
      Return $Null;
   }
   #'---------------------------------------------------------------------------
   #'Add the IGroup Initiators to a Hashtable for comparision.
   #'---------------------------------------------------------------------------
   [HashTable]$iqns = @{};
   ForEach($iqn In $ig.initiators){
      If(-Not($iqns.ContainsKey($iqn.name))){
         [HashTable]$iqns.Add($iqn.name, "")
      }
   }
   #'---------------------------------------------------------------------------
   #'Compare the Array of Initiators to the Hashtable of existing IQN's.
   #'---------------------------------------------------------------------------
   [Bool]$update       = $False;
   [HashTable]$removed = @{};
   ForEach($iqn In $Initiators){
      If($iqns.ContainsKey($iqn)){
         [HashTable]$iqns.Remove($iqn)
         [HashTable]$removed.Add($iqn, $Null)
         [Bool]$update = $True;
      }
   }
   #'---------------------------------------------------------------------------
   #'Remove the Initiators from the IGroup if they exist.
   #'---------------------------------------------------------------------------
   If($update){
      [Array]$initiatorList = $iqns.GetEnumerator() | Sort-Object -Property Name | Select-Object -ExpandProperty Name
      [Array]$removedList   = $removed.GetEnumerator() | Sort-Object -Property Name | Select-Object -ExpandProperty Name
      [String]$command      = $("Set-UMIGroup -Server $Server -IGroupName " + $ig.name + " -IGroupID '" + $ig.key + "' -OsType " + $ig.os_type + " -Initiators `$initiatorList -Credential `$Credential -ErrorAction Stop")
      Try{
         $igroup = Invoke-Expression -Command $command -ErrorAction Stop
         Write-Host "Executed Command`: $command" -ForegroundColor Cyan
      }Catch{
         Write-Warning -Message $("Failed Executing Command`: $command. Error " + $_.Exception.Message)
         Return $igroup;
      }
      Write-Host $("Removed Initiators """ + $([String]::Join(",", $removedList)) + """ from IGroup ""$IGroupName"" ID ""$IGroupID"" on Vserver ""$VserverName"" on Cluster ""$ClusterName""")
   }Else{
      Write-Host $("The Initiators """ + $([String]::Join(",", $Initiators)) + """ do not exist in Igroup ""$IGroupName"" ID ""$IGroupID"" on Vserver ""$VserverName"" on Cluster ""$ClusterName""")
   }
   Return $Null;
}#'End Function Remove-UMIGroupInitiators.
#'------------------------------------------------------------------------------
Function Get-UMVserver{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $False, HelpMessage = "The resource key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$VserverID,
      [Parameter(Mandatory = $False, HelpMessage = "The Cluster Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$ClusterID,
      [Parameter(Mandatory = $False, HelpMessage = "The Cluster name")]
      [String]$ClusterName,
      [Parameter(Mandatory = $False, HelpMessage = "The Cluster UUID")]
      [String]$ClusterUuid,
      [Parameter(Mandatory = $False, HelpMessage = "The NIS enabled status")]
      [ValidateSet("true", "false")]
      [String]$NisEnabled,
      [Parameter(Mandatory = $False, HelpMessage = "The NVME enabled status")]
      [ValidateSet("true", "false")]
      [String]$NvmeEnabled,
      [Parameter(Mandatory = $False, HelpMessage = "The vserver language")]
      [ValidateSet("ar","ar.utf-8","c","c.utf-8","cs","cs.utf-8","da","da.utf-8","de","de.utf-8","en","en.utf-8","en_us","en_us.utf-8","es","es.utf-8","fi","fi.utf-8","fr","fr.utf-8","he","he.utf-8","hr","hr.utf-8","hu","hu.utf-8","it","it.utf-8","ja","ja.utf-8","ja_jp.932","ja_jp.932.utf-8","ja_jp.pck","ja_jp.pck.utf-8","ja_jp.pck_v2","ja_jp.pck_v2.utf-8","ja_v1","ja_v1.utf-8","ko","ko.utf-8","nl","nl.utf-8","no","no.utf-8","pl","pl.utf-8","pt","pt.utf-8","ro","ro.utf-8","ru","ru.utf-8","sk","sk.utf-8","sl","sl.utf-8","sv","sv.utf-8","tr","tr.utf-8","utf8mb4","zh","zh.gbk","zh.gbk.utf-8","zh.utf-8","zh_tw","zh_tw.big5","zh_tw.big5.utf-8","zh_tw.utf-8")]
      [String]$Language,
      [Parameter(Mandatory = $False, HelpMessage = "The NFS enabled status")]
      [ValidateSet("true", "false")]
      [String]$NfsEnabled,
      [Parameter(Mandatory = $False, HelpMessage = "The vserver subtype")]
      [ValidateSet("default","dp-destination")]
      [String]$SubType,
      [Parameter(Mandatory = $False, HelpMessage = "The FCP enabled status")]
      [ValidateSet("true", "false")]
      [String]$FcpEnabled,
      [Parameter(Mandatory = $False, HelpMessage = "The ISCSI enabled status")]
      [ValidateSet("true", "false")]
      [String]$IscsiEnabled,
      [Parameter(Mandatory = $False, HelpMessage = "The vserver name")]
      [String]$VserverName,
      [Parameter(Mandatory = $False, HelpMessage = "The LDAP enabled status")]
      [ValidateSet("true", "false")]
      [String]$LdapEnabled,
      [Parameter(Mandatory = $False, HelpMessage = "The vserver UUID")]
      [String]$Uuid,
      [Parameter(Mandatory = $False, HelpMessage = "The CIFS Server name")]
      [String]$CifsServer,
      [Parameter(Mandatory = $False, HelpMessage = "The CIFS enabled status")]
      [ValidateSet("true", "false")]
      [String]$CifsEnabled,
      [Parameter(Mandatory = $False, HelpMessage = "The CIFS enabled status")]
      [ValidateSet("deleting","initializing","starting","stopped","stopping","running")]
      [String]$State,
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
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{"Authorization" = "Basic $auth"}
   #'---------------------------------------------------------------------------
   #'Set the URI to enumerate the vservers.
   #'---------------------------------------------------------------------------
   [String]$uri = "https://$Server/api/datacenter/svm/svms?"
   [Bool]$query = $False;
   If($VserverID){
      [String]$uri += "&key=$VserverID"
      [Bool]$query = $True
   }
   If($ClusterID){
      [String]$uri += "&cluster.key=$ClusterID"
      [Bool]$query = $True
   }
   If($ClusterName){
      [String]$uri += "&cluster.name=$ClusterName"
      [Bool]$query = $True
   }
   If($ClusterUuid){
      [String]$uri += "&cluster.uuid=$ClusterUuid"
      [Bool]$query = $True
   }
   If($NisEnabled){
      [String]$uri += "&nis.enabled=$NisEnabled"
      [Bool]$query = $True
   }
   If($NvmeEnabled){
      [String]$uri += "&nvme.enabled=$NvmeEnabled"
      [Bool]$query = $True
   }
   If($Language){
      [String]$uri += $("&language=" + $Language.Replace("-", "_"))
      [Bool]$query = $True
   }
   If($NfsEnabled){
      [String]$uri += "&nfs.enabled=$NfsEnabled"
      [Bool]$query = $True
   }
   If($SubType){
      [String]$uri += $("&subtype=" + $SubType.Replace("-", "_"))
      [Bool]$query = $True
   }
   If($FcpEnabled){
      [String]$uri += "&fcp.enabled=$FcpEnabled"
      [Bool]$query = $True
   }
   If($IscsiEnabled){
      [String]$uri += "&iscsi.enabled=$IscsiEnabled"
      [Bool]$query = $True
   }
   If($VserverName){
      [String]$uri += "&name=$VserverName"
      [Bool]$query = $True
   }
   If($LdapEnabled){
      [String]$uri += "&ldap.enabled=$LdapEnabled"
      [Bool]$query = $True
   }
   If($Uuid){
      [String]$uri += "&uuid=$Uuid"
      [Bool]$query = $True
   }
   If($CifsServer){
      [String]$uri += "&cifs.name=$CifsServer"
      [Bool]$query = $True
   }
   If($CifsEnabled){
      [String]$uri += "&cifs.enabled=$CifsEnabled"
      [Bool]$query = $True
   }
   If($Offset){
      [String]$uri += "&offset=$Offset"
      [Bool]$query = $True
   }
   If($OrderBy){
      [String]$uri += "&order_by=$OrderBy"
      [Bool]$query = $True
   }
   If($MaxRecords){
      [String]$uri += "&max_records=$MaxRecords"
      [Bool]$query = $True
   }
   If(-Not($query)){
      [String]$uri = $uri.SubString(0, ($uri.Length -1))
   }Else{
      [String]$uri = $uri.Replace("?&", "?")
   }
   #'---------------------------------------------------------------------------
   #'Enumerate the vservers.
   #'---------------------------------------------------------------------------
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers -ErrorAction Stop
      Write-Host "Enumerated Vservers on Server ""$Server"" using URI ""$uri"""
   }Catch{
      Write-Warning -Message $("Failed enumerating Vservers on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
   }
   Return $response;
}#'End Function Get-UMVserver.
#'------------------------------------------------------------------------------
Function Get-UMVserverID{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $True, HelpMessage = "The resource key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$VserverID,
      [Parameter(Mandatory = $True, HelpMessage = "The Credential to authenticate to AIQUM")]
      [ValidateNotNullOrEmpty()]
      [System.Management.Automation.PSCredential]$Credential
   )
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{"Authorization" = "Basic $auth"}
   #'---------------------------------------------------------------------------
   #'Enumerate the vserver.
   #'---------------------------------------------------------------------------
   [String]$uri = "https://$Server/api/datacenter/svm/svms/$VserverID"
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers -ErrorAction Stop
      Write-Host "Enumerated Vserver on Server ""$Server"" using URI ""$uri"""
   }Catch{
      Write-Warning -Message $("Failed enumerating Vserver on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
   }
   Return $response;
}#'End Function Get-UMVserverID.
#'------------------------------------------------------------------------------
Function Remove-UMVserver{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $False, HelpMessage = "The Vserver UUID")]
      [String]$VserverID,
      [Parameter(Mandatory = $False, HelpMessage = "The Cluster Name")]
      [String]$ClusterName,
      [Parameter(Mandatory = $False, HelpMessage = "The Vserver Name")]
      [String]$VserverName,
      [Parameter(Mandatory = $False, HelpMessage = "If Set to true, SVM objects will be deleted and data volumes will be offline and deleted")]
      [Bool]$Force,
      [Parameter(Mandatory = $True, HelpMessage = "The Credential to authenticate to AIQUM")]
      [ValidateNotNullOrEmpty()]
      [System.Management.Automation.PSCredential]$Credential
   )
   #'---------------------------------------------------------------------------
   #'Validate the input paramaters.
   #'---------------------------------------------------------------------------
   [Bool]$id = $False
   If(-Not($VserverID)){
      If((-Not($VserverName)) -And (-Not($ClusterName))){
         Write-Warning -Message "The 'VserverName' and 'ClusterName' must be provided if the 'VserverID' is not specified"
         Return $Null;
      }
   }Else{
      [Bool]$id = $True
   }
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{
      "Authorization" = "Basic $auth"
      "Accept"        = "application/json"
      "Content-Type"  = "application/json"
   }
   #'---------------------------------------------------------------------------
   #'Enumerate the Vserver by Name if the UUID is not provided.
   #'---------------------------------------------------------------------------
   If(-Not($id)){
      Try{
         $i = Get-UMVserver -Server $Server -ClusterName $ClusterName -VserverName $VserverName -Credential $Credential -ErrorAction Stop
      }Catch{
         Write-Warning "Failed enumerating Vserver ""$VserverName"" on cluster ""$ClusterName"""
      }
      If($Null -eq $i){
         Write-Warning -Message "The Vserver ""$VserverName"" was not found on cluster ""$ClusterName"""
         Return $Null;
      }
      [String]$VserverID = $i.records.key
   }
   #'---------------------------------------------------------------------------
   #'Remove the Vserver.
   #'---------------------------------------------------------------------------
   [String]$uri = "https://$Server/api/datacenter/svm/svms/$VserverID"
   If($Force){
      [String]$uri += $("`?force=" + $Force.ToString().ToLower())
   }
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method DELETE -Headers $headers -ErrorAction Stop
      If($id){
         Write-Host "Removed Vserver ID ""$VserverID"" from Server ""$Server"" using URI ""$uri"""
      }Else{
         Write-Host "Removed Vserver ""$VserverName"" ID ""$VserverID"" from Cluster ""$ClusterName"" on server ""$Server"" using URI ""$uri"""
      }
   }Catch{
      If($id){
         Write-Warning -Message $("Failed removing VserverID ""$VserverID"" from Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
      }Else{
         Write-Warning -Message $("Failed removing Vserver ""$VserverName"" ID ""$VserverID"" from Cluster ""$ClusterName"" on server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
      }
   }
   Return $response;
}#'End Function Remove-UMVserver.
#'------------------------------------------------------------------------------
Function Invoke-UMRediscover{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $False, HelpMessage = "The Cluster Name")]
      [String]$ClusterName,
      [Parameter(Mandatory = $False, HelpMessage = "The Cluster Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$ClusterID,
      [Parameter(Mandatory = $True, HelpMessage = "The Credential to authenticate to AIQUM")]
      [ValidateNotNullOrEmpty()]
      [System.Management.Automation.PSCredential]$Credential
   )
   #'---------------------------------------------------------------------------
   #'Validate the input parameters.
   #'---------------------------------------------------------------------------
   If((-Not($ClusterId)) -And (-Not($ClusterName))){
      Write-Warning -Message "The 'ClusterId' or 'ClusterName' paramater must be provided"
      Return $Null;
   }
   #'---------------------------------------------------------------------------
   #'Enumerate the cluster resource key if not provided.
   #'---------------------------------------------------------------------------
   If(-Not($ClusterId)){
      [String]$command = "Get-UMObjectID -Server $Server -ObjectType cluster -ObjectName $ClusterName -Credential `$Credential -ErrorAction Stop"
      Try{
         [String]$ClusterId = Invoke-Expression -Command $command -ErrorAction Stop
         Write-Host "Executed Command`: $command" -ForegroundColor Cyan
      }Catch{
         Write-Warning -Message $("Failed Executing Command`: $command. Error " + $_.Exception.Message)
         Return $Null;
      }
      If([String]::IsNullOrEmpty($ClusterID)){
         Write-Warning -Message "Failed enumerating ID for cluster ""$ClusterName"""
         Return $Null;
      }
   }
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{
      "Authorization" = "Basic $auth"
      "Accept"        = "application/json"
      "Content-Type"  = "application/json"
   }
   #'---------------------------------------------------------------------------
   #'Create a hashtable for the body and covert to JSON.
   #'---------------------------------------------------------------------------
   [String]$uri         = "https://$Server/api/management-server/admin/datasources/$ClusterId/discover"
   [HashTable]$discover = @{"resourceKey" = $ClusterId};
   $body = $discover | ConvertTo-Json
   #'---------------------------------------------------------------------------
   #'Rediscover the Cluster.
   #'---------------------------------------------------------------------------
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method POST -Body $body -Headers $headers -ErrorAction Stop
      If($ClusterID){
         Write-Host "Invoked rediscovery for Cluster ID ""$ClusterId"" on Server ""$Server"" using URI ""$uri"""
      }Else{
         Write-Host "Invoked rediscovery for Cluster ""$ClusterName"" on Server ""$Server"" using URI ""$uri"""
      }
   }Catch{
      If($ClusterID){
         Write-Warning -Message $("Failed Invoking rediscovery for Cluster ID ""$ClusterId"" on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
      }Else{
         Write-Warning -Message $("Failed Invoking rediscovery for Cluster ""$ClusterName"" on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
      }
   }
   Return $response;
}#'End Function Invoke-UMRediscover.
#'------------------------------------------------------------------------------
Function Wait-UMRediscover{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $True, HelpMessage = "The Job ID")]
      [ValidateNotNullOrEmpty()]
      [String]$JobID,
      [Parameter(Mandatory = $False, HelpMessage = "The maximum timeout in seconds to wait for the job to complete. Default is 300 seconds")]
      [Int]$Timeout = 30,
      [Parameter(Mandatory = $False, HelpMessage = "The maximum number of seconds to wait inbetween checking the job status. Default is 3 seconds")]
      [ValidateRange(1, 60)]
      [Int]$WaitInterval = 3,
      [Parameter(Mandatory = $True, HelpMessage = "The Credential to authenticate to AIQUM")]
      [ValidateNotNullOrEmpty()]
      [System.Management.Automation.PSCredential]$Credential
   )
   #'---------------------------------------------------------------------------
   #'Wait for the discovery job to complete or until the timeout is exceeded.
   #'---------------------------------------------------------------------------
   [Long]$waited     = 0
   [Long]$timeWaited = $waited
   [Bool]$rediscover = $False
   Do{
      [Long]$timeWaited += [Long]($waited + $waitInterval)
      #'------------------------------------------------------------------------
      #'Enumerate the rediscovery job.
      #'------------------------------------------------------------------------
      [String]$command = "Get-UMJobID -Server $Server -JobID $JobId -Credential `$Credential -ErrorAction Stop"
      Try{
         $job = Invoke-Expression -Command $command -ErrorAction Stop
         Write-Host "Executed Command`: $command"
      }Catch{
         Write-Warning -Message $("Failed Executing Command`: $command. Error " + $_.Exception.Message)
         Return $rediscover;
      }
      #'------------------------------------------------------------------------
      #'Check the monitor discovery tasks within the rediscover job.
      #'------------------------------------------------------------------------
      If($Null -ne $job){
         $tasks = $job.task_reports
         [Int]$taskCount    = 0
         [Int]$successCount = 0
         ForEach($task In $tasks){
            If($task.type -eq "monitor_discover"){
               [Int]$taskCount++
               If($task.state -eq 'completed' -And $task.status -eq 'normal'){
                  [Int]$successCount++
               }Else{
                  Write-Host $("Job`: " + $task.key + ". Type`: " + $task.type + ". State`: " + $task.state + ". Status`: " + $task.status)
               }
            }
         }
      }Else{
         Break;
      }
      If(($taskCount -eq $successCount) -And ($timeWaited -le $TimeOut) -And $TimeOut -gt 0){
         [Bool]$discovered = $True;
         Break;
      }
      Start-Sleep -Seconds $WaitInterval         
   }Until(($taskCount -eq $successCount) -Or (($timeWaited -ge $TimeOut) -And $TimeOut -gt 0))
   Return $discovered;
}#'End Function Wait-UMRediscover.
#'------------------------------------------------------------------------------
Function Wait-UMJobID{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $True, HelpMessage = "The Job ID")]
      [ValidateNotNullOrEmpty()]
      [String]$JobID,
      [Parameter(Mandatory = $False, HelpMessage = "The Desired Job Status")]
      [String]$DesiredStatus="normal",
      [Parameter(Mandatory = $False, HelpMessage = "The Desired Job State")]
      [String]$DesiredState="completed",
      [Parameter(Mandatory = $False, HelpMessage = "The maximum timeout in seconds to wait for the job to complete. Default is 300 seconds")]
      [Int]$Timeout = 30,
      [Parameter(Mandatory = $False, HelpMessage = "The maximum number of seconds to wait inbetween checking the job status. Default is 3 seconds")]
      [ValidateRange(1, 60)]
      [Int]$WaitInterval = 3,
      [Parameter(Mandatory = $True, HelpMessage = "The Credential to authenticate to AIQUM")]
      [ValidateNotNullOrEmpty()]
      [System.Management.Automation.PSCredential]$Credential
   )
   #'---------------------------------------------------------------------------
   #'Wait for the job to reach the desired State and Status or until the timeout is exceeded.
   #'---------------------------------------------------------------------------
   [Long]$waited     = 0
   [Long]$timeWaited = $waited
   [Bool]$isComplete = $False
   Do{
      [Long]$timeWaited += [Long]($waited + $waitInterval)
      #'------------------------------------------------------------------------
      #'Enumerate the rediscovery job.
      #'------------------------------------------------------------------------
      [String]$command = "Get-UMJobID -Server $Server -JobID $JobId -Credential `$Credential -ErrorAction Stop"
      Try{
         $job = Invoke-Expression -Command $command -ErrorAction Stop
         Write-Host "Executed Command`: $command"
      }Catch{
         Write-Warning -Message $("Failed Executing Command`: $command. Error " + $_.Exception.Message)
         Return $isComplete;
      }
      #'------------------------------------------------------------------------
      #'Check the job status and state.
      #'------------------------------------------------------------------------
      If($Null -ne $job){
         If(($job.status -eq $DesiredStatus) -And ($job.state -eq $DesiredState)){
            [Bool]$isComplete = $True
         }ElseIf(($job.status -ne "normal") -And ($job.state -eq "completed")){
            Break;
         }Else{
            Write-Host $("Job`: " + $job.key + ". Status`: " + $job.status + ". State`: " + $job.state)
         }
      }Else{
         Return $False;
      }
      If(($icComplete) -And ($timeWaited -le $TimeOut) -And $TimeOut -gt 0){
         Break;
      }
      Start-Sleep -Seconds $WaitInterval         
   }Until(($isComplete) -Or (($timeWaited -ge $TimeOut) -And $TimeOut -gt 0))
   Return $isComplete;
}#'End Function Wait-UMJobID.
#'------------------------------------------------------------------------------
Function Get-UMJob{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $False, HelpMessage = "The Job Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$JobID,
      [Parameter(Mandatory = $False, HelpMessage = "The Job Name")]
      [String]$JobName,
      [Parameter(Mandatory = $False, HelpMessage = "The Job Type")]
      [String]$Type,
      [Parameter(Mandatory = $False, HelpMessage = "The Job State")]
      [String]$State,
      [Parameter(Mandatory = $False, HelpMessage = "The Job Status")]
      [String]$Status,
      [Parameter(Mandatory = $False, HelpMessage = "The time the job was submitted")]
      [String]$SubmitTime,
      [Parameter(Mandatory = $False, HelpMessage = "The time the job completed")]
      [String]$CompleteTime,
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
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth        = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers     = @{"Authorization" = "Basic $auth"}
   [String]$uri = "https://$Server/api/management-server/jobs?"
   [Bool]$query = $False;
   If($JobID){
      [String]$uri += "&key=$JobID"
      [Bool]$query = $True
   }
   If($JobName){
      [String]$uri += "&name=$JobName"
      [Bool]$query = $True
   }
   If($Type){
      [String]$uri += "&type=$Type"
      [Bool]$query = $True
   }
   If($State){
      [String]$uri += "&state=$State"
      [Bool]$query = $True
   }
   If($Status){
      [String]$uri += "&status=$Status"
      [Bool]$query = $True
   }
   If($SubmitTime){
      [String]$uri += "&submit_time=$SubmitTime"
      [Bool]$query = $True
   }
   If($CompleteTime){
      [String]$uri += "&complete_time=$CompleteTime"
      [Bool]$query = $True
   }
   If($Offset){
      [String]$uri += "&offset=$Offset"
   }
   If($OrderBy){
      [String]$uri += "&order_by=$OrderBy"
   }
   If($MaxRecords){
      [String]$uri += "&max_records=$MaxRecords"
   }
   If(-Not($query)){
      [String]$uri = $uri.SubString(0, ($uri.Length -1))
   }Else{
      [String]$uri = $uri.Replace("?&", "?")
   }
   #'---------------------------------------------------------------------------
   #'Enumerate the jobs.
   #'---------------------------------------------------------------------------
   Try{
      $job = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers -ErrorAction Stop
      Write-Host "Enumerated jobs on Server ""$Server"" using URI ""$uri"""
   }Catch{
      Write-Warning -Message $("Failed enumerating jobs on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message)
   }
   Return $job;
}#'End Function Get-UMJob.
#'------------------------------------------------------------------------------
Function Get-UMJobID{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $True, HelpMessage = "The Job ID")]
      [ValidateNotNullOrEmpty()]
      [String]$JobID,
      [Parameter(Mandatory = $True, HelpMessage = "The Credential to authenticate to AIQUM")]
      [ValidateNotNullOrEmpty()]
      [System.Management.Automation.PSCredential]$Credential
   )
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth        = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers     = @{"Authorization" = "Basic $auth"}
   [String]$uri = "https://$Server/api/management-server/jobs/$JobID"
   #'---------------------------------------------------------------------------
   #'Enumerate the job.
   #'---------------------------------------------------------------------------
   Try{
      $job = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers -ErrorAction Stop
      Write-Host "Enumerated job ""$JobID"" on Server ""$Server"" using URI ""$uri"""
   }Catch{
      Write-Warning -Message $("Failed enumerating job ""$JobID"" on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message)
   }
   Return $job;
}#'End Function Get-UMJobID.
#'------------------------------------------------------------------------------
Function Set-UMDatasourcePassword{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $False, HelpMessage = "The Cluster Name")]
      [String]$ClusterName,
      [Parameter(Mandatory = $False, HelpMessage = "The Cluster Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$ClusterID,
      [Parameter(Mandatory = $True, HelpMessage = "The Credential to reset the cluster password in AIQUM")]
      [ValidateNotNullOrEmpty()]
      [System.Management.Automation.PSCredential]$ClusterCredential,
      [Parameter(Mandatory = $True, HelpMessage = "The Credential to authenticate to AIQUM")]
      [ValidateNotNullOrEmpty()]
      [System.Management.Automation.PSCredential]$Credential
   )
   #'---------------------------------------------------------------------------
   #'Validate the input parameters.
   #'---------------------------------------------------------------------------
   If((-Not($ClusterId)) -And (-Not($ClusterName))){
      Write-Warning -Message "The 'ClusterId' or 'ClusterName' paramater must be provided"
      Return $Null;
   }
   #'---------------------------------------------------------------------------
   #'Enumerate the cluster resource key if not provided.
   #'---------------------------------------------------------------------------
   If(-Not($ClusterId)){
      [String]$command = "Get-UMObjectID -Server $Server -ObjectType 'cluster' -ObjectName $ClusterName -Credential `$Credential -ErrorAction Stop"
      Try{
         [String]$ClusterId = Invoke-Expression -Command $command -ErrorAction Stop
         Write-Host "Executed Command`: $command" -ForegroundColor Cyan
      }Catch{
         Write-Warning -Message $("Failed Executing Command`: $command. Error " + $_.Exception.Message)
         Return $Null;
      }
      If([String]::IsNullOrEmpty($ClusterID)){
         Write-Warning -Message "Failed enumerating ID for cluster ""$ClusterName"""
         Return $Null;
      }
   }
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{
      "Authorization" = "Basic $auth"
      "Accept"        = "application/json"
      "Content-Type"  = "application/json"
   }
   #'---------------------------------------------------------------------------
   #'Create a hashtable for the body and covert to JSON.
   #'---------------------------------------------------------------------------
   [String]$uri            = "https://$Server/api/admin/datasources/clusters/$ClusterID"
   [String]$userName       = $ClusterCredential.GetNetworkCredential().Username
   [HashTable]$Credentials = @{
      "username" = $Username
      "password" = $ClusterCredential.GetNetworkCredential().Password
   }
   $body = $Credentials | ConvertTo-Json
   #'---------------------------------------------------------------------------
   #'Set the Cluster credentials in AIQUM.
   #'---------------------------------------------------------------------------
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method PATCH -Body $body -Headers $headers -ErrorAction Stop
      If($ClusterID){
         Write-Host "Reset password for Cluster ID ""$ClusterId"" user ""$Username"" on Server ""$Server"" using URI ""$uri"""
      }Else{
         Write-Host "Reset password for Cluster ""$ClusterName"" user ""$Username""  on Server ""$Server"" using URI ""$uri"""
      }
   }Catch{
      If($ClusterID){
         Write-Warning -Message $("Failed resetting password for Cluster ID ""$ClusterId"" user ""$Username"" on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
      }Else{
         Write-Warning -Message $("Failed resetting password for Cluster ""$ClusterName"" user ""$Username"" on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
      }
   }
   Return $response;
}#'End Function Set-UMDatasourcePassword.
#'------------------------------------------------------------------------------
Function Get-UMDatasource{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $True, HelpMessage = "The Credential to authenticate to AIQUM")]
      [ValidateNotNullOrEmpty()]
      [System.Management.Automation.PSCredential]$Credential
   )
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{
      "Authorization" = "Basic $auth"
   }
   #'---------------------------------------------------------------------------
   #'Enumerate the Datasources.
   #'---------------------------------------------------------------------------
   [String]$uri = "https://$Server/api/admin/datasources/clusters"
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers -ErrorAction Stop
      Write-Host "Enumerated Datasources on Server ""$Server"" using URI ""$uri"""
   }Catch{
      Write-Warning -Message $("Failed enumerating Datasources on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
   }
   Return $response;
}#'End Function Get-UMDatasource.
#'------------------------------------------------------------------------------
Function Get-UMDatasourceID{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $True, HelpMessage = "The Cluster Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$DatasourceID,
      [Parameter(Mandatory = $True, HelpMessage = "The Credential to authenticate to AIQUM")]
      [ValidateNotNullOrEmpty()]
      [System.Management.Automation.PSCredential]$Credential
   )
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{
      "Authorization" = "Basic $auth"
   }
   #'---------------------------------------------------------------------------
   #'Enumerate the Datasources.
   #'---------------------------------------------------------------------------
   [String]$uri = "https://$Server/api/admin/datasources/clusters/$DatasourceID"
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers -ErrorAction Stop
      Write-Host "Enumerated Datasource ID ""$DatasourceID"" on Server ""$Server"" using URI ""$uri"""
   }Catch{
      Write-Warning -Message $("Failed enumerating Datasource ID ""$DatasourceID"" on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
   }
   Return $response;
}#'End Function Get-UMDatasourceID.
#'------------------------------------------------------------------------------
Function Add-UMDatasource{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $True, HelpMessage = "The Datasource Hostname, FQDN or IP Address")]
      [String]$Hostname,
      [Parameter(Mandatory = $False, HelpMessage = "The Datasource Hostname, FQDN or IP Address")]
      [Int]$PortNumber = 443,
      [Parameter(Mandatory = $False, HelpMessage = "The Datasource Protocol")]
      [ValidateSet("https")]
      [String]$Protocol = "https",
      [Parameter(Mandatory = $True, HelpMessage = "The Datasource Credential")]
      [ValidateNotNullOrEmpty()]
      [System.Management.Automation.PSCredential]$DatasouceCredential,
      [Parameter(Mandatory = $True, HelpMessage = "The Credential to authenticate to AIQUM")]
      [ValidateNotNullOrEmpty()]
      [System.Management.Automation.PSCredential]$Credential
   )
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{
      "Authorization" = "Basic $auth"
      "Accept"        = "application/json"
      "Content-Type"  = "application/json"
   }
   #'---------------------------------------------------------------------------
   #'Create a hashtable for the body and covert to JSON.
   #'---------------------------------------------------------------------------
   [String]$uri           = "https://$Server/api/admin/datasources/clusters"
   [HashTable]$datasource = @{
      "address"  = $Hostname
      "password" = $DatasouceCredential.GetNetworkCredential().Password
      "port"     = $PortNumber
      "protocol" = $Protocol
      "username" = $DatasouceCredential.GetNetworkCredential().Username
   }
   $body = $datasource | ConvertTo-Json
   #'---------------------------------------------------------------------------
   #'Add the datasource.
   #'---------------------------------------------------------------------------
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method POST -Body $body -Headers $headers -ErrorAction Stop
      Write-Host "Added datasource ""$Hostname"" on Server ""$Server"" using URI ""$uri"""
   }Catch{
      Write-Warning -Message $("Failed adding datasource ""$Hostname"" on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
   }
   Return $response;
}#'End Function Add-UMDatasource.
#'------------------------------------------------------------------------------
Function Remove-UMDatasource{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $False, HelpMessage = "The Datasource Hostname, FQDN or IP Address")]
      [String]$DatasourceName,
      [Parameter(Mandatory = $False, HelpMessage = "The Datasource Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$DatasourceID,
      [Parameter(Mandatory = $True, HelpMessage = "The Credential to authenticate to AIQUM")]
      [ValidateNotNullOrEmpty()]
      [System.Management.Automation.PSCredential]$Credential
   )
   #'---------------------------------------------------------------------------
   #'Validate the input paramaters.
   #'---------------------------------------------------------------------------
   [Bool]$id = $False
   If(-Not($DatasourceID)){
      If((-Not($DatasourceID)) -And (-Not($DatasourceName))){
         Write-Warning -Message "The 'DatasourceName' must be provided if the 'DatasourceID' is not specified"
         Return $Null;
      }
   }Else{
      [Bool]$id = $True
   }
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{
      "Authorization" = "Basic $auth"
      "Accept"        = "application/json"
      "Content-Type"  = "application/json"
   }
   #'---------------------------------------------------------------------------
   #'Enumerate the Datasource by Name if the resource key is not provided.
   #'---------------------------------------------------------------------------
   If(-Not($id)){
      Try{
         [String]$command = "Get-UMDatasource -Server $Server -Credential `$Credential -ErrorAction Stop"
         $datasources = Invoke-Expression -Command $command -ErrorAction Stop
         Write-Host "Executed Command`: $command" -ForegroundColor Cyan
      }Catch{
         Write-Warning $("Failed Executing Command`: $command. Error " + $_.Exception.Message)
         Return $Null;
      }
      If($Null -eq $datasources){
         Write-Warning -Message "There are no datasources configured on server ""$Server"""
         Return $Null;
      }      
      [String]$DatasourceID = $Null;
      ForEach($datasource In $datasources.records){
         If(($datasource.name -Match $DatasourceName) -Or ($datasource.address -Match $DatasourceName)){
            [String]$DatasourceID = $datasource.key
         }
      }
      If([String]::IsNullOrEmpty($DatasourceID)){
         Write-Warning -Message "The datasource ""$DatasourceName"" was not found on server ""$Server"""
         Return $Null;
      }
   }
   #'---------------------------------------------------------------------------
   #'Remove the datasource.
   #'---------------------------------------------------------------------------
   [String]$uri = "https://$Server/api/admin/datasources/clusters/$DatasourceID"
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method DELETE -Headers $headers -ErrorAction Stop
      If($id){
         Write-Host "Removed Datasource ID ""$DatasourceID"" from Server ""$Server"" using URI ""$uri"""
      }Else{
         Write-Host "Removed Datasource ""$DatasourceName"" from Server ""$Server"" using URI ""$uri"""
      }
   }Catch{
      If($id){
         Write-Warning -Message $("Failed removing Datasource ID ""$DatasourceID"" from Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
      }Else{
         Write-Warning -Message $("Failed removing Datasource ""$DatasourceName"" from Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
      }
   }
   Return $response;
}#'End Function Remove-UMDatasource.
#'------------------------------------------------------------------------------
Function Get-UMDataRetention{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $True, HelpMessage = "The Credential to authenticate to AIQUM")]
      [ValidateNotNullOrEmpty()]
      [System.Management.Automation.PSCredential]$Credential
   )
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{
      "Authorization" = "Basic $auth"
   }
   #'---------------------------------------------------------------------------
   #'Enumerate the Datasources.
   #'---------------------------------------------------------------------------
   [String]$uri = "https://$Server/api/management-server/admin/retention"
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers -ErrorAction Stop
      Write-Host "Enumerated Data Retention on Server ""$Server"" using URI ""$uri"""
   }Catch{
      Write-Warning -Message $("Failed enumerating Data Retention on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
   }
   Return $response;
}#'End Function Get-UMDataRetention.
#'------------------------------------------------------------------------------
Function Set-UMDataRetention{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $True, HelpMessage = "The number of months that AIQUM retains events")]
      [ValidateRange(1, 34)]
      [Int]$EventMonths,
      [Parameter(Mandatory = $True, HelpMessage = "The number of months that AIQUM retains performance data")]
      [ValidateRange(1, 13)]
      [Int]$PerformanceMonths,
      [Parameter(Mandatory = $True, HelpMessage = "The Credential to authenticate to AIQUM")]
      [ValidateNotNullOrEmpty()]
      [System.Management.Automation.PSCredential]$Credential
   )
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{
      "Authorization" = "Basic $auth"
      "Accept"        = "application/json"
      "Content-Type"  = "application/json"
   }
   #'---------------------------------------------------------------------------
   #'Create a hashtable for the body and covert to JSON.
   #'---------------------------------------------------------------------------
   [String]$uri       = "https://$Server/api/management-server/admin/retention"
   [Array]$retention  = @();
   [HashTable]$policy = @{};
   [HashTable]$events = @{
      "type"  = "EVENT_RETENTION_PERIOD"
      "value" = $EventMonths
   }
   [Array]$retention += $events
   [HashTable]$performance = @{
      "type"  = "HOURLY_SUMMARY_RETENTION_PERIOD"
      "value" = $PerformanceMonths
   }
   [Array]$retention += $performance
   [HashTable]$policy.Add("retentionPolicyObjectList", $retention)
   $body = $policy | ConvertTo-Json
   #'---------------------------------------------------------------------------
   #'Set the event and performance data retention.
   #'---------------------------------------------------------------------------
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method PUT -Body $body -Headers $headers -ErrorAction Stop
      Write-Host "Set retention for events to ""$EventMonths"" months and performance data to ""$PerformanceMonths"" months on Server ""$Server"" using URI ""$uri"""
   }Catch{
      Write-Warning -Message $("Failed setting retention for events to ""$EventMonths"" months and performance data to ""$PerformanceMonths"" months on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
      Return $False;
   }
   Return $True;
}#'End Function Set-UMDataRetention.
#'------------------------------------------------------------------------------
Function Get-UMUser{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $False, HelpMessage = "The username")]
      [String]$Username,
      [Parameter(Mandatory = $False, HelpMessage = "The user role. Valid values are 'report_schema', 'integration_schema', 'operator', 'storage_administrator' or 'administrator'")]
      [String]$Role,
      [Parameter(Mandatory = $False, HelpMessage = "The user authentication type. Valid values are 'ldap_group', 'ldap_user', 'local_user', 'database_user' or 'maintenance_user'")]
      [ValidateSet("ldap_group","ldap_user","local_user","database_user","maintenance_user")]
      [String]$AuthenticationType,
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
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{"Authorization" = "Basic $auth"}
   #'---------------------------------------------------------------------------
   #'Set the URI to enumerate the users.
   #'---------------------------------------------------------------------------
   [String]$uri = "https://$Server/api/security/users?"
   [Bool]$query = $False;
   If($Username){
      [String]$uri += "&name=$Username"
      [Bool]$query = $True
   }
   If($Role){
      [String]$uri += "&role=$Role"
      [Bool]$query = $True
   }
   If($AuthenticationType){
      [String]$uri += "&authentication_type=$AuthenticationType"
      [Bool]$query = $True
   }
   If($Offset){
      [String]$uri += "&offset=$Offset"
   }
   If($MaxRecords){
      [String]$uri += "&max_records=$MaxRecords"
   }
   If($OrderBy){
      [String]$uri += "&order_by=$OrderBy"
   }
   If(-Not($query)){
      [String]$uri = $uri.SubString(0, ($uri.Length -1))
   }Else{
      [String]$uri = $uri.Replace("?&", "?")
   }
   #'---------------------------------------------------------------------------
   #'Enumerate the users.
   #'---------------------------------------------------------------------------
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers -ErrorAction Stop
      Write-Host "Enumerated Users on Server ""$Server"" using URI ""$uri"""
   }Catch{
      Write-Warning -Message $("Failed enumerating Users on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
   }
   Return $response;
}#'End Function Get-UMUser.
#'------------------------------------------------------------------------------
Function Get-UMUsername{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $True, HelpMessage = "The User Name")]
      [String]$Username,
      [Parameter(Mandatory = $True, HelpMessage = "The Credential to authenticate to AIQUM")]
      [ValidateNotNullOrEmpty()]
      [System.Management.Automation.PSCredential]$Credential
   )
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{"Authorization" = "Basic $auth"}
   #'---------------------------------------------------------------------------
   #'Enumerate the user.
   #'---------------------------------------------------------------------------
   [String]$uri = "https://$Server/api/security/users/$Username"
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers -ErrorAction Stop
      Write-Host "Enumerated User ""$Username"" on Server ""$Server"" using URI ""$uri"""
   }Catch{
      Write-Warning -Message $("Failed enumerating User ""$Username"" on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
   }
   Return $response;
}#'End Function Get-UMUsername.
#'------------------------------------------------------------------------------
Function New-UMUser{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $False, HelpMessage = "The user role. Valid values are 'report_schema', 'integration_schema', 'operator', 'storage_administrator' or 'administrator'")]
      [ValidateSet("report_schema","integration_schema","operator","storage_administrator","administrator")]
      [String]$Role,
      [Parameter(Mandatory = $False, HelpMessage = "The user authentication type. Valid values are 'ldap_group', 'ldap_user', 'local_user', 'database_user' or 'maintenance_user'")]
      [ValidateSet("ldap_group","ldap_user","local_user","database_user","maintenance_user")]
      [String]$AuthenticationType,
      [Parameter(Mandatory = $False, HelpMessage = "The User Email Address")]
      [String]$EmailAddress,
      [Parameter(Mandatory = $False, HelpMessage = "If specified the User represents a group")]
      [Switch]$Group,
      [Parameter(Mandatory = $True, HelpMessage = "The User Credential")]
      [ValidateNotNullOrEmpty()]
      [System.Management.Automation.PSCredential]$UserCredential,
      [Parameter(Mandatory = $True, HelpMessage = "The Credential to authenticate to AIQUM")]
      [ValidateNotNullOrEmpty()]
      [System.Management.Automation.PSCredential]$Credential
   )
   #'---------------------------------------------------------------------------
   #'Validate the input parameters.
   #'---------------------------------------------------------------------------
   If(($AuthenticationType -eq 'local_user') -Or ($AuthenticationType -eq 'ldap_user')){
      If($EmailAddress -NotMatch '^[A-Z0-9_\-.]+@[A-Z0-9.-]+$'){
         Write-Warning -Message "A valid email address must be provided"
         Return $Null;
      }
   }
   [Bool]$isGroup = $False
   If($Group){
      [Bool]$isGroup = $True
   }
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{
      "Authorization" = "Basic $auth"
      "Accept"        = "application/json"
      "Content-Type"  = "application/json"
   }
   #'---------------------------------------------------------------------------
   #'Create a hashtable for the body and covert to JSON.
   #'---------------------------------------------------------------------------
   [String]$uri      = "https://$Server/api/security/users"
   [String]$username = $UserCredential.GetNetworkCredential().Username
   [HashTable]$user = @{};
   [HashTable]$user.Add("authentication_type", $AuthenticationType)
   [HashTable]$user.Add("confirm_password",    $UserCredential.GetNetworkCredential().Password)
   If(($AuthenticationType -eq 'local_user') -Or ($AuthenticationType -eq 'ldap_user')){
      [HashTable]$user.Add("email", $EmailAddress)
   }
   [HashTable]$user.Add("group",               $isGroup)
   [HashTable]$user.Add("name",                $username)
   [HashTable]$user.Add("password",            $UserCredential.GetNetworkCredential().Password)
   [HashTable]$user.Add("role",                $Role)
   $body = $user | ConvertTo-Json
   #'---------------------------------------------------------------------------
   #'Create the user.
   #'---------------------------------------------------------------------------
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method POST -Body $body -Headers $headers -ErrorAction Stop
      Write-Host "Created User ""$username"" on Server ""$Server"" using URI ""$uri"""
   }Catch{
      Write-Warning -Message $("Failed creating User ""$username"" on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
   }
   Return $response;
}#'End Function New-UMUser.
#'------------------------------------------------------------------------------
Function Set-UMUser{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $False, HelpMessage = "The user role. Valid values are 'report_schema', 'integration_schema', 'operator', 'storage_administrator' or 'administrator'")]
      [ValidateSet("report_schema","integration_schema","operator","storage_administrator","administrator")]
      [String]$Role,
      [Parameter(Mandatory = $False, HelpMessage = "The User Email Address")]
      [String]$EmailAddress,
      [Parameter(Mandatory = $True, HelpMessage = "The User Credential")]
      [ValidateNotNullOrEmpty()]
      [System.Management.Automation.PSCredential]$UserCredential,
      [Parameter(Mandatory = $True, HelpMessage = "The Credential to authenticate to AIQUM")]
      [ValidateNotNullOrEmpty()]
      [System.Management.Automation.PSCredential]$Credential
   )
   #'---------------------------------------------------------------------------
   #'Validate the input parameters.
   #'---------------------------------------------------------------------------
   If($EmailAddress){
      If($EmailAddress -NotMatch '^[A-Z0-9_\-.]+@[A-Z0-9.-]+$'){
         Write-Warning -Message "A valid email address must be provided"
         Return $Null;
      }
   }
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{
      "Authorization" = "Basic $auth"
      "Accept"        = "application/json"
      "Content-Type"  = "application/json"
   }
   #'---------------------------------------------------------------------------
   #'Create a hashtable for the body and covert to JSON.
   #'---------------------------------------------------------------------------
   [String]$username = $UserCredential.GetNetworkCredential().Username
   [String]$uri      = "https://$Server/api/security/users/$username"
   [HashTable]$user  = @{};
   If($EmailAddress){
      [HashTable]$user.Add("email", $EmailAddress)
   }
   If($Role){
      [HashTable]$user.Add("password", $UserCredential.GetNetworkCredential().Password)
   }
   If($Role){
      [HashTable]$user.Add("role", $Role)
   }
   $body = $user | ConvertTo-Json
   #'---------------------------------------------------------------------------
   #'Update the user.
   #'---------------------------------------------------------------------------
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method PATCH -Body $body -Headers $headers -ErrorAction Stop
      Write-Host "Updated User ""$username"" on Server ""$Server"" using URI ""$uri"""
   }Catch{
      Write-Warning -Message $("Failed updating User ""$username"" on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
   }
   Return $response;
}#'End Function Set-UMUser.
#'------------------------------------------------------------------------------
Function Remove-UMUser{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $False, HelpMessage = "The User Name")]
      [String]$Username,
      [Parameter(Mandatory = $True, HelpMessage = "The Credential to authenticate to AIQUM")]
      [ValidateNotNullOrEmpty()]
      [System.Management.Automation.PSCredential]$Credential
   )
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{
      "Authorization" = "Basic $auth"
      "Accept"        = "application/json"
      "Content-Type"  = "application/json"
   }
   #'---------------------------------------------------------------------------
   #'Remove the user.
   #'---------------------------------------------------------------------------
   [String]$uri = "https://$Server/api/security/users/$Username"
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method DELETE -Headers $headers -ErrorAction Stop
      Write-Host "Deleted User ""$Username"" on Server ""$Server"" using URI ""$uri"""
   }Catch{
      Write-Warning -Message $("Failed deleting User ""$Username"" on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
      Return $False;
   }
   Return $True;
}#'End Function Remove-UMDatasource.
#'------------------------------------------------------------------------------
Function New-UMLunMap{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $False, HelpMessage = "The LUN resource key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$LunID,
      [Parameter(Mandatory = $False, HelpMessage = "The LUN Path")]
      [String]$LunPath,
      [Parameter(Mandatory = $False, HelpMessage = "The IGroup resource key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$IGroupID,
      [Parameter(Mandatory = $False, HelpMessage = "The IGroup Name")]
      [String]$IGroupName,
      [Parameter(Mandatory = $False, HelpMessage = "The LUN Logical Unit Number")]
      [ValidateRange(0, 4095)]
      [Int]$ID,
      [Parameter(Mandatory = $False, HelpMessage = "The Vserver Name")]
      [String]$VserverName,
      [Parameter(Mandatory = $False, HelpMessage = "The Cluster Name")]
      [String]$ClusterName,
      [Parameter(Mandatory = $True, HelpMessage = "The Credential to authenticate to AIQUM")]
      [ValidateNotNullOrEmpty()]
      [System.Management.Automation.PSCredential]$Credential
   )
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{
      "Authorization" = "Basic $auth"
      "Accept"        = "application/json"
      "Content-Type"  = "application/json"
   }
   #'---------------------------------------------------------------------------
   #'Enumerate the LUN Resource key if not provided.
   #'---------------------------------------------------------------------------
   If((-Not($LunID)) -And $VserverName -And $ClusterName){
      [String]$command = "Get-UMObjectID -Server $Server -ObjectType 'lun' -ObjectName $LunPath -VserverName $VserverName -ClusterName $ClusterName -Credential `$Credential -ErrorAction Stop"
      Try{
         [String]$LunID = Invoke-Expression -Command $command -ErrorAction Stop
         Write-Host "Executed Command`: $command" -ForegroundColor Cyan
      }Catch{
         Write-Warning -Message $("Failed Executing Command`: $command. Error " + $_.Exception.Message)
         Return $Null;
      }
      If([String]::IsNullOrEmpty($LunID)){
         Write-Warning -Message "Failed enumerating LUN ""$LunPath"" on Vserver ""$VserverName"" on Cluster ""$ClusterName"""
         Return $Null;
      }
   }Else{
      Write-Warning -Message "The 'LunPath', 'VserverName' and 'ClusterName' parameters must be provided if the 'LunID' is not specified"
      Return $Null;
   }
   #'---------------------------------------------------------------------------
   #'Enumerate the IGroup Resource key if not provided.
   #'---------------------------------------------------------------------------
   If((-Not($IGroupID)) -And $VserverName -And $ClusterName){
      [String]$command = "Get-UMObjectID -Server $Server -ObjectType 'igroup' -ObjectName $IGroupName -VserverName $VserverName -ClusterName $ClusterName -Credential `$Credential -ErrorAction Stop"
      Try{
         [String]$IGroupID = Invoke-Expression -Command $command -ErrorAction Stop
         Write-Host "Executed Command`: $command" -ForegroundColor Cyan
      }Catch{
         Write-Warning -Message $("Failed Executing Command`: $command. Error " + $_.Exception.Message)
         Return $Null;
      }
      If([String]::IsNullOrEmpty($IGroupID)){
         Write-Warning -Message "Failed enumerating IGroup ""$IGroupName"" on Vserver ""$VserverName"" on Cluster ""$ClusterName"""
         Return $Null;
      }
   }Else{
      Write-Warning -Message "The 'IGroupName', 'VserverName' and 'ClusterName' parameters must be provided if the 'IGroupID' is not specified"
      Return $Null;
   }
   #'---------------------------------------------------------------------------
   #'Create a hashtable for the body and covert to JSON.
   #'---------------------------------------------------------------------------
   [String]$uri       = "https://$Server/api/storage-provider/luns/$LunID"
   [Array]$mapping    = @();
   [HashTable]$lunmap = @{};
   [HashTable]$igroup = @{"key" = $IGroupID}
   [HashTable]$map    = @{"igroup" = $igroup}
   If($ID){
      [HashTable]$map.Add("logical_unit_number", $ID)
   }
   [Array]$mapping += $map
   [HashTable]$lunmap.Add("lun_maps", $mapping)
   $body = $lunmap | ConvertTo-Json -Depth 3
   #'---------------------------------------------------------------------------
   #'Map the LUN.
   #'---------------------------------------------------------------------------
   [String]$message = "LUN ID ""$LunID"" "
   If($ID){
      [String]$message += "ID ""$ID"" "
   }
   [STring]$message += "to IGroup ID ""$IGroupID"" on Server ""$Server"" using URI ""$uri"""
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method PATCH -Body $body -Headers $headers -ErrorAction Stop
      Write-Host $("Mapped " + $message)
   }Catch{
      Write-Warning -Message $("Failed mapping " + $message + ". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
   }
   Return $response;
}#'End Function Add-UMLunMap.
#'------------------------------------------------------------------------------
Function Set-UMLun{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $False, HelpMessage = "The LUN resource key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$LunID,
      [Parameter(Mandatory = $False, HelpMessage = "The LUN Path")]
      [String]$LunPath,
      [Parameter(Mandatory = $False, HelpMessage = "The LUN state. Valid values are 'online' or 'offline'")]
      [ValidateSet("online","offline")]
      [String]$State,
      [Parameter(Mandatory = $False, HelpMessage = "The LUN Size in GigaBytes")]
      [Int]$SizeGB,
      [Parameter(Mandatory = $False, HelpMessage = "The Performance Service Level resource key. The syntax is: '<uuid>'")]
      [String]$ServiceLevelID,
      [Parameter(Mandatory = $False, HelpMessage = "The Performance Service Level name")]
      [String]$ServiceLevelName,
      [Parameter(Mandatory = $False, HelpMessage = "The Storage Efficiency Policy resource key. The syntax is: '<uuid>'")]
      [String]$EfficiencyPolicyID,
      [Parameter(Mandatory = $False, HelpMessage = "The Storage Efficiency Policy name")]
      [String]$EfficiencyPolicyName,
      [Parameter(Mandatory = $False, HelpMessage = "The Vserver Name")]
      [String]$VserverName,
      [Parameter(Mandatory = $False, HelpMessage = "The Cluster Name")]
      [String]$ClusterName,
      [Parameter(Mandatory = $True, HelpMessage = "The Credential to authenticate to AIQUM")]
      [ValidateNotNullOrEmpty()]
      [System.Management.Automation.PSCredential]$Credential
   )
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{
      "Authorization" = "Basic $auth"
      "Accept"        = "application/json"
      "Content-Type"  = "application/json"
   }
   #'---------------------------------------------------------------------------
   #'Enumerate the LUN Resource key if not provided.
   #'---------------------------------------------------------------------------
   [Int]$counter = 0
   If((-Not($LunID)) -And $VserverName -And $ClusterName){
      [String]$command = "Get-UMObjectID -Server $Server -ObjectType 'lun' -ObjectName $LunPath -VserverName $VserverName -ClusterName $ClusterName -Credential `$Credential -ErrorAction Stop"
      Try{
         [String]$LunID = Invoke-Expression -Command $command -ErrorAction Stop
         Write-Host "Executed Command`: $command" -ForegroundColor Cyan
      }Catch{
         Write-Warning -Message $("Failed Executing Command`: $command. Error " + $_.Exception.Message)
         Return $Null;
      }
      If([String]::IsNullOrEmpty($LunID)){
         Write-Warning -Message "Failed enumerating LUN ""$LunPath"" on Vserver ""$VserverName"" on Cluster ""$ClusterName"""
         Return $Null;
      }
   }Else{
      Write-Warning -Message "The 'LunPath', 'VserverName' and 'ClusterName' parameters must be provided if the 'LunID' is not specified"
      Return $Null;
   }
   #'---------------------------------------------------------------------------
   #'Ensure the current LUN size is not less than the new size.
   #'---------------------------------------------------------------------------
   If($SizeGB){
      [String]$command = "Get-UMLunID -Server $Server -LunID '$LunID' -Credential `$Credential -ErrorAction Stop"
      Try{
         $lun = Invoke-Expression -Command $command -ErrorAction Stop
         Write-Host "Executed Command`: $command" -ForegroundColor Cyan
      }Catch{
         Write-Warning -Message $("Failed Executing Command`: $command. Error " + $_.Exception.Message)
         Return $Null;
      }
      If($Null -ne $lun){
         [Int]$lunSizeGB = ($lun.space.size / (1024 * 1024 * 1024))
         If($SizeGb -lt $lunSizeGB){
            Write-Warning -Message "The current LUN size is $lunSizeGB`GB. It can not be decreased to $SizeGB`GB"
            Return $Null;
         }
      }Else{
         Write-Warning -Message "Failed Enumerating LUN ID ""$LunID"" on server ""$Server"""
         Return $Null;
      }
   }
   #'---------------------------------------------------------------------------
   #'Enumerate the Performance Service Level Resource key if not provided.
   #'---------------------------------------------------------------------------
   If((-Not($ServiceLevelID)) -And $ServiceLevelName){
      [String]$command = "Get-UMObjectID -Server $Server -ObjectType 'service-level' -ObjectName '$ServiceLevelName' -Credential `$Credential -ErrorAction Stop"
      Try{
         [String]$ServiceLevelID = Invoke-Expression -Command $command -ErrorAction Stop
         Write-Host "Executed Command`: $command" -ForegroundColor Cyan
      }Catch{
         Write-Warning -Message $("Failed Executing Command`: $command. Error " + $_.Exception.Message)
         Return $Null;
      }
      If([String]::IsNullOrEmpty($ServiceLevelID)){
         Write-Warning -Message "Failed enumerating Performance Service Level ""$ServiceLevelName"" on Server ""$Server"""
         Return $Null;
      }
   }
   #'---------------------------------------------------------------------------
   #'Enumerate the Efficiency Policy Resource key if not provided.
   #'---------------------------------------------------------------------------
   If((-Not($EfficiencyPolicyID)) -And $EfficiencyPolicyName){
      [String]$command = "Get-UMObjectID -Server $Server -ObjectType 'efficiency-policy' -ObjectName '$EfficiencyPolicyName' -Credential `$Credential -ErrorAction Stop"
      Try{
         [String]$EfficiencyPolicyID = Invoke-Expression -Command $command -ErrorAction Stop
         Write-Host "Executed Command`: $command" -ForegroundColor Cyan
      }Catch{
         Write-Warning -Message $("Failed Executing Command`: $command. Error " + $_.Exception.Message)
         Return $Null;
      }
      If([String]::IsNullOrEmpty($EfficiencyPolicyID)){
         Write-Warning -Message "Failed enumerating Storage Efficiency Policy ""$EfficiencyPolicyName"" on Server ""$Server"""
         Return $Null;
      }
   }
   #'---------------------------------------------------------------------------
   #'Create a hashtable for the body and covert to JSON.
   #'---------------------------------------------------------------------------
   [String]$uri    = "https://$Server/api/storage-provider/luns/$LunID"
   [HashTable]$lun = @{};
   [Bool]$update   = $False;
   If($State){
      [HashTable]$lun.Add("operational_state", $State)
      [Bool]$update = $True
      [Int]$counter = $counter + 1
   }
   If($ServiceLevelID){
      [HashTable]$serviceLevel = @{"key" = $ServiceLevelID};
      [HashTable]$lun.Add("performance_service_level", $serviceLevel)
      [Bool]$update = $True
      [Int]$counter = $counter + 1
   }
   If($SizeGB){
      [HashTable]$space = @{"size" = ($SizeGB * (1024 * 1024 * 1024))};
      [HashTable]$lun.Add("space", $space)
      [Bool]$update = $True
      [Int]$counter = $counter + 1
   }
   If($EfficiencyPolicyID){
      [HashTable]$policy = @{"key" = $EfficiencyPolicyID};
      [HashTable]$lun.Add("storage_efficiency_policy", $policy)
      [Bool]$update = $True
      [Int]$counter = $counter + 1
   }
   If(-Not($update)){
      Write-Host "The LUN ID ""$LunID"" was not been modified. Please provide valid input parameters"
      Return $Null;
   }Else{
      If($counter -ne 1){
         Write-Warning -Message "You can only update one property at a time"
         Return $Null;
      }
   }
   $body = $lun | ConvertTo-Json
   #'---------------------------------------------------------------------------
   #'Set the LUN.
   #'---------------------------------------------------------------------------
   [String]$message = "LUN ID ""$LunID"" "
   If($State){
      [String]$message += "State ""$State"" "
   }
   If($SizeGB){
      [String]$message += "Size ""$SizeGB`GB"" "
   }
   If($ServiceLevelID){
      [String]$message += "Performance Service Level ID ""$ServiceLevelID"" "
   }
   If($EfficiencyPolicyID){
      [String]$message += "Efficiency Policy ID ""$EfficiencyPolicyID"" "
   }
   [STring]$message += "on Server ""$Server"" using URI ""$uri"""
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method PATCH -Body $body -Headers $headers -ErrorAction Stop
      Write-Host $("Set " + $message)
   }Catch{
      Write-Warning -Message $("Failed setting " + $message + ". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
   }
   Return $response;
}#'End Function Set-UMLun.
#'------------------------------------------------------------------------------
Function Get-UMLun{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $False, HelpMessage = "The LUN resource key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$LunID,
      [Parameter(Mandatory = $False, HelpMessage = "The LUN name")]
      [String]$LunName,
      [Parameter(Mandatory = $False, HelpMessage = "The LUN UUID")]
      [String]$LunUuid,
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
      [Parameter(Mandatory = $False, HelpMessage = "The Volume Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$VolumeID,
      [Parameter(Mandatory = $False, HelpMessage = "The Volume name")]
      [String]$VolumeName,
      [Parameter(Mandatory = $False, HelpMessage = "The Volume UUID")]
      [String]$VolumeUuid,
      [Parameter(Mandatory = $False, HelpMessage = "The assigned performance service level")]
      [String]$AssignedServiceLevelName,
      [Parameter(Mandatory = $False, HelpMessage = "The assigned performance service level resource key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$AssignedServiceLevelID,
      [Parameter(Mandatory = $False, HelpMessage = "The assigned performance service level expected IOPs")]
      [Int64]$AssignedServiceLevelExpectedIops,
      [Parameter(Mandatory = $False, HelpMessage = "The assigned performance service level peak IOPs")]
      [Int64]$AssignedServiceLevelPeakIops,
      [Parameter(Mandatory = $False, HelpMessage = "The storage efficiency policy name")]
      [String]$EfficiencyPolicyName,
      [Parameter(Mandatory = $False, HelpMessage = "The storage efficiency policy resource key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$EfficiencyPolicyID,
      [Parameter(Mandatory = $False, HelpMessage = "The recommended performance service level")]
      [String]$RecommendedServiceLevelName,
      [Parameter(Mandatory = $False, HelpMessage = "The recommended performance service level resource key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$RecommendedServiceLevelID,
      [Parameter(Mandatory = $False, HelpMessage = "The recommended performance service level expected IOPs")]
      [Int64]$RecommendedServiceLevelExpectedIops,
      [Parameter(Mandatory = $False, HelpMessage = "The recommended performance service level peak IOPs")]
      [Int64]$RecommendedServiceLevelPeakIops,
      [Parameter(Mandatory = $False, HelpMessage = "The LUN Size")]
      [Int64]$Size,
      [Parameter(Mandatory = $False, HelpMessage = "A search or 'query' is issued on attributes using a 'contains' relationship")]
      [String]$Query,
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
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{"Authorization" = "Basic $auth"}
   #'---------------------------------------------------------------------------
   #'Set the URI to enumerate the vservers.
   #'---------------------------------------------------------------------------
   [String]$uri   = "https://$Server/api/storage-provider/luns?"
   [Bool]$isQuery = $False;
   If($LunID){
      [String]$uri  += "&key=$LunID"
      [Bool]$isQuery = $True
   }
   If($LunName){
      If($LunName.Contains("/")){
         [String]$uri  += "&name=$LunName"
      }Else{
         [String]$uri  += "&name=*$LunName"
      }
      [Bool]$isQuery = $True
   }
   If($LunUuid){
      [String]$uri  += "&uuid=$LunUuid"
      [Bool]$isQuery = $True
   }
   If($ClusterID){
      [String]$uri  += "&cluster.key=$ClusterID"
      [Bool]$isQuery = $True
   }
   If($ClusterName){
      [String]$uri  += "&cluster.name=$ClusterName"
      [Bool]$isQuery = $True
   }
   If($ClusterUuid){
      [String]$uri  += "&cluster.uuid=$ClusterUuid"
      [Bool]$isQuery = $True
   }
   If($VserverID){
      [String]$uri  += "&svm.key=$VserverID"
      [Bool]$isQuery = $True
   }
   If($VserverName){
      [String]$uri  += "&svm.name=$VserverName"
      [Bool]$isQuery = $True
   }
   If($VserverUuid){
      [String]$uri  += "&smv.uuid=$VserverUuid"
      [Bool]$isQuery = $True
   }
   If($VolumeID){
      [String]$uri  += "&volume.key=$VolumeID"
      [Bool]$isQuery = $True
   }
   If($VolumeName){
      [String]$uri  += "&volume.name=$VolumeName"
      [Bool]$isQuery = $True
   }
   If($VolumeUuid){
      [String]$uri  += "&volume.uuid=$VolumeUuid"
      [Bool]$isQuery = $True
   }
   If($AssignedServiceLevelName){
      [String]$uri  += "&assigned_performance_service_level.name=$AssignedServiceLevelName"
      [Bool]$isQuery = $True
   }
   If($AssignedServiceLevelID){
      [String]$uri  += "&assigned_performance_service_level.key=$AssignedServiceLevelID"
      [Bool]$isQuery = $True
   }
   If($AssignedServiceLevelExpectedIops){
      [String]$uri  += "&assigned_performance_service_level.expected_iops=$AssignedServiceLevelExpectedIops"
      [Bool]$isQuery = $True
   }
   If($AssignedServiceLevelPeakIops){
      [String]$uri  += "&assigned_performance_service_level.peak_iops=$AssignedServiceLevelPeakIops"
      [Bool]$isQuery = $True
   }
   If($EfficiencyPolicyName){
      [String]$uri  += "&assigned_storage_efficiency_policy.name=$EfficiencyPolicyName"
      [Bool]$isQuery = $True
   }
   If($EfficiencyPolicyID){
      [String]$uri  += "&assigned_storage_efficiency_policy.key=$FcpEnabled"
      [Bool]$isQuery = $True
   }
   If($RecommendedServiceLevelName){
      [String]$uri  += "&recommended_performance_service_level.name=$AssignedServiceLevelName"
      [Bool]$isQuery = $True
   }
   If($RecommendedServiceLevelID){
      [String]$uri  += "&recommended_performance_service_level.key=$AssignedServiceLevelID"
      [Bool]$isQuery = $True
   }
   If($RecommendedServiceLevelExpectedIops){
      [String]$uri  += "&recommended_performance_service_level.expected_iops=$AssignedServiceLevelExpectedIops"
      [Bool]$isQuery = $True
   }
   If($RecommendedServiceLevelPeakIops){
      [String]$uri  += "&recommended_performance_service_level.peak_iops=$AssignedServiceLevelPeakIops"
      [Bool]$isQuery = $True
   }
   If($Size){
      [String]$uri  += "&space.size=$Size"
      [Bool]$isQuery = $True
   }
   If($Query){
      [String]$uri  += "&query=$Query"
      [Bool]$isQuery = $True
   }
   If($Offset){
      [String]$uri += "&offset=$Offset"
   }
   If($OrderBy){
      [String]$uri += "&order_by=$OrderBy"
   }
   If($MaxRecords){
      [String]$uri += "&max_records=$MaxRecords"
   }
   If(-Not($isQuery)){
      [String]$uri = $uri.SubString(0, ($uri.Length -1))
   }Else{
      [String]$uri = $uri.Replace("?&", "?")
   }
   #'---------------------------------------------------------------------------
   #'Enumerate the LUNs.
   #'---------------------------------------------------------------------------
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers -ErrorAction Stop
      Write-Host "Enumerated LUNs on Server ""$Server"" using URI ""$uri"""
   }Catch{
      Write-Warning -Message $("Failed enumerating LUNs on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
   }
   Return $response;
}#'End Function Get-UMLun.
#'------------------------------------------------------------------------------
Function Get-UMLunID{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $False, HelpMessage = "The LUN resource key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$LunID,
      [Parameter(Mandatory = $True, HelpMessage = "The Credential to authenticate to AIQUM")]
      [ValidateNotNullOrEmpty()]
      [System.Management.Automation.PSCredential]$Credential
   )
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{"Authorization" = "Basic $auth"}
   #'---------------------------------------------------------------------------
   #'Enumerate the LUN
   #'---------------------------------------------------------------------------
   [String]$uri = "https://$Server/api/storage-provider/luns/$LunID"
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers -ErrorAction Stop
      Write-Host "Enumerated LUN ID ""$LunID"" on Server ""$Server"" using URI ""$uri"""
   }Catch{
      Write-Warning -Message $("Failed enumerating LUN ID ""$LunID"" on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
   }
   Return $response;
}#'End Function Get-UMLunID.
#'------------------------------------------------------------------------------
Function Remove-UMLun{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $False, HelpMessage = "The LUN resource key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$LunID,
      [Parameter(Mandatory = $False, HelpMessage = "The LUN Path")]
      [String]$LunPath,
      [Parameter(Mandatory = $False, HelpMessage = "The Vserver Name")]
      [String]$VserverName,
      [Parameter(Mandatory = $False, HelpMessage = "The Cluster Name")]
      [String]$ClusterName,
      [Parameter(Mandatory = $True, HelpMessage = "The Credential to authenticate to AIQUM")]
      [ValidateNotNullOrEmpty()]
      [System.Management.Automation.PSCredential]$Credential
   )
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{
      "Authorization" = "Basic $auth"
      "Accept"        = "application/json"
      "Content-Type"  = "application/json"
   }
   #'---------------------------------------------------------------------------
   #'Enumerate the LUN Resource key if not provided.
   #'---------------------------------------------------------------------------
   If((-Not($LunID)) -And $VserverName -And $ClusterName){
      [String]$command = "Get-UMObjectID -Server $Server -ObjectType 'lun' -ObjectName $LunPath -VserverName $VserverName -ClusterName $ClusterName -Credential `$Credential -ErrorAction Stop"
      Try{
         [String]$LunID = Invoke-Expression -Command $command -ErrorAction Stop
         Write-Host "Executed Command`: $command" -ForegroundColor Cyan
      }Catch{
         Write-Warning -Message $("Failed Executing Command`: $command. Error " + $_.Exception.Message)
         Return $Null;
      }
      If([String]::IsNullOrEmpty($LunID)){
         Write-Warning -Message "Failed enumerating LUN ""$LunPath"" on Vserver ""$VserverName"" on Cluster ""$ClusterName"""
         Return $Null;
      }
   }Else{
      Write-Warning -Message "The 'LunPath', 'VserverName' and 'ClusterName' parameters must be provided if the 'LunID' is not specified"
      Return $Null;
   }
   #'---------------------------------------------------------------------------
   #'Remove the LUN.
   #'---------------------------------------------------------------------------
   [String]$uri = "https://$Server/api/storage-provider/luns/$LunID"
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method DELETE -Headers $headers -ErrorAction Stop
      Write-Host "Deleted LUN ID ""$LunID"" on Server ""$Server"" using URI ""$uri"""
   }Catch{
      Write-Warning -Message $("Failed deleting LUN ID ""$LunID"" on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
   }
   Return $response;
}#'End Function Remove-UMLun.
#'------------------------------------------------------------------------------
Function New-UMLun{
   [CmdletBinding()]
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
      [Parameter(Mandatory = $False, HelpMessage = "The Performance Service Name")]
      [String]$ServiceLevelName,
      [Parameter(Mandatory = $False, HelpMessage = "The Storage Efficiency Policy resource key. The syntax is: '<uuid>'")]
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
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{
      "Authorization" = "Basic $auth"
      "Accept"        = "application/json"
      "Content-Type"  = "application/json"
   }
   #'---------------------------------------------------------------------------
   #'Validate the input parameters.
   #'---------------------------------------------------------------------------
   If(-Not($ServiceLevelID)){
      If(-Not($ServiceLevelName)){
         Write-Warning -Message "The 'ServiceLevelName' parameter parameter must be provided if the 'ServiceLevelID' parameter is not specified"
         Return $Null;
      }
   }
   If(-Not($VserverID)){
      If((-Not($VserverName)) -And (-Not($ClusterName))){
         Write-Warning -Message "The 'VserverName' and 'ClusterName' parameters must be provided if the 'VserverID' parameter is not specified"
         Return $Null;
      }
   }
   #'---------------------------------------------------------------------------
   #'Enumerate the Serivce Level Resource key if not provided.
   #'---------------------------------------------------------------------------
   If(-Not($ServiceLevelID)){
      [String]$command = "Get-UMObjectID -Server $Server -ObjectType 'service-level' -ObjectName $ServiceLevelName -Credential `$Credential -ErrorAction Stop"
      Try{
         [String]$ServiceLevelID = Invoke-Expression -Command $command -ErrorAction Stop
         Write-Host "Executed Command`: $command" -ForegroundColor Cyan
      }Catch{
         Write-Warning -Message $("Failed Executing Command`: $command. Error " + $_.Exception.Message)
         Return $Null;
      }
      If([String]::IsNullOrEmpty($ServiceLevelID)){
         Write-Warning -Message "Failed enumerating Performance Service Level ""$ServiceLevelName"""
         Return $Null;
      }
   }
   #'---------------------------------------------------------------------------
   #'Enumerate the Vserver Resource key if not provided.
   #'---------------------------------------------------------------------------
   If((-Not($VserverID)) -And $VserverName -And $ClusterName){
      [String]$command = "Get-UMObjectID -Server $Server -ObjectType 'vserver' -ObjectName $VserverName -ClusterName $ClusterName -Credential `$Credential -ErrorAction Stop"
      Try{
         [String]$VserverID = Invoke-Expression -Command $command -ErrorAction Stop
         Write-Host "Executed Command`: $command" -ForegroundColor Cyan
      }Catch{
         Write-Warning -Message $("Failed Executing Command`: $command. Error " + $_.Exception.Message)
         Return $Null;
      }
      If([String]::IsNullOrEmpty($VserverID)){
         Write-Warning -Message "Failed enumerating Vserver ""$VserverName"" on cluster ""$ClusterName"""
         Return $Null;
      }
   }
   #'---------------------------------------------------------------------------
   #'Enumerate the IGroup Resource key if not provided.
   #'---------------------------------------------------------------------------
   If((-Not($IGroupID)) -And $IGroupName -And $VserverName -And $ClusterName){
      [String]$command = "Get-UMObjectID -Server $Server -ObjectType 'igroup' -ObjectName $IGroupName -VserverName $VserverName -ClusterName $ClusterName -Credential `$Credential -ErrorAction Stop"
      Try{
         [String]$IGroupID = Invoke-Expression -Command $command -ErrorAction Stop
         Write-Host "Executed Command`: $command" -ForegroundColor Cyan
      }Catch{
         Write-Warning -Message $("Failed Executing Command`: $command. Error " + $_.Exception.Message)
         Return $Null;
      }
      If([String]::IsNullOrEmpty($IGroupID)){
         Write-Warning -Message "Failed enumerating Vserver ""$VserverName"" on cluster ""$ClusterName"""
         Return $Null;
      }
   }
   #'---------------------------------------------------------------------------
   #'Enumerate the Storage Efficency Policy Resource key if not provided.
   #'---------------------------------------------------------------------------
   If((-Not($EfficiencyPolicyID)) -And $EfficiencyPolicyName){
      [String]$command = "Get-UMObjectID -Server $Server -ObjectType 'efficiency-policy' -ObjectName $EfficiencyPolicyName -Credential `$Credential -ErrorAction Stop"
      Try{
         [String]$EfficiencyPolicyID = Invoke-Expression -Command $command -ErrorAction Stop
         Write-Host "Executed Command`: $command" -ForegroundColor Cyan
      }Catch{
         Write-Warning -Message $("Failed Executing Command`: $command. Error " + $_.Exception.Message)
         Return $Null;
      }
      If([String]::IsNullOrEmpty($EfficiencyPolicyID)){
         Write-Warning -Message "Failed enumerating ID for Storage EfficiencyPolicy ""$EfficiencyPolicyName"""
         Return $Null;
      }
   }
   #'---------------------------------------------------------------------------
   #'Create a hashtable for the body and covert to JSON.
   #'---------------------------------------------------------------------------
   [String]$uri    = "https://$Server/api/storage-provider/luns"
   [HashTable]$lun = @{};
   If($AggregateID){
      [HashTable]$aggregate = @{"key" = $AggregateID}
      [HashTable]$lun.Add("aggregate", $aggregate)
   }
   If($IGroupID){
      [Array]$mapping    = @();
      [HashTable]$igroup = @{"key" = $IGroupID}
      [HashTable]$map    = @{"igroup" = $igroup}
      If($ID){
         [HashTable]$map.Add("logical_unit_number", $ID)
      }
      [Array]$mapping += $map
      [HashTable]$lun.Add("lun_maps", $mapping)
   }
   [HashTable]$lun.Add("name", $LunName)
   [HashTable]$lun.Add("os_type", $OsType)
   [HashTable]$serviceLevel = @{"key" = $ServiceLevelID}
   [HashTable]$lun.Add("performance_service_level", $serviceLevel)
   [HashTable]$space = @{"size" = $($SizeGB * (1024 * 1024 * 1024))}
   [HashTable]$lun.Add("space", $space)
   If($EfficiencyPolicyID){
      [HashTable]$policy = @{"key" = $EfficiencyPolicyID}
      [HashTable]$lun.Add("storage_efficiency_policy", $policy)
   }
   [HashTable]$vserver = @{"key" = $VserverID}
   [HashTable]$lun.Add("svm", $vserver)
   If($VolumeID){
      [HashTable]$volume = @{"key" = $VolumeID}
      [HashTable]$lun.Add("volume", $volume)
   }Else{
      If($VolumeID -And $VolumeName){
         [HashTable]$volume = @{"key" = $VolumeID}
         [HashTable]$volume.Add("name_tag", $VolumeName)
         [HashTable]$lun.Add("volume", $volume)
      }
   }
   $body = $lun | ConvertTo-Json -Depth 3
   #'---------------------------------------------------------------------------
   #'Create the LUN.
   #'---------------------------------------------------------------------------
   [String]$message += "LUN ""$LunName"" of size ""$SizeGB`GB"" of OS Type ""$OsType"" on VserverID ""$VserverID"" of Performance Service Level ""$ServiceLevelID"" "
   If($VolumeID){
      [String]$message += "on volume ID ""$VolumeID"" "
   }
   If($AggregateID){
      [String]$message += "on Aggregate ID ""$AggregateID"" "
   }
   If($EfficiencyPolicyID){
      [String]$message += "with Efficency Policy ID ""$EfficiencyPolicyID"" "
   }
   [String]$message += "on Server ""$Server"" using URI ""$uri"""
   Try{
      $job = Invoke-RestMethod -Uri $uri -Method POST -Body $body -Headers $headers -ErrorAction Stop
      Write-Host $("Created " + $message)
   }Catch{
      Write-Warning -Message $("Failed creating " + $message + ". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
   }
   #'---------------------------------------------------------------------------
   #'Wait for the LUN creation Job to complete.
   #'---------------------------------------------------------------------------
   If($Null -eq $Job){
      Write-Warning -Message "Failed creating $message"
      Return $Null;
   }
   [String]$command = "Wait-UMJobID -Server $Server -JobID """ + $job.job.key + """ -Credential `$Credential -ErrorAction Stop"
   Try{
      $jobComplete = Invoke-Expression -Command $command -ErrorAction Stop
      Write-Host "Executed Command`: $command"
   }Catch{
      Write-Warning -Message $("Failed Executing command`: $command. Error " + $_.Exception.Message)
   }
   If(-Not($jobComplete)){
      Write-Warning $("Failed waiting for job """ + $job.job.key + """ on server ""$Server""")
      Return $job;
   }
   #'---------------------------------------------------------------------------
   #'Enumerate the completed LUN creation Job.
   #'---------------------------------------------------------------------------
   [String]$command = "Get-UMJobID -Server $Server -JobID """ + $job.job.key + """ -Credential `$Credential -ErrorAction Stop"
   Try{
      $j = Invoke-Expression -Command $command -ErrorAction Stop
      Write-Host "Executed Command`: $command"
   }Catch{
      Write-Warning -Message $("Failed Executing command`: $command. Error " + $_.Exception.Message)
      Return $j;
   }
   If($VolumeName -And $ClusterName -And (-Not($VolumeID))){
      [String]$id = $j.job_results | Where-Object {$_.name -eq "volumeKey"} | Select-Object -ExpandProperty value
      If([String]::IsNullOrEmpty($id)){
         Write-Warning -Message $("Failed Enumerating Volume ID from Job ID """ + $j.key + """")
         Return $j;
      }
      If(-Not($id.Contains("="))){
         Write-Warning -Message $("The Volume ID ""$id"" is invalid in Job ID """ + $j.key + """")
         Return $j;
      }
      [String]$uuid    = $id.SubString($id.LastIndexOf("=") + 1)
      [String]$command = "Rename-UMVolume -Server $Server -VolumeUuid ""$uuid"" -NewVolumeName ""$VolumeName"" -ClusterName $ClusterName -Credential `$Credential -ErrorAction Stop"
      Try{
         $rj = Invoke-Expression -Command $command -ErrorAction Stop
         Write-Host "Executed Command`: $command"
      }Catch{
         Write-Warning -Message $("Failed Executing command`: $command. Error " + $_.Exception.Message)
         Return $j;
      }
      If($Null -eq $rj){
         Write-Warning -Message "Failed renaming Volume ID ""$id"" to ""$VolumeName"""
         Return $j;
      }
   }
   Return $j;
}#'End Function New-UMLun.
#'------------------------------------------------------------------------------
Function Get-UMEventID{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $False, HelpMessage = "The Event ID")]
      [Int]$EventID,
      [Parameter(Mandatory = $True, HelpMessage = "The Credential to authenticate to AIQUM")]
      [ValidateNotNullOrEmpty()]
      [System.Management.Automation.PSCredential]$Credential
   )
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{"Authorization" = "Basic $auth"}
   #'---------------------------------------------------------------------------
   #'Enumerate the Event ID.
   #'---------------------------------------------------------------------------
   [String]$uri = "https://$Server/api/management-server/events/$EventID"
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers -ErrorAction Stop
      Write-Host "Enumerated Event ""$EventID"" on Server ""$Server"" using URI ""$uri"""
   }Catch{
      Write-Warning -Message $("Failed enumerating Event ""$EventID"" on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
   }
   If($Null -eq $response.EventList.Event.'object-id'){
      Write-Warning -Message "The Event ""$EventID"" was not found"
      Return $Null;
   }Else{
      Return $response.EventList.Event;
   }
}#'End Function Get-UMEventID.
#'------------------------------------------------------------------------------
Function Set-UMEventID{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $True, HelpMessage = "The Event ID Number")]
      [Int]$EventID,
      [Parameter(Mandatory = $False, HelpMessage = "The Event State")]
      [ValidateSet("resolved","acknowledged")]
      [String]$State,
      [Parameter(Mandatory = $False, HelpMessage = "The Username to assign the event to")]
      [String]$Username,
      [Parameter(Mandatory = $False, HelpMessage = "The Note to add to the event")]
      [String]$Note,
      [Parameter(Mandatory = $True, HelpMessage = "The Credential to authenticate to AIQUM")]
      [ValidateNotNullOrEmpty()]
      [System.Management.Automation.PSCredential]$Credential
   )
   #'---------------------------------------------------------------------------
   #'Validate the input parameters.
   #'---------------------------------------------------------------------------
   If($Note -And ($Username -Or $State)){
      Write-Warning -Message "The 'State' and 'Username' parameters must not be provided with the 'Note' parameter"
      Return $Null;
   }
   If((-Not($State)) -And (-Not($Username)) -And (-Not($Note))){
      Write-Warning -Message "Please provide the 'State', 'Username' or 'Note' parameter"
      Return $Null;
   }
   If($State -And $Username){
      Write-Warning -Message "The 'State' and 'Username' parameters can not both be provided"
      Return $Null;
   }
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{"Authorization" = "Basic $auth"}
   #'---------------------------------------------------------------------------
   #'Ensure the Event ID exists.
   #'---------------------------------------------------------------------------
   [String]$uri = "https://$Server/api/management-server/events/$EventID"
   Try{
      $event = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers -ErrorAction Stop
   }Catch{
      Write-Warning -Message $("Failed enumerating Event ""$EventID"" on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
      Return $Null;
   }
   If($Null -eq $event.EventList.Event.'object-id'){
      Write-Warning -Message "The Event ""$EventID"" was not found"
      Return $Null;
   }Else{
      Write-Host "Enumerated Event ID ""$EventID"" on Server ""$Server"" using URI ""$uri"""
   }
   If($Note -And ($event.EventList.Event.State -eq "resolved")){
      Write-Warning -Message "The Event ID ""$EventID"" has already been resolved. You cannot add a note to a resolved event"
      Return $Null;
   }
   #'---------------------------------------------------------------------------
   #'Set the header content type based on the action (assign, state or note).
   #'---------------------------------------------------------------------------
   If($Username){
      $headers.Add("Content-Type", "application/vnd.netapp.object.event.assign.hal+json")
   }
   If($State){
      $headers.Add("Content-Type", "application/vnd.netapp.object.event.statechange.hal+json")
   }
   If($Note){
      $headers.Add("Content-Type", "application/vnd.netapp.object.event.addnote.hal+json")
   }
   $headers.Add("Accept", "application/json")
   #'---------------------------------------------------------------------------
   #'Set the event URI. Create a hashtable for the body and covert to JSON.
   #'---------------------------------------------------------------------------
   [String]$uri      = "https://$Server/api/management-server/events?id=$EventID"
   [HashTable]$event = @{"id" = $EventID};
   If($State){
      [HashTable]$event.Add("state", $State.ToUpper())
      [String]$message = "Set state to ""$State"" for Event ID ""$EventID"" on Server ""$Server"" using URI ""$uri"""
   }
   If($Username){
      [HashTable]$event.Add("userId", $Username)
      [String]$message = "Assigned user ""$Username"" to Event ID ""$EventID"" on Server ""$Server"" using URI ""$uri"""
   }
   If($Note){
      [HashTable]$event.Add("note", $Note)
      [String]$message = "Added note ""$Note"" to Event ID ""$EventID"" on Server ""$Server"" using URI ""$uri"""
   }
   $body = $event | ConvertTo-Json
   #'---------------------------------------------------------------------------
   #'Set the Event state.
   #'---------------------------------------------------------------------------
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method PATCH -Body $body -Headers $headers -ErrorAction Stop
      Write-Host $Message
   }Catch{
      [String]$message = $(($message.Replace("Set state", "setting state").Replace("Assigned user", "assigning user").Replace("Added note", "adding note")))
      Write-Warning -Message $("Failed " + $message + ". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
      Return $False;
   }
   Return $True;
}#'End Function Set-UMEventID.
#'------------------------------------------------------------------------------
Function Get-UMVolume{
   [CmdletBinding()]
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
      [Parameter(Mandatory = $False, HelpMessage = "The Volume Style")]
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
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{"Authorization" = "Basic $auth"}
   #'---------------------------------------------------------------------------
   #'Set the URI to enumerate the clusters.
   #'---------------------------------------------------------------------------
   [String]$uri = "https://$Server/api/datacenter/storage/volumes?"
   [Bool]$query = $False;
   If($VolumeID){
      [String]$uri += "&key=$VolumeID"
      [Bool]$query = $True
   }
   If($VolumeType){
      [String]$uri += "&type=$VolumeType"
      [Bool]$query = $True
   }
   If($VolumeName){
      [String]$uri += "&name=$VolumeName"
      [Bool]$query = $True
   }
   If($SpaceAvailableGB){
      [String]$uri += $("&space.available=" + ($SpaceAvailableGB * (1024 * 1024 * 1024)))
      [Bool]$query = $True
   }
   If($SpaceUsedGB){
      [String]$uri += $("&space.used=" + ($SpaceUsedGB * (1024 * 1024 * 1024)))
      [Bool]$query = $True
   }
   If($AutosizeMode){
      [String]$uri += "&autosize.mode=$AutosizeMode"
      [Bool]$query = $True
   }
   If($AutosizeMaximumGB){
      [String]$uri += $("&autosize.maximum=" + ($AutosizeMaximumGB * (1024 * 1024 * 1024)))
      [Bool]$query = $True
   }
   If($DateCreated){
      $createTime = Get-Date -Date $DateCreated -Format "yyyy-MM-ddTHH:mm:ss.fffZ"
      [String]$uri += $("&create_time=" + ($createTime.ToString()))
      [Bool]$query = $True
   }
   If($State){
      [String]$uri += "&state=$State"
      [Bool]$query = $True
   }
   If($Style){
      [String]$uri += "&style=$Style"
      [Bool]$query = $True
   }
   If($VolumeUuid){
      [String]$uri += "&uuid=$VolumeUuid"
      [Bool]$query = $True
   }
   If($ClusterID){
      [String]$uri += "&cluster.key=$ClusterID"
      [Bool]$query = $True
   }
   If($ClusterName){
      [String]$uri += "&cluster.name=$ClusterName"
      [Bool]$query = $True
   }
   If($ClusterUuid){
      [String]$uri += "&cluster.uuid=$ClusterUuid"
      [Bool]$query = $True
   }
   If($VserverID){
      [String]$uri += "&svm.key=$VserverID"
      [Bool]$query = $True
   }
   If($VserverName){
      [String]$uri += "&svm.name=$VserverName"
      [Bool]$query = $True
   }
   If($VserverUuid){
      [String]$uri += "&svm.uuid=$VserverUuid"
      [Bool]$query = $True
   }
   If($AggregateID){
      [String]$uri += "&aggregate.key=$AggregateID"
      [Bool]$query = $True
   }
   If($AggregateName){
      [String]$uri += "&aggregate.name=$AggregateName"
      [Bool]$query = $True
   }
   If($AggregateUuid){
      [String]$uri += "&aggregate.uuid=$AggregateUuid"
      [Bool]$query = $True
   }
   If($Offset){
      [String]$uri += "&offset=$Offset"
   }
   If($OrderBy){
      [String]$uri += "&order_by=$OrderBy"
   }
   If($MaxRecords){
      [String]$uri += "&max_records=$MaxRecords"
   }
   If(-Not($query)){
      [String]$uri = $uri.SubString(0, ($uri.Length -1))
   }Else{
      [String]$uri = $uri.Replace("?&", "?")
   }
   #'---------------------------------------------------------------------------
   #'Enumerate the Volumes.
   #'---------------------------------------------------------------------------
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers -ErrorAction Stop
      Write-Host "Enumerated Volumes on Server ""$Server"" using URI ""$uri"""
   }Catch{
      Write-Warning -Message $("Failed enumerating Volumes on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
   }
   Return $response;
}#'End Function Get-UMVolume.
#'------------------------------------------------------------------------------
Function Get-UMVolumeID{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $True, HelpMessage = "The Volume Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$VolumeID,
      [Parameter(Mandatory = $True, HelpMessage = "The Credential to authenticate to AIQUM")]
      [ValidateNotNullOrEmpty()]
      [System.Management.Automation.PSCredential]$Credential
   )
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{"Authorization" = "Basic $auth"}
   #'---------------------------------------------------------------------------
   #'Enumerate the Volume.
   #'---------------------------------------------------------------------------
   [String]$uri = "https://$Server/api/datacenter/storage/volumes/$VolumeID"
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers -ErrorAction Stop
      Write-Host "Enumerated Volume on Server ""$Server"" using URI ""$uri"""
   }Catch{
      Write-Warning -Message $("Failed enumerating Volume on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
   }
   Return $response;
}#'End Function Get-UMVolumeID.
#'------------------------------------------------------------------------------
Function Rename-UMVolume{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $False, HelpMessage = "The Volume UUID")]
      [String]$VolumeUuid,
      [Parameter(Mandatory = $False, HelpMessage = "The Volume Name")]
      [String]$VolumeName,
      [Parameter(Mandatory = $True, HelpMessage = "The New Volume Name")]
      [String]$NewVolumeName,
      [Parameter(Mandatory = $False, HelpMessage = "The Vserver Name")]
      [String]$VserverName,
      [Parameter(Mandatory = $False, HelpMessage = "The Cluster UUID")]
      [String]$ClusterUuid,
      [Parameter(Mandatory = $False, HelpMessage = "The Cluster Name")]
      [String]$ClusterName,
      [Parameter(Mandatory = $True, HelpMessage = "The Credential to authenticate to AIQUM")]
      [ValidateNotNullOrEmpty()]
      [System.Management.Automation.PSCredential]$Credential
   )
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{
      "Authorization" = "Basic $auth"
      "Accept"        = "application/json"
      "Content-Type"  = "application/json"
   }
   #'---------------------------------------------------------------------------
   #'Validate input parameters.
   #'---------------------------------------------------------------------------
   If((-Not($ClusterUuid)) -And (-Not($ClusterName))){
      Write-Warning -Message "The 'ClusterUuid' or 'ClusterName' parameters must be provided"
      Return $Null;
   }
   If((-Not($VolumeUuid)) -And (-Not($ClusterName)) -And (-Not($VserverName)) -And (-Not($VolumeName))){
      Write-Warning -Message "The 'VolumeUuid' or 'VolumeName', 'VserverName' and 'ClusterName' parameters must be provided"
      Return $Null;
   }
   #'---------------------------------------------------------------------------
   #'Enumerate the cluster UUID if not provided.
   #'---------------------------------------------------------------------------
   If((-Not($ClusterUuid)) -And $ClusterName){
      [String]$command = "Get-UMDatasource -Server $Server -Credential `$Credential -ErrorAction Stop"
      Try{
         $dataSources = Invoke-Expression -Command $command -ErrorAction Stop
         Write-Host "Executed Command`: $command" -ForegroundColor Cyan
      }Catch{
         Write-Warning -Message $("Failed Executing Command`: $command. Error " + $_.Exception.Message)
         Return $Null;
      }
      If($Null -ne $dataSources){
         ForEach($dataSource In $dataSources.records){
            If($dataSource.name -eq $ClusterName){
               $ClusterUuid = $($dataSource.key).Split(":")[0]
            }
         }
      }
   }
   #'---------------------------------------------------------------------------
   #'Enumerate the volume UUID if not provided.
   #'---------------------------------------------------------------------------
   If((-Not($VolumeUuid)) -And $VolumeName -And $VserverName -And $ClusterName){
      [String]$command = "Get-UMVolume -Server $Server -VolumeName $VolumeName -VserverName $VserverName -ClusterName $ClusterName -Credential `$Credential -ErrorAction Stop"
      Try{
         $volume = Invoke-Expression -Command $command -ErrorAction Stop
         Write-Host "Executed Command`: $command" -ForegroundColor Cyan
      }Catch{
         Write-Warning -Message $("Failed Executing Command`: $command. Error " + $_.Exception.Message)
         Return $Null;
      }
      [String]$VolumeUuid = $volume.records.uuid
   }
   If(([String]::IsNullOrEmpty($ClusterUuid)) -Or ([String]::IsNullOrEmpty($VolumeUuid))){
      Write-Warning -Message "Failed enuerating volume and cluster UUID's"
      Return $Null;
   }
   [HashTable]$volume = @{"name" = $NewVolumeName}
   $body = $volume | ConvertTo-Json
   #'---------------------------------------------------------------------------
   #'Rename the Volume.
   #'---------------------------------------------------------------------------
   [String]$uri = "https://$Server/api/gateways/$ClusterUuid/storage/volumes/$VolumeUuid"
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method Patch -Body $body -Headers $headers -ErrorAction Stop
      Write-Host "Renamed Volume on Server ""$Server"" using URI ""$uri"""
   }Catch{
      Write-Warning -Message $("Failed renaming Volume on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
   }
   Return $response;
}#'End Function Rename-UMVolume.
#'------------------------------------------------------------------------------
Function Get-UMAggregate{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $False, HelpMessage = "The Aggregate Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$AggregateID,
      [Parameter(Mandatory = $False, HelpMessage = "The Aggregate UUID")]
      [String]$AggregateUuid,
      [Parameter(Mandatory = $False, HelpMessage = "The Aggregate Name")]
      [String]$AggregateName,
      [Parameter(Mandatory = $False, HelpMessage = "The Aggregate State")]
      [ValidateSet("online","offline")]
      [String]$State,
      [Parameter(Mandatory = $False, HelpMessage = "The Aggregate Efficiency Logical Used Space in GigaBytes")]
      [Int]$LogicalUsedGB,
      [Parameter(Mandatory = $False, HelpMessage = "The Aggregate Efficiency Savings in GigaBytes")]
      [Int]$SavingsGB,
      [Parameter(Mandatory = $False, HelpMessage = "The Aggregate Space Block Storage Size in GigaBytes")]
      [Int]$SizeGB,
      [Parameter(Mandatory = $False, HelpMessage = "The Aggregate Space Block Storage Available Size in GigaBytes")]
      [Int]$AvailableGB,
      [Parameter(Mandatory = $False, HelpMessage = "The Aggregate Space Block Storage Used Size in GigaBytes")]
      [Int]$UsedGB,
      [Parameter(Mandatory = $False, HelpMessage = "The Aggregate Data Encryption Software Encryption Enabled Status")]
      [ValidateSet("true","false")]
      [String]$EncryptionEnabled,
      [Parameter(Mandatory = $False, HelpMessage = "The Aggregate Type")]
      [String]$SnaplockType,
      [Parameter(Mandatory = $False, HelpMessage = "The Aggregate Type")]
      [String]$AggregateType,
      [Parameter(Mandatory = $False, HelpMessage = "The Aggregate creation Date")]
      [DateTime]$DateCreated,
      [Parameter(Mandatory = $False, HelpMessage = "The Aggregate Block Storage Primary Raid Size")]
      [Int64]$RaidSize,
      [Parameter(Mandatory = $False, HelpMessage = "The Aggregate Block Storage Primary Raid Type")]
      [String]$RaidType,
      [Parameter(Mandatory = $False, HelpMessage = "The Aggregate Block Storage Mirror State")]
      [String]$MirrorState,
      [Parameter(Mandatory = $False, HelpMessage = "The Aggregate Block Storage Mirror Enabled Status")]
      [ValidateSet("true","false")]
      [String]$MirrorEnabled,
      [Parameter(Mandatory = $False, HelpMessage = "The Aggregate Block Storage Hybrid Cache Enabled Status")]
      [ValidateSet("true","false")]
      [String]$HybridCacheEnabled,
      [Parameter(Mandatory = $False, HelpMessage = "The Aggregate Block Storage Hybrid Cache Size in GigaBytes")]
      [Int]$HybridCacheSizeGB,
      [Parameter(Mandatory = $False, HelpMessage = "The Cluster Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$ClusterID,
      [Parameter(Mandatory = $False, HelpMessage = "The Cluster name")]
      [String]$ClusterName,
      [Parameter(Mandatory = $False, HelpMessage = "The Cluster UUID")]
      [String]$ClusterUuid,
      [Parameter(Mandatory = $False, HelpMessage = "The Node Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$NodeID,
      [Parameter(Mandatory = $False, HelpMessage = "The Node name")]
      [String]$NodeName,
      [Parameter(Mandatory = $False, HelpMessage = "The Node UUID")]
      [String]$NodeUuid,
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
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{"Authorization" = "Basic $auth"}
   #'---------------------------------------------------------------------------
   #'Set the URI to enumerate the aggregates.
   #'---------------------------------------------------------------------------
   [String]$uri = "https://$Server/api/datacenter/storage/aggregates?"
   [Bool]$query = $False;
   If($AggregateID){
      [String]$uri += "&key=$AggregateID"
      [Bool]$query = $True
   }
   If($AggregateUuid){
      [String]$uri += "&uuid=$AggregateUuid"
      [Bool]$query = $True
   }
   If($AggregateName){
      [String]$uri += "&name=$AggregateName"
      [Bool]$query = $True
   }
   If($State){
      [String]$uri += "&state=$State"
      [Bool]$query = $True
   }
   If($LogicalUsedGB){
      [String]$uri += $("&space.efficiency.logical_used=" + ($LogicalUsedGB * (1024 * 1024 * 1024)))
      [Bool]$query = $True
   }
   If($SavingsGB){
      [String]$uri += $("&space.efficiency.savings=" + ($SavingsGB * (1024 * 1024 * 1024)))
      [Bool]$query = $True
   }
   If($SizeGB){
      [String]$uri += $("&space.block_storage.size=" + ($SizeGB * (1024 * 1024 * 1024)))
      [Bool]$query = $True
   }
   If($AvailableGB){
      [String]$uri += $("&space.block_storage.available=" + ($AvailableGB * (1024 * 1024 * 1024)))
      [Bool]$query = $True
   }
   If($UsedGB){
      [String]$uri += $("&space.block_storage.used=" + ($UsedGB * (1024 * 1024 * 1024)))
      [Bool]$query = $True
   }
   If($EncryptionEnabled){
      [String]$uri += "&data_encryption.software_encryption_enabled=$EncryptionEnabled"
      [Bool]$query = $True
   }
   If($SnaplockType){
      [String]$uri += "&snaplock_type=$SnaplockType"
      [Bool]$query = $True
   }
   If($AggregateType){
      [String]$uri += "&type=$AggregateType"
      [Bool]$query = $True
   }
   If($DateCreated){
      $createTime = Get-Date -Date $DateCreated -Format "yyyy-MM-ddTHH:mm:ss.fffZ"
      [String]$uri += $("&create_time=" + ($createTime.ToString()))
      [Bool]$query = $True
   }
   If($RaidSize){
      [String]$uri += "&block_storage.primary.raid_size=$RaidSize"
      [Bool]$query = $True
   }
   If($RaidType){
      [String]$uri += "&block_storage.primary.raid_type=$RaidType"
      [Bool]$query = $True
   }
   If($MirrorState){
      [String]$uri += "&block_storage.mirror.state=$MirrorState"
      [Bool]$query = $True
   }
   If($MirrorEnabled){
      [String]$uri += "&block_storage.mirror.enabled=$MirrorEnabled"
      [Bool]$query = $True
   }
   If($HybridCacheEnabled){
      [String]$uri += "&block_storage.hybrid_cache.enabled=$HybridCacheEnabled"
      [Bool]$query = $True
   }
   If($HybridCacheSizeGB){
      [String]$uri += $("&block_storage.hybrid_cache.size=" + ($HybridCacheSizeGB * (1024 * 1024 * 1024)))
      [Bool]$query = $True
   }
   If($ClusterID){
      [String]$uri += "&cluster.key=$ClusterID"
      [Bool]$query = $True
   }
   If($ClusterName){
      [String]$uri += "&cluster.name=$ClusterName"
      [Bool]$query = $True
   }
   If($ClusterUuid){
      [String]$uri += "&cluster.uuid=$ClusterUuid"
      [Bool]$query = $True
   }
   If($NodeID){
      [String]$uri += "&node.key=$NodeID"
      [Bool]$query = $True
   }
   If($NodeName){
      [String]$uri += "&node.name=$NodeName"
      [Bool]$query = $True
   }
   If($NodeUuid){
      [String]$uri += "&node.uuid=$NodeUuid"
      [Bool]$query = $True
   }
   If($Offset){
      [String]$uri += "&offset=$Offset"
   }
   If($OrderBy){
      [String]$uri += "&order_by=$OrderBy"
   }
   If($MaxRecords){
      [String]$uri += "&max_records=$MaxRecords"
   }
   If(-Not($query)){
      [String]$uri = $uri.SubString(0, ($uri.Length -1))
   }Else{
      [String]$uri = $uri.Replace("?&", "?")
   }
   #'---------------------------------------------------------------------------
   #'Enumerate the Aggregates.
   #'---------------------------------------------------------------------------
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers -ErrorAction Stop
      Write-Host "Enumerated Aggregates on Server ""$Server"" using URI ""$uri"""
   }Catch{
      Write-Warning -Message $("Failed enumerating Aggregates on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
   }
   Return $response;
}#'End Function Get-UMAggregate.
#'------------------------------------------------------------------------------
Function Get-UMAggregateID{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $False, HelpMessage = "The Aggregate Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$AggregateID,
      [Parameter(Mandatory = $True, HelpMessage = "The Credential to authenticate to AIQUM")]
      [ValidateNotNullOrEmpty()]
      [System.Management.Automation.PSCredential]$Credential
   )
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{"Authorization" = "Basic $auth"}
   #'---------------------------------------------------------------------------
   #'Enumerate the Aggregate.
   #'---------------------------------------------------------------------------
   [String]$uri = "https://$Server/api/datacenter/storage/aggregates/$AggregateID"
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers -ErrorAction Stop
      Write-Host "Enumerated Aggregate on Server ""$Server"" using URI ""$uri"""
   }Catch{
      Write-Warning -Message $("Failed enumerating Aggregate on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
   }
   Return $response;
}#'End Function Get-UMAggregateID.
#'------------------------------------------------------------------------------
Function Get-UMQoSPolicy{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $False, HelpMessage = "The QoS Policy Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$QoSPolicyID,
      [Parameter(Mandatory = $False, HelpMessage = "The QoS Policy UUID")]
      [String]$QoSPolicyUuid,
      [Parameter(Mandatory = $False, HelpMessage = "The QoS Policy Minimum IOPs")]
      [Int64]$MinimumIops,
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
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{"Authorization" = "Basic $auth"}
   #'---------------------------------------------------------------------------
   #'Set the URI to enumerate the QoS Policies.
   #'---------------------------------------------------------------------------
   [String]$uri = "https://$Server/api/datacenter/storage/qos/policies?"
   [Bool]$query = $False;
   If($QoSPolicyID){
      [String]$uri += "&key=$VolumeID"
      [Bool]$query = $True
   }
   If($QoSPolicyUuid){
      [String]$uri += "&uuid=$QoSPolicyUuid"
      [Bool]$query = $True
   }
   If($MinimumIops){
      [String]$uri += "&adaptive.absolute_min_iops=$MinimumIops"
      [Bool]$query = $True
   }
   If($ClusterID){
      [String]$uri += "&cluster.key=$ClusterID"
      [Bool]$query = $True
   }
   If($ClusterName){
      [String]$uri += "&cluster.name=$ClusterName"
      [Bool]$query = $True
   }
   If($ClusterUuid){
      [String]$uri += "&cluster.uuid=$ClusterUuid"
      [Bool]$query = $True
   }
   If($VserverID){
      [String]$uri += "&svm.key=$VserverID"
      [Bool]$query = $True
   }
   If($VserverName){
      [String]$uri += "&svm.name=$VserverName"
      [Bool]$query = $True
   }
   If($VserverUuid){
      [String]$uri += "&svm.uuid=$VserverUuid"
      [Bool]$query = $True
   }
   If($Offset){
      [String]$uri += "&offset=$Offset"
   }
   If($OrderBy){
      [String]$uri += "&order_by=$OrderBy"
   }
   If($MaxRecords){
      [String]$uri += "&max_records=$MaxRecords"
   }
   If(-Not($query)){
      [String]$uri = $uri.SubString(0, ($uri.Length -1))
   }Else{
      [String]$uri = $uri.Replace("?&", "?")
   }
   #'---------------------------------------------------------------------------
   #'Enumerate the QoS Policies.
   #'---------------------------------------------------------------------------
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers -ErrorAction Stop
      Write-Host "Enumerated QoS Policies on Server ""$Server"" using URI ""$uri"""
   }Catch{
      Write-Warning -Message $("Failed enumerating QoS Policies on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
   }
   Return $response;
}#'End Function Get-UMQoSPolicy.
#'------------------------------------------------------------------------------
Function Get-UMQoSPolicyID{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $True, HelpMessage = "The QoS Policy Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$QoSPolicyID,
      [Parameter(Mandatory = $True, HelpMessage = "The Credential to authenticate to AIQUM")]
      [ValidateNotNullOrEmpty()]
      [System.Management.Automation.PSCredential]$Credential
   )
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{"Authorization" = "Basic $auth"}
   #'---------------------------------------------------------------------------
   #'Enumerate the QoS Policy.
   #'---------------------------------------------------------------------------
   [String]$uri = "https://$Server/api/datacenter/storage/qos/policies/$PolicyID"
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers -ErrorAction Stop
      Write-Host "Enumerated QoS Policy on Server ""$Server"" using URI ""$uri"""
   }Catch{
      Write-Warning -Message $("Failed enumerating QoS Policy on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
   }
   Return $response;
}#'End Function Get-UMQoSPolicyID.
#'------------------------------------------------------------------------------
Function Get-UMQtree{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $False, HelpMessage = "The Qtree Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$QtreeId,
      [Parameter(Mandatory = $False, HelpMessage = "The Qtree Name")]
      [String]$QtreeName,
      [Parameter(Mandatory = $False, HelpMessage = "The Qtree UUID")]
      [String]$QtreeUuid,
      [Parameter(Mandatory = $False, HelpMessage = "The Qtree Security Style")]
      [ValidateSet("mixed","ntfs","unix")]
      [String]$SecurityStyle,
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
      [Parameter(Mandatory = $False, HelpMessage = "The Volume Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$VolumeID,
      [Parameter(Mandatory = $False, HelpMessage = "The Volume name")]
      [String]$VolumeName,
      [Parameter(Mandatory = $False, HelpMessage = "The Volume UUID")]
      [String]$VolumeUuid,
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
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{"Authorization" = "Basic $auth"}
   #'---------------------------------------------------------------------------
   #'Set the URI to enumerate the Qtrees
   #'---------------------------------------------------------------------------
   [String]$uri = "https://$Server/api/datacenter/storage/qtrees?"
   [Bool]$query = $False;
   If($QtreeID){
      [String]$uri += "&key=$QtreeID"
      [Bool]$query = $True
   }
   If($QtreeName){
      [String]$uri += "&name=$QtreeName"
      [Bool]$query = $True
   }
   If($QtreeUuid){
      [String]$uri += "&uuid=$QtreeUuid"
      [Bool]$query = $True
   }
   If($SecurityStyle){
      [String]$uri += "&security_style=$SecurityStyle"
      [Bool]$query = $True
   }
   If($ClusterID){
      [String]$uri += "&cluster.key=$ClusterID"
      [Bool]$query = $True
   }
   If($ClusterName){
      [String]$uri += "&cluster.name=$ClusterName"
      [Bool]$query = $True
   }
   If($ClusterUuid){
      [String]$uri += "&cluster.uuid=$ClusterUuid"
      [Bool]$query = $True
   }
   If($VserverID){
      [String]$uri += "&svm.key=$VserverID"
      [Bool]$query = $True
   }
   If($VserverName){
      [String]$uri += "&svm.name=$VserverName"
      [Bool]$query = $True
   }
   If($VserverUuid){
      [String]$uri += "&svm.uuid=$VserverUuid"
      [Bool]$query = $True
   }
   If($VolumeID){
      [String]$uri += "&volume.key=$VserverID"
      [Bool]$query = $True
   }
   If($VolumeName){
      [String]$uri += "&volume.name=$VolumeName"
      [Bool]$query = $True
   }
   If($VolumeUuid){
      [String]$uri += "&volume.uuid=$VolumeUuid"
      [Bool]$query = $True
   }
   If($Offset){
      [String]$uri += "&offset=$Offset"
   }
   If($OrderBy){
      [String]$uri += "&order_by=$OrderBy"
   }
   If($MaxRecords){
      [String]$uri += "&max_records=$MaxRecords"
   }
   If(-Not($query)){
      [String]$uri = $uri.SubString(0, ($uri.Length -1))
   }Else{
      [String]$uri = $uri.Replace("?&", "?")
   }
   #'---------------------------------------------------------------------------
   #'Enumerate the Qtrees.
   #'---------------------------------------------------------------------------
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers -ErrorAction Stop
      Write-Host "Enumerated Qtrees on Server ""$Server"" using URI ""$uri"""
   }Catch{
      Write-Warning -Message $("Failed enumerating Qtrees on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
   }
   Return $response;
}#'End Function Get-UMQtree.
#'------------------------------------------------------------------------------
Function Get-UMQtreeID{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $True, HelpMessage = "The Qtree Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$QtreeID,
      [Parameter(Mandatory = $True, HelpMessage = "The Credential to authenticate to AIQUM")]
      [ValidateNotNullOrEmpty()]
      [System.Management.Automation.PSCredential]$Credential
   )
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{"Authorization" = "Basic $auth"}
   #'---------------------------------------------------------------------------
   #'Enumerate the Qtree.
   #'---------------------------------------------------------------------------
   [String]$uri = "https://$Server/api/datacenter/storage/qtrees/$QtreeID"
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers -ErrorAction Stop
      Write-Host "Enumerated Qtree on Server ""$Server"" using URI ""$uri"""
   }Catch{
      Write-Warning -Message $("Failed enumerating Qtree on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
   }
   Return $response;
}#'End Function Get-UMQtreeID.
#'------------------------------------------------------------------------------
Function Get-UMServiceLevel{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $False, HelpMessage = "The Service Level Resource Key. The syntax is: '<uuid>'")]
      [String]$ServiceLevelID,
      [Parameter(Mandatory = $False, HelpMessage = "The Service Level Name")]
      [String]$ServiceLevelName,
      [Parameter(Mandatory = $False, HelpMessage = "The Service Level Description")]
      [String]$Description,
      [Parameter(Mandatory = $False, HelpMessage = "The absolute minimum iops")]
      [Int64]$AbsoluteMinimumIops,
      [Parameter(Mandatory = $False, HelpMessage = "The expected iops per TeraByte")]
      [Int64]$ExpectedIopsTB,
      [Parameter(Mandatory = $False, HelpMessage = "The peak iops TeraByte")]
      [Int64]$PeakIopsTB,
      [Parameter(Mandatory = $False, HelpMessage = "The peak iops allocation policy name")]
      [ValidateSet("used_space","allocated_space")]
      [String]$PeakIopsAllocationPolicy,
      [Parameter(Mandatory = $False, HelpMessage = "The latency excepted")]
      [Float]$LatencyExcepted,
      [Parameter(Mandatory = $False, HelpMessage = "The System Defined configuration")]
      [ValidateSet("true","false")]
      [String]$SystemDefined,
      [Parameter(Mandatory = $False, HelpMessage = "The space used in GigaBytes")]
      [Int]$SpaceUsedGB,
      [Parameter(Mandatory = $False, HelpMessage = "The workload count")]
      [Int64]$WorkloadCount,
      [Parameter(Mandatory = $False, HelpMessage = "The Date created")]
      [DateTime]$DateCreated,
      [Parameter(Mandatory = $False, HelpMessage = "The Date updated")]
      [DateTime]$DateUpdated,
      [Parameter(Mandatory = $False, HelpMessage = "The Sort Order. Default is 'asc'")]
      [ValidateSet("asc","desc")]
      [String]$OrderBy,
      [Parameter(Mandatory = $True, HelpMessage = "The Credential to authenticate to AIQUM")]
      [ValidateNotNullOrEmpty()]
      [System.Management.Automation.PSCredential]$Credential
   )
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{"Authorization" = "Basic $auth"}
   #'---------------------------------------------------------------------------
   #'Set the URI to enumerate the Service Levels.
   #'---------------------------------------------------------------------------
   [String]$uri = "https://$Server/api/storage-provider/performance-service-levels?"
   [Bool]$query = $False;
   If($ServiceLevelID){
      [String]$uri += "&key=$ServiceLevelID"
      [Bool]$query = $True
   }
   If($ServiceLevelName){
      [String]$uri += "&name=$ServiceLevelName"
      [Bool]$query = $True
   }
   If($Description){
      [String]$uri += "&description=$Description"
      [Bool]$query = $True
   }
   If($AbsoluteMinimumIops){
      [String]$uri += "&iops.absolute_min_iops=$AbsoluteMinimumIops"
      [Bool]$query = $True
   }
   If($ExpectedIopsTB){
      [String]$uri += "&iops.expected_iops_per_tb=$ExpectedIopsTB"
      [Bool]$query = $True
   }
   If($PeakIopsTB){
      [String]$uri += "&iops.peak_iops_per_tb=$PeakIopsTB"
      [Bool]$query = $True
   }
   If($PeakIopsAllocationPolicy){
      [String]$uri += "&iops.peak_iops_allocation_policy=$PeakIopsAllocationPolicy"
      [Bool]$query = $True
   }
   If($LatencyExcepted){
      [String]$uri += "&latency.excepted=$LatencyExcepted"
      [Bool]$query = $True
   }
   If($SystemDefined){
      [String]$uri += "&system_defined=$SystemDefined"
      [Bool]$query = $True
   }
   If($SpaceUsedGB){
      [String]$uri += $("&space.used=" + $($SpaceUsedGB * (1024 * 1024 * 1024)))
      [Bool]$query = $True
   }
   If($WorkloadCount){
      [String]$uri += "&workload_count=$WorkloadCount"
      [Bool]$query = $True
   }
   If($DateCreated){
      $createTime   = Get-Date -Date $DateCreated -Format "yyyy-MM-ddTHH:mm:ss.fffZ"
      [String]$uri += $("&create_time=" + ($createTime.ToString()))
      [Bool]$query  = $True
   }
   If($DateUpdated){
      $updateTime   = Get-Date -Date $DateUpdated -Format "yyyy-MM-ddTHH:mm:ss.fffZ"
      [String]$uri += $("&update_time=" + ($updateTime.ToString()))
      [Bool]$query  = $True
   }
   If($OrderBy){
      [String]$uri += "&order_by=$OrderBy"
   }
   If(-Not($query)){
      [String]$uri = $uri.SubString(0, ($uri.Length -1))
   }Else{
      [String]$uri = $uri.Replace("?&", "?")
   }
   #'---------------------------------------------------------------------------
   #'Enumerate the Performance Service Levels.
   #'---------------------------------------------------------------------------
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers -ErrorAction Stop
      Write-Host "Enumerated Performance Service Levels on Server ""$Server"" using URI ""$uri"""
   }Catch{
      Write-Warning -Message $("Failed enumerating Performance Service Levels on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
   }
   Return $response;
}#'End Function Get-UMServiceLevel.
#'------------------------------------------------------------------------------
Function Get-UMServiceLevelID{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $False, HelpMessage = "The Service Level Resource Key. The syntax is: '<uuid>'")]
      [String]$ServiceLevelID,
      [Parameter(Mandatory = $True, HelpMessage = "The Credential to authenticate to AIQUM")]
      [ValidateNotNullOrEmpty()]
      [System.Management.Automation.PSCredential]$Credential
   )
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{"Authorization" = "Basic $auth"}
   #'---------------------------------------------------------------------------
   #'Enumerate the Performance Service Level.
   #'---------------------------------------------------------------------------
   [String]$uri = "https://$Server/api/storage-provider/performance-service-levels/$ServiceLevelID"
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers -ErrorAction Stop
      Write-Host "Enumerated Performance Service Level on Server ""$Server"" using URI ""$uri"""
   }Catch{
      Write-Warning -Message $("Failed enumerating Performance Service Level on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
   }
   Return $response;
}#'End Function Get-UMServiceLevelID.
#'------------------------------------------------------------------------------
Function Get-UMObjectMetrics{
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
   #'---------------------------------------------------------------------------
   #'Set the command to enumerate the object Resource key based on the object type.
   #'---------------------------------------------------------------------------
   Switch($ObjectType){
      "cluster"{
         [String]$endPoint = "/datacenter/cluster/clusters/$ObjectID/metrics"
      }
      "node"{
         [String]$endPoint = "/datacenter/cluster/nodes/$ObjectID/metrics"
      }
      "ethernet_port"{
         [String]$endPoint = "/datacenter/network/ethernet/ports/$ObjectID/metrics"
      }
      "fc_interface"{
         [String]$endPoint = "/datacenter/network/fc/interfaces/$ObjectID/metrics"
      }
      "fc_port"{
         [String]$endPoint = "/datacenter/network/fc/ports/$ObjectID/metrics"
      }
      "ip_interface"{
         [String]$endPoint = "/datacenter/network/ip/interfaces/$ObjectID/metrics"
      }
      "aggregate"{
         [String]$endPoint = "/datacenter/storage/aggregates/$ObjectID/metrics"
      }
      "lun"{
         [String]$endPoint = "/datacenter/storage/luns/$ObjectID/metrics"
      }
      "volume"{
         [String]$endPoint = "/datacenter/storage/volumes/$ObjectID/metrics"
      }
      "svm"{
         [String]$endPoint = "/datacenter/svm/svms/$ObjectID/metrics"
      }
      default {$endPoint = $Null}
   }
   [String]$uri = "https://$Server/api$endPoint"
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{"Authorization" = "Basic $auth"}
   #'---------------------------------------------------------------------------
   #'Enumerate the Object metrics.
   #'---------------------------------------------------------------------------
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers -ErrorAction Stop
      Write-Host "Enumerated Object metrics on Server ""$Server"" using URI ""$uri"""
   }Catch{
      Write-Warning -Message $("Failed enumerating Object metrics on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
   }
   Return $response;
}#'End Function Get-UMObjectMetrics.
#'------------------------------------------------------------------------------
Function Get-UMObjectID{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $True, HelpMessage = "The Object Type")]
      [ValidateSet("cluster","efficiency-policy","igroup","lun","qtree","volume","vserver","service-level")]
      [String]$ObjectType,
      [Parameter(Mandatory = $True, HelpMessage = "The Object Name")]
      [String]$ObjectName,
      [Parameter(Mandatory = $False, HelpMessage = "The Cluster Name")]
      [String]$ClusterName,
      [Parameter(Mandatory = $False, HelpMessage = "The Vserver Name")]
      [String]$VserverName,
      [Parameter(Mandatory = $False, HelpMessage = "The Volume Name")]
      [String]$VolumeName,
      [Parameter(Mandatory = $True, HelpMessage = "The Credential to authenticate to AIQUM")]
      [ValidateNotNullOrEmpty()]
      [System.Management.Automation.PSCredential]$Credential
   )
   #'---------------------------------------------------------------------------
   #'Set the command to enumerate the object Resource key based on the object type.
   #'---------------------------------------------------------------------------
   Switch($ObjectType){
      "cluster"{
         [String]$command = "Get-UMCluster -Server $Server -ClusterName $ObjectName -Credential `$Credential -ErrorAction Stop"
      }
      "efficiency-policy"{
         [String]$command = "Get-UMEfficiencyPolicy -Server $Server -PolicyName $ObjectName -Credential `$Credential -ErrorAction Stop"
      }
      "igroup"{
         If((-Not($VserverName)) -And (-Not($ClusterName))){
            Write-Warning -Message "The 'ClusterName' and 'VserverName' parameters must be provided when specifying the object type '$ObjectType'"
            Return $Null;
         }
         [String]$command = "Get-UMIgroup -Server $Server -IGroupName '$ObjectName' -ClusterName '$ClusterName' -VserverName '$VserverName' -Credential `$Credential -ErrorAction Stop"
      }
      "lun"{
         If((-Not($VserverName)) -And (-Not($ClusterName))){
            Write-Warning -Message "The 'ClusterName' and 'VserverName' parameters must be provided when specifying the object type '$ObjectType'"
            Return $Null;
         }
         [String]$command = "Get-UMLun -Server $Server -LunName '$ObjectName' -ClusterName '$ClusterName' -VserverName '$VserverName' -Credential `$Credential -ErrorAction Stop"
      }
      "qtree"{
         If((-Not($VserverName)) -And ((-Not($VolumeName))) -And (-Not($ClusterName))){
            Write-Warning -Message "The 'ClusterName', 'VserverName' and 'VolumeName' parameters must be provided when specifying the object type '$ObjectType'"
            Return $Null;
         }
         [String]$command = "Get-UMQtree -Server $Server -QtreeName '$ObjectName' -ClusterName '$ClusterName' -VserverName '$VserverName' -VolumeName '$VolumeName' -Credential `$Credential -ErrorAction Stop"
      }
      "volume"{
         If((-Not($VserverName)) -And (-Not($ClusterName))){
            Write-Warning -Message "The 'ClusterName' and 'VserverName' parameters must be provided when specifying the object type '$ObjectType'"
            Return $Null;
         }
         [String]$command = "Get-UMVolume -Server $Server -VolumeName '$ObjectName' -VserverName '$VserverName' -ClusterName '$ClusterName' -Credential `$Credential -ErrorAction Stop"
      }
      "vserver"{
         If(-Not($ClusterName)){
            Write-Warning -Message "The 'ClusterName' parameter must be provided when specifying the object type '$ObjectType'"
            Return $Null;
         }
         [String]$command = "Get-UMVserver -Server $Server -VserverName '$ObjectName' -ClusterName '$ClusterName' -Credential `$Credential -ErrorAction Stop"
      }
      "service-level"{
         [String]$command = "Get-UMServiceLevel -Server $Server -ServiceLevelName '$ObjectName' -Credential `$Credential -ErrorAction Stop"
      }
      default {$command = $Null}
   }
   If([String]::IsNullOrEmpty($command)){
      Write-Warning -Message "Invalid command attempting ot enumerate object type ""$ObjectType"""
      Return $Null;
   }
   #'---------------------------------------------------------------------------
   #'Enumerate the object Resource key.
   #'---------------------------------------------------------------------------
   Try{
      $response = Invoke-Expression -Command $command -ErrorAction Stop
      Write-Host "Executed Command`: $command" -ForegroundColor Cyan
   }Catch{
      Write-Warning -Message $("Failed Executing Command`: $command. Error " + $_.Exception.Message)
      Return $Null;
   }
   If($Null -ne $response){
      [String]$id = $response.records.key
   }
   If([String]::IsNullOrEmpty($id)){
      Write-Warning -Message "Failed enumerating $ObjectType ""$ObjectName"" on cluster ""$ClusterName"""
      Return $Null;
   }Else{
      Return $id;
   }
}#'End Function Get-UMObjectID.
#'------------------------------------------------------------------------------
Function Get-UMEfficiencyPolicy{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $False, HelpMessage = "The Storage Efficiency Policy Resource Key. The syntax is: '<uuid>'")]
      [String]$PolicyID,
      [Parameter(Mandatory = $False, HelpMessage = "The Storage Efficiency Policy name")]
      [String]$PolicyName,
      [Parameter(Mandatory = $False, HelpMessage = "The System Defined configuration")]
      [ValidateSet("true","false")]
      [String]$SystemDefined,
      [Parameter(Mandatory = $False, HelpMessage = "The Thin Provisioned configuration")]
      [ValidateSet("true","false")]
      [String]$ThinProvisioned,
      [Parameter(Mandatory = $False, HelpMessage = "The Workload Count")]
      [Int64]$WorkloadCount,
      [Parameter(Mandatory = $False, HelpMessage = "The Compression configuration")]
      [ValidateSet("inline","background","none")]
      [String]$Compression,
      [Parameter(Mandatory = $False, HelpMessage = "The Deduplication configuration")]
      [ValidateSet("inline","background","none")]
      [String]$Deduplication,
      [Parameter(Mandatory = $False, HelpMessage = "The Date Created")]
      [DateTime]$DateCreated,
      [Parameter(Mandatory = $False, HelpMessage = "The Date Updated")]
      [DateTime]$DateUpdated,
      [Parameter(Mandatory = $False, HelpMessage = "The Sort Order. Default is 'asc'")]
      [ValidateSet("asc","desc")]
      [String]$OrderBy,
      [Parameter(Mandatory = $True, HelpMessage = "The Credential to authenticate to AIQUM")]
      [ValidateNotNullOrEmpty()]
      [System.Management.Automation.PSCredential]$Credential
   )
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{"Authorization" = "Basic $auth"}
   #'---------------------------------------------------------------------------
   #'Set the URI to enumerate the Storage Efficiency Policies.
   #'---------------------------------------------------------------------------
   [String]$uri = "https://$Server/api/storage-provider/storage-efficiency-policies?"
   [Bool]$query = $False;
   If($PolicyID){
      [String]$uri += "&key=$PolicyID"
      [Bool]$query = $True
   }
   If($PolicyName){
      [String]$uri += "&name=$PolicyName"
      [Bool]$query = $True
   }
   If($SystemDefined){
      [String]$uri += "&system_defined=$SystemDefined"
      [Bool]$query = $True
   }
   If($ThinProvisioned){
      [String]$uri += "&space_thin_provisioned=$ThinProvisioned"
      [Bool]$query = $True
   }
   If($WorkloadCount){
      [String]$uri += "&workload_count=$WorkloadCount"
      [Bool]$query = $True
   }
   If($Compression){
      [String]$uri += "&compression=$Compression"
      [Bool]$query = $True
   }
   If($Deduplication){
      [String]$uri += "&deduplication=$Deduplication"
      [Bool]$query = $True
   }
   If($DateCreated){
      $createTime   = Get-Date -Date $DateCreated -Format "yyyy-MM-ddTHH:mm:ss.fffZ"
      [String]$uri += $("&create_time=" + ($createTime.ToString()))
      [Bool]$query  = $True
   }
   If($DateUpdated){
      $updateTime   = Get-Date -Date $DateUpdated -Format "yyyy-MM-ddTHH:mm:ss.fffZ"
      [String]$uri += $("&update_time=" + ($updateTime.ToString()))
      [Bool]$query  = $True
   }
   If($OrderBy){
      [String]$uri += "&order_by=$OrderBy"
   }
   If(-Not($query)){
      [String]$uri = $uri.SubString(0, ($uri.Length -1))
   }Else{
      [String]$uri = $uri.Replace("?&", "?")
   }
   #'---------------------------------------------------------------------------
   #'Enumerate the Storage Efficency Policies.
   #'---------------------------------------------------------------------------
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers -ErrorAction Stop
      Write-Host "Enumerated Storage Efficiency Policies on Server ""$Server"" using URI ""$uri"""
   }Catch{
      Write-Warning -Message $("Failed enumerating Storage Efficiency Policies on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
   }
   Return $response;
}#'End Function Get-UMEfficiencyPolicy.
#'------------------------------------------------------------------------------
Function Get-UMEfficiencyPolicyID{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $False, HelpMessage = "The Storage Efficiency Policy Resource Key. The syntax is: '<uuid>'")]
      [String]$PolicyID,
      [Parameter(Mandatory = $True, HelpMessage = "The Credential to authenticate to AIQUM")]
      [ValidateNotNullOrEmpty()]
      [System.Management.Automation.PSCredential]$Credential
   )
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{"Authorization" = "Basic $auth"}
   #'---------------------------------------------------------------------------
   #'Enumerate the Storage Efficency Policy.
   #'---------------------------------------------------------------------------
   [String]$uri = "https://$Server/api/storage-provider/storage-efficiency-policies/$PolicyID"
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers -ErrorAction Stop
      Write-Host "Enumerated Storage Efficiency Policy on Server ""$Server"" using URI ""$uri"""
   }Catch{
      Write-Warning -Message $("Failed enumerating Storage Efficiency Policy on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
   }
   Return $response;
}#'End Function Get-UMEfficiencyPolicyID.
#'------------------------------------------------------------------------------

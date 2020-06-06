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
}#End Function Get-UMCluster.
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
}#End Function Get-UMClusterID.
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
}#End Function Get-UMNode.
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
}#End Function Get-UMNodeID.
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
}#End Function Get-UMCifsShare.
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
}#End Function Get-UMCifsShareID.
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
}#End Function Get-UMExportPolicy.
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
}#End Function Get-UMExportPolicyID.
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
}#End Function Get-UMIgroup.
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
}#End Function Get-UMIgroupID.
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
      Write-Host "Enumerating vserver resource key for Vserver ""$VserverName"" on cluster ""$ClusterName"" on server ""$Server"""
      [String]$command = "Get-UMVserver -Server $Server -VserverName $VserverName -ClusterName $ClusterName -Credential `$Credential -ErrorAction Stop"
      Try{
         $vserver = Invoke-Expression -Command $command -ErrorAction Stop
         Write-Host "Executed Command`: $command" -ForegroundColor Cyan
      }Catch{
         Write-Warning -Message $("Failed Executing Command`: $command. Error " + $_.Exception.Message)
         Return $vserver;
      }
      [String]$VserverID = $vserver.records.key
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
}#End Function New-UMIgroup.
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
      [String]$command = "Get-UMIGroup -Server $Server -IGroupName $IGroupName -VserverName $VserverName -ClusterName $ClusterName -Credential `$Credential -ErrorAction Stop"
      Try{
         $i = Invoke-Expression -Command $command -ErrorAction Stop
         Write-Host "Executed Command`: $command" -ForegroundColor Cyan
      }Catch{
         Write-Warning -Message $("Failed Executing Command`: $command. Error " + $_.Exception.Message)
         Return $Null;
      }
      [String]$IgroupID = $i.records.key
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
}#End Function Set-UMIgroup.
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
}#End Function Remove-UMIgroup.
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
   #'Enumerate the IGroup by Name if the resource key is not provided.
   #'---------------------------------------------------------------------------
   If(-Not($IgroupID)){
      [String]$command = "Get-UMIgroup -Server $Server -ClusterName $ClusterName -VserverName $VserverName -IGroupName $IGroupName -Credential `$Credential -ErrorAction Stop"
      Try{
         $i = Invoke-Expression -Command $command -ErrorAction Stop
         Write-Host "Executed Command`: $command"
      }Catch{
         Write-Warning -Message $("Failed Executing Command`: $command. Error " + $_.Exception.Message)
         Return $Null;
      }
      If($Null -eq $i){
         Write-Warning -Message "The IGroup ""$IGroupName"" was not found on vserver ""$VserverName"" on cluster ""$ClusterName"""
         Return $Null;
      }
      [String]$IGroupID = $i.records.key
   }
   #'---------------------------------------------------------------------------
   #'Enumerate the IGroup by ID to ensure the initiators list is the most current.
   #'---------------------------------------------------------------------------
   [String]$command = "Get-UMIgroupID -Server $Server -IGroupID $IGroupID -Credential `$Credential -ErrorAction Stop"
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
      [String]$command      = $("Set-UMIGroup -Server $Server -IGroupName " + $ig.name + " -IGroupID '" + $ig.key + "' -OsType " + $ig.os_type + " -Protocol " + $ig.protocol + " -Initiators `$initiatorList -Credential `$Credential -ErrorAction Stop")
      Try{
         $igroup = Invoke-Expression -Command $command -ErrorAction Stop
         Write-Host "Executed Command`: $command" -ForegroundColor Cyan
      }Catch{
         Write-Warning -Message $("Failed Executing Command`: $command. Error " + $_.Exception.Message)
         Return $igroup;
      }
      If($id){
         Write-Host $("Added Initiators """ + $([String]::Join(",", $updateList)) + """ to IGroup ID ""$IGroupID""")
      }Else{
         Write-Host $("Added Initiators """ + $([String]::Join(",", $updateList)) + """ to IGroup ""$IGroupName"" on Vserver ""$VserverName"" on Cluster ""$ClusterName""")
      }
   }Else{
      If($id){
         Write-Host $("The Initiators """ + $([String]::Join(",", $Initiators)) + """ are already added to Igroup ID ""$IGroupID""")
      }Else{
         Write-Host $("The Initiators """ + $([String]::Join(",", $Initiators)) + """ are already added to Igroup ""$IGroupName"" on Vserver ""$VserverName"" on Cluster ""$ClusterName""")
      }
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
   #'Enumerate the IGroup by Name if the resource key is not provided.
   #'---------------------------------------------------------------------------
   If(-Not($IgroupID)){
      [String]$command = "Get-UMIgroup -Server $Server -ClusterName $ClusterName -VserverName $VserverName -IGroupName $IGroupName -Credential `$Credential -ErrorAction Stop"
      Try{
         $i = Invoke-Expression -Command $command -ErrorAction Stop
         Write-Host "Executed Command`: $command"
      }Catch{
         Write-Warning -Message $("Failed Executing Command`: $command. Error " + $_.Exception.Message)
         Return $Null;
      }
      If($Null -eq $i){
         Write-Warning -Message "The IGroup ""$IGroupName"" was not found on vserver ""$VserverName"" on cluster ""$ClusterName"""
         Return $Null;
      }
      [String]$IGroupID = $i.records.key
   }
   #'---------------------------------------------------------------------------
   #'Enumerate the IGroup by ID to ensure the initiators list is the most current.
   #'---------------------------------------------------------------------------
   [String]$command = "Get-UMIgroupID -Server $Server -IGroupID $IGroupID -Credential `$Credential -ErrorAction Stop"
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
      [String]$command      = $("Set-UMIGroup -Server $Server -IGroupName " + $ig.name + " -IGroupID '" + $ig.key + "' -OsType " + $ig.os_type + " -Protocol " + $ig.protocol + " -Initiators `$initiatorList -Credential `$Credential -ErrorAction Stop")
      Try{
         $igroup = Invoke-Expression -Command $command -ErrorAction Stop
         Write-Host "Executed Command`: $command" -ForegroundColor Cyan
      }Catch{
         Write-Warning -Message $("Failed Executing Command`: $command. Error " + $_.Exception.Message)
         Return $igroup;
      }
      If($id){
         Write-Host $("Removed Initiators """ + $([String]::Join(",", $removedList)) + """ from IGroup ID ""$IGroupID""")
      }Else{
         Write-Host $("Removed Initiators """ + $([String]::Join(",", $removedList)) + """ from IGroup ""$IGroupName"" on Vserver ""$VserverName"" on Cluster ""$ClusterName""")
      }
   }Else{
      If($id){
         Write-Host $("The Initiators """ + $([String]::Join(",", $Initiators)) + """ do not exist in Igroup ID ""$IGroupID""")
      }Else{
         Write-Host $("The Initiators """ + $([String]::Join(",", $Initiators)) + """ do not exist in Igroup ""$IGroupName"" on Vserver ""$VserverName"" on Cluster ""$ClusterName""")
      }
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
   #'Enumerate the vservers.
   #'---------------------------------------------------------------------------
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers -ErrorAction Stop
      Write-Host "Enumerated Vservers on Server ""$Server"" using URI ""$uri"""
   }Catch{
      Write-Warning -Message $("Failed enumerating Vservers on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
   }
   Return $response;
}#End Function Get-UMVserver.
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
      [String]$command = "Get-UMCluster -Server $Server -ClusterName $ClusterName -Credential `$Credential -ErrorAction Stop"
      Try{
         $cluster = Invoke-Expression -Command $command -ErrorAction Stop
         Write-Host "Executed Command`: $command" -ForegroundColor Cyan
      }Catch{
         Write-Warning -Message $("Failed Executing Command`: $command. Error " + $_.Exception.Message)
         Return $Null;
      }
      [String]$ClusterId = $cluster.records.key
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
}#End Function Invoke-UMRediscover.
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
}#End Function Wait-UMRediscover.
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
      [String]$command = "Get-UMCluster -Server $Server -ClusterName $ClusterName -Credential `$Credential -ErrorAction Stop"
      Try{
         $cluster = Invoke-Expression -Command $command -ErrorAction Stop
         Write-Host "Executed Command`: $command" -ForegroundColor Cyan
      }Catch{
         Write-Warning -Message $("Failed Executing Command`: $command. Error " + $_.Exception.Message)
         Return $Null;
      }
      [String]$ClusterId = $cluster.records.key
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
}#End Function Set-UMDatasourcePassword.
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
}#End Function Get-UMDatasource.
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
}#End Function Get-UMDatasourceID.
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
}#End Function Add-UMDatasource.
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
}#End Function Get-UMDataRetention.
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
}#End Function Get-UMUser.
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
}#End Function Get-UMUsername.
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
}#End Function New-UMUser.
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
}#End Function Set-UMUser.
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
Function New-UMLunMapID{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $True, HelpMessage = "The LUN resource key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$LunID,
      [Parameter(Mandatory = $True, HelpMessage = "The IGroup resource key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$IGroupID,
      [Parameter(Mandatory = $False, HelpMessage = "The LUN Logical Unit Number")]
      [ValidateRange(0, 4095)]
      [Int]$ID,
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
}#End Function Add-UMLunMapID.
#'------------------------------------------------------------------------------
Function Set-UMLunID{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $True, HelpMessage = "The LUN resource key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$LunID,
      [Parameter(Mandatory = $False, HelpMessage = "The LUN state. Valid values are 'online' or 'offline'")]
      [ValidateSet("online","offline")]
      [String]$State,
      [Parameter(Mandatory = $False, HelpMessage = "The LUN Size in GigaBytes")]
      [Int]$SizeGB,
      [Parameter(Mandatory = $False, HelpMessage = "The Performance Service Level resource key. The syntax is: '<uuid>'")]
      [String]$PerformanceServiceLevelID,
      [Parameter(Mandatory = $False, HelpMessage = "The Storage Efficiency Policy resource key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$EfficiencyPolicyID,
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
   [String]$uri    = "https://$Server/api/storage-provider/luns/$LunID"
   [HashTable]$lun = @{};
   [Bool]$update   = $False;
   If($State){
      [HashTable]$lun.Add("operational_state", $State)
      [Bool]$update = $True
   }
   If($PerformanceServiceLevelID){
      [HashTable]$serviceLevel = @{"key" = $PerformanceServiceLevelID};
      [HashTable]$lun.Add("performance_service_level", $serviceLevel)
      [Bool]$update = $True
   }
   If($SizeGB){
      [HashTable]$space = @{"size" = ($SizeGB * (1024 * 1024 * 1024))};
      [HashTable]$lun.Add("space", $space)
      [Bool]$update = $True
   }
   If($EfficiencyPolicyID){
      [HashTable]$policy = @{"key" = $EfficiencyPolicyID};
      [HashTable]$lun.Add("storage_efficiency_policy", $policy)
      [Bool]$update = $True
   }
   If(-Not($update)){
      Write-Host "The LUN ID ""$LunID"" was not been modified. Please provide valid input parameters"
      Return $Null;
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
   If($PerformanceServiceLevelID){
      [String]$message += "Performance Service Level ID ""$PerformanceServiceLevelID"" "
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
}#End Function Set-UMLunID.
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
      [String]$uri  += "&name=$LunName"
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
}#End Function Get-UMLun.
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
}#End Function Get-UMLunID.
#'------------------------------------------------------------------------------
Function Remove-UMLunID{
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
   $headers = @{
      "Authorization" = "Basic $auth"
      "Accept"        = "application/json"
      "Content-Type"  = "application/json"
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
      Return $False;
   }
   Return $True;
}#'End Function Remove-UMLunID.
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
      [Parameter(Mandatory = $True, HelpMessage = "The Performance Service Level resource key. The syntax is: '<uuid>'")]
      [String]$PerformanceServiceLevelID,
      [Parameter(Mandatory = $False, HelpMessage = "The Storage Efficiency Policy resource key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$EfficiencyPolicyID,
      [Parameter(Mandatory = $False, HelpMessage = "The Volume resource key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$VolumeID,
      [Parameter(Mandatory = $False, HelpMessage = "The Volume Name")]
      [String]$VolumeName,
      [Parameter(Mandatory = $True, HelpMessage = "The Vserver resource key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$VserverID,
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
   [HashTable]$serviceLevel = @{"key" = $PerformanceServiceLevelID}
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
   [String]$message += "LUN ""$LunName"" of size ""$SizeGB`GB"" of OS Type ""$OsType"" on VserverID ""$VserverID"" of Performance Service Level ""$PerformanceServiceLevelID"" "
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
      $response = Invoke-RestMethod -Uri $uri -Method POST -Body $body -Headers $headers -ErrorAction Stop
      Write-Host $("Created " + $message)
   }Catch{
      Write-Warning -Message $("Failed creating " + $message + ". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
   }
   Return $response;
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
}#End Function Get-UMEventID.
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
      [Parameter(Mandatory = $False, HelpMessage = "The Volume Security Style")]
      [ValidateSet("mixed","ntfs","unix")]
      [String]$SecurityStyle,
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
   If($SecurityStyle){
      [String]$uri += "&style=$SecurityStyle"
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
}#End Function Get-UMVolume.
#'------------------------------------------------------------------------------

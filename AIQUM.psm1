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
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{
      "Authorization" = "Basic $auth"
   }
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
   If($Name){
      [String]$uri += "&name=$Name"
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
      If($version -NotMatch '\d{1,3}$'){
         Write-Warning "The 'Version' parameter does contain the full ONTAP version number including the major, minor and micro release numbers. Example '9.6.0'"
         Return $Null
      }
      [String]$uri += "&version.full=$Version"
      [Bool]$query = $True
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
      Write-Warning -Message $("Failed enumerating clusters on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
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
   $headers = @{
      "Authorization" = "Basic $auth"
   }
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
      [String]$Name,
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
   $headers = @{
      "Authorization" = "Basic $auth"
   }
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
   If($Name){
      [String]$uri += "&name=$Name"
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
      If($version -NotMatch '\d{1,3}$'){
         Write-Warning "The 'Version' parameter does contain the full ONTAP version number including the major, minor and micro release numbers. Example '9.6.0'"
         Return $Null
      }
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
   $headers = @{
      "Authorization" = "Basic $auth"
   }
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
      [String]$Name,
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
      [String]$VserverUuid,
      [Parameter(Mandatory = $False, HelpMessage = "The Volume Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$VolumeID,
      [Parameter(Mandatory = $False, HelpMessage = "The Volume Name")]
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
   $headers = @{
      "Authorization" = "Basic $auth"
   }
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
   If($Name){
      [String]$uri += "&name=$Name"
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
   $headers = @{
      "Authorization" = "Basic $auth"
   }
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
      [String]$Name,
      [Parameter(Mandatory = $False, HelpMessage = "The Export Policy ID")]
      [Long]$PolicyId,
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
   $headers = @{
      "Authorization" = "Basic $auth"
   }
   #'---------------------------------------------------------------------------
   #'Set the URI to enumerate the Export Policy.
   #'---------------------------------------------------------------------------
   [String]$uri = "https://$Server/api/datacenter/protocols/nfs/export-policies?"
   [Bool]$query = $False;
   If($ExportPolicyID){
      [String]$uri += "&key=$ExportPolicyID"
      [Bool]$query = $True
   }
   If($Name){
      [String]$uri += "&name=$Name"
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
   $headers = @{
      "Authorization" = "Basic $auth"
   }
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
      [String]$Name,
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
      [String]$VserverUuid,
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
   $headers = @{
      "Authorization" = "Basic $auth"
   }
   #'---------------------------------------------------------------------------
   #'Set the URI to enumerate the Igroups.
   #'---------------------------------------------------------------------------
   [String]$uri = "https://$Server/api/datacenter/protocols/san/igroups?"
   [Bool]$query = $False;
   If($IGroupID){
      [String]$uri += "&key=$IGroupID"
      [Bool]$query = $True
   }
   If($Name){
      [String]$uri += "&name=$Name"
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
   $headers = @{
      "Authorization" = "Basic $auth"
   }
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
      [String]$Name,
      [Parameter(Mandatory = $True, HelpMessage = "The Vserver Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$VserverId,
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
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $auth    = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
   $headers = @{
      "Authorization" = "Basic $auth"
      "Accept"        = "application/json"
      "Content-Type"  = "application/json"

   }
   #'---------------------------------------------------------------------------
   #'Set the URI to enumerate the Igroups.
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
   }Else{
      [HashTable]$iqn = @{};
      [HashTable]$igroup.Add("initiators", $iqn)
   }
   [HashTable]$vserver = @{"key" = $VserverID}
   [HashTable]$igroup.Add("name",     $Name)
   [HashTable]$igroup.Add("os_type",  $OsType)
   [HashTable]$igroup.Add("protocol", $Protocol)
   [HashTable]$igroup.Add("svm",      $vserver)
   $body = $igroup | ConvertTo-Json
   #'---------------------------------------------------------------------------
   #'Create the IGroup.
   #'---------------------------------------------------------------------------
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method POST -Body $body -Headers $headers -ErrorAction Stop
      Write-Host $("Created IGroup ""$Name"" of OS type ""$OsType"" Protocol ""$Protocol"" with initiators """ + $([String]::Join(",", $Initiators)) + """ on Vserver ID ""$VserverID"" Server ""$Server"" using URI ""$uri""")
   }Catch{
      Write-Warning -Message $("Failed creating IGroup ""$Name"" of OS type ""$OsType"" Protocol ""$Protocol"" with initiators """ + $([String]::Join(",", $Initiators)) + """ on Vserver ID ""$VserverID""  using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
   }
   Return $response;
}#End Function New-UMIgroup.
#'------------------------------------------------------------------------------
Function Remove-UMIgroup{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $True, HelpMessage = "The IGroup Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$IgroupId,
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
   #'Remove the IGroup.
   #'---------------------------------------------------------------------------
   [String]$uri = "https://$Server/api/datacenter/protocols/san/igroups/$IGroupID"
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method DELETE -Headers $headers -ErrorAction Stop
      Write-Host $("Removed IGroupID ""$IGroupID"" from Server ""$Server"" using URI ""$uri""")
   }Catch{
      Write-Warning -Message $("Failed removing IGroupID ""$IGroupID"" from Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
   }
   Return $response;
}#End Function Remove-UMIgroup.
#'------------------------------------------------------------------------------
Function Set-UMIgroup{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $False, HelpMessage = "The IGroup Name")]
      [String]$Name,
      [Parameter(Mandatory = $True, HelpMessage = "The IGroup Resource Key. The syntax is: 'key=<uuid>:type=<object_type>,uuid=<uuid>'")]
      [String]$IgroupId,
      [Parameter(Mandatory = $False, HelpMessage = "The IGroup Operating System Type. Valid values are 'aix', 'hpux', 'hyper_v', 'linux', 'netware', 'openvms', 'solaris', 'vmware', 'windows' and 'xen'")]
      [ValidateSet("aix","hpux","hyper_v","linux","netware","openvms","solaris","vmware","windows","xen")]
      [String]$OsType,
      [Parameter(Mandatory = $False, HelpMessage = "The IGroup Protocol. Valid values are 'fcp', 'iscsi' and 'mixed'")]
      [ValidateSet("fcp","iscsi","mixed")]
      [String]$Protocol,
      [Parameter(Mandatory = $False, HelpMessage = "The IGroup Initiators")]
      [Array]$Initiators,
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
   [HashTable]$igroup.Add("name",     $Name)
   [HashTable]$igroup.Add("os_type",  $OsType)
   $body = $igroup | ConvertTo-Json
   #'---------------------------------------------------------------------------
   #'Set the IGroup.
   #'---------------------------------------------------------------------------
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method PATCH -Body $body -Headers $headers -ErrorAction Stop
      Write-Host $("Set IGroup ""$Name"" of OS type ""$OsType"" with initiators """ + $([String]::Join(",", $Initiators)) + """ on Vserver ID ""$VserverID"" Server ""$Server"" using URI ""$uri""")
   }Catch{
      Write-Warning -Message $("Failed setting IGroup ""$Name"" of OS type ""$OsType"" with initiators """ + $([String]::Join(",", $Initiators)) + """ on Vserver ID ""$VserverID""  using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
   }
   Return $response;
}#End Function Set-UMIgroup.
#'------------------------------------------------------------------------------

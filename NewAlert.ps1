#'------------------------------------------------------------------------------
Param(
   [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
   [ValidateNotNullOrEmpty()]
   [String]$Server,
   [Parameter(Mandatory = $False, HelpMessage = "The Alert name")]
   [String]$AlertName,
   [Parameter(Mandatory = $False, HelpMessage = "The Alert description")]
   [String]$Description,
   [Parameter(Mandatory = $False, HelpMessage = "Indicates if the alert is enabled")]
   [Bool]$Enabled = $False,
   [Parameter(Mandatory = $False, HelpMessage = "The event severtities. Valid values are 'warning, error or critical'")]
   [Array]$EventSeverities,
   [Parameter(Mandatory = $False, HelpMessage = "The Type of event to be observered. EG 'Login Banner Disabled'")]
   [Array]$EventTypes,
   [Parameter(Mandatory = $False, HelpMessage = "The Resource Type")]
   [ValidateSet("cluster", "cluster_node", "vserver", "aggregate", "volume", "network_lif", "qtree", "lun", "namespace", "bridge", "bridge_stack_connection", "fcp_lif", "inter_node_connection", "inter_switch_connection", "network_port", "metro_cluster_relationship", "nvmf_fc_lif", "node_bridge_connection", "node_stack_connection", "node_switch_connection", "storage_shelf", "switch", "switch_bridge_connection", "snap_mirror", "fcp_port", "objectstore_config", "disk", "infinitevol_storage_service", "user_quota", "management_station", "storage_service")]
   [String]$ResourceType,
   [Parameter(Mandatory = $False, HelpMessage = "The Resource UUID's")]
   [Array]$ResourceKeys,
   [Parameter(Mandatory = $False, HelpMessage = "The Resource names to include")]
   [Array]$Include,
   [Parameter(Mandatory = $False, HelpMessage = "The Resource names to exclude")]
   [Array]$Exclude,
   [Parameter(Mandatory = $False, HelpMessage = "Indicates if all resources are included")]
   [Bool]$IncludeAll = $False,
   [Parameter(Mandatory = $False, HelpMessage = "The duration between alert notifications. EG 'PT1000S'")]
   [String]$Duration,
   [Parameter(Mandatory = $False, HelpMessage = "The Email Addresses to send the alert notifications to")]
   [Array]$EmailAddresses,
   [Parameter(Mandatory = $False, HelpMessage = "The start time of recurring notifications. EG 'PT9000S'")]
   [String]$StartTime,
   [Parameter(Mandatory = $False, HelpMessage = "The end time of recurring notifications. EG 'PT18000S'")]
   [String]$EndTime,
   [Parameter(Mandatory = $False, HelpMessage = "Indicates if an SNMP trap should be issued")]
   [Bool]$SnmpTrap = $False,
   [Parameter(Mandatory = $False, HelpMessage = "The Script UUID. EG '02c9e252-41be-11e9-81d5-00a0986138f7'")]
   [String]$ScriptID,
   [Parameter(Mandatory = $False, HelpMessage = "The Script name to attach to the alert")]
   [String]$ScriptName,
   [Parameter(Mandatory = $True, HelpMessage = "The Credential to authenticate to AIQUM")]
   [ValidateNotNullOrEmpty()]
   [System.Management.Automation.PSCredential]$Credential
)
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
}#'End Function Get-UMAuthorization.
#'------------------------------------------------------------------------------
Function New-UMAlert{
   [CmdletBinding()]
   Param(
      [Parameter(Mandatory = $True, HelpMessage = "The AIQUM server Hostname, FQDN or IP Address")]
      [ValidateNotNullOrEmpty()]
      [String]$Server,
      [Parameter(Mandatory = $True, HelpMessage = "The Alert name")]
      [String]$AlertName,
      [Parameter(Mandatory = $False, HelpMessage = "The Alert description")]
      [String]$Description,
      [Parameter(Mandatory = $False, HelpMessage = "Indicates if the alert is enabled")]
      [Bool]$Enabled = $False,
      [Parameter(Mandatory = $False, HelpMessage = "The event severtities. Valid values are 'warning, error or critical'")]
      [Array]$EventSeverities,
      [Parameter(Mandatory = $False, HelpMessage = "The Type of event to be observered. EG 'Login Banner Disabled'. Valid values are 'warning', 'error' and 'critical'")]
      [Array]$EventTypes,
      [Parameter(Mandatory = $False, HelpMessage = "The Resource Type")]
      [ValidateSet("cluster", "cluster_node", "vserver", "aggregate", "volume", "network_lif", "qtree", "lun", "namespace", "bridge", "bridge_stack_connection", "fcp_lif", "inter_node_connection", "inter_switch_connection", "network_port", "metro_cluster_relationship", "nvmf_fc_lif", "node_bridge_connection", "node_stack_connection", "node_switch_connection", "storage_shelf", "switch", "switch_bridge_connection", "snap_mirror", "fcp_port", "objectstore_config", "disk", "infinitevol_storage_service", "user_quota", "management_station", "storage_service")]
      [String]$ResourceType,
      [Parameter(Mandatory = $False, HelpMessage = "The Resource UUID's")]
      [Array]$ResourceKeys,
      [Parameter(Mandatory = $False, HelpMessage = "The Resource names to include")]
      [Array]$Include,
      [Parameter(Mandatory = $False, HelpMessage = "The Resource names to exclude")]
      [Array]$Exclude,
      [Parameter(Mandatory = $False, HelpMessage = "Indicates if all resources are included")]
      [Bool]$IncludeAll = $False,
      [Parameter(Mandatory = $False, HelpMessage = "The duration between alert notifications. EG 'PT1000S'")]
      [String]$Duration,
      [Parameter(Mandatory = $False, HelpMessage = "The Email Addresses to send the alert notifications to")]
      [Array]$EmailAddresses,
      [Parameter(Mandatory = $False, HelpMessage = "The start time of recurring notifications. EG 'PT9000S'")]
      [String]$StartTime,
      [Parameter(Mandatory = $False, HelpMessage = "The end time of recurring notifications. EG 'PT18000S'")]
      [String]$EndTime,
      [Parameter(Mandatory = $False, HelpMessage = "Indicates if an SNMP trap should be issued")]
      [Bool]$SnmpTrap = $False,
      [Parameter(Mandatory = $False, HelpMessage = "The Script UUID. EG '02c9e252-41be-11e9-81d5-00a0986138f7'")]
      [String]$ScriptID,
      [Parameter(Mandatory = $False, HelpMessage = "The Script name to attach to the alert")]
      [String]$ScriptName,
      [Parameter(Mandatory = $True, HelpMessage = "The Credential to authenticate to AIQUM")]
      [ValidateNotNullOrEmpty()]
      [System.Management.Automation.PSCredential]$Credential
   )
   #'---------------------------------------------------------------------------
   #'Set the authentication header to connect to AIQUM.
   #'---------------------------------------------------------------------------
   $headers = Get-UMAuthorization -Credential $Credential
   #'---------------------------------------------------------------------------
   #'Create a hashtable for the body and covert to JSON.
   #'---------------------------------------------------------------------------
   [String]$uri = "https://$Server/api/management-server/alerts"
   $alert        = @{};
   $action       = @{};
   $event        = @{};
   $notification = @{};
   $resource     = @{};
   $script       = @{};
   $resources    = @();
   $notification.Add("duration", $Duration)
   $notification.Add("emails", [Array]$EmailAddresses)
   $notification.Add("from", $StartTime)
   $notification.Add("send_snmp_trap", $SnmpTrap)
   $notification.Add("to", $EndTime)
   $script.Add("key", $ScriptID)
   $script.Add("name", $ScriptName)
   $action.Add("notification", $notification)
   $action.Add("script", $script)
   $alert.Add("action", $action)
   $alert.Add("description", $Description)
   $alert.Add("enabled", $Enabled)
   $event.Add("severities", [Array]$EventSeverities)
   $event.Add("types", [Array]$EventTypes)
   $alert.Add("event", $event)
   $alert.Add("name", $AlertName)
   $resource.Add("exclude", [Array]$Exclude)
   $resource.Add("include", [Array]$Include)
   $resource.Add("include_all", $IncludeAll)
   $resource.Add("keys", [Array]$ResourceKeys)
   $resource.Add("type", $ResourceType)
   $resources += $resource
   $alert.add("resource", $resources)
   $body = $alert | ConvertTo-Json -Depth 3 
   #'---------------------------------------------------------------------------
   #'Create the Alert.
   #'---------------------------------------------------------------------------
   Try{
      $response = Invoke-RestMethod -Uri $uri -Method POST -Body $body -Headers $headers -ErrorAction Stop
      Write-Host "Created Alert ""$AlertName"" on Server ""$Server"" using URI ""$uri"""
   }Catch{
      Write-Warning -Message $("Failed creating Alert ""$AlertName"" on Server ""$Server"" using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
   }
   Return $response;
}#'End Function New-UMAlert.
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
[String]$command = "New-UMAlert -Server $Server "
If($AlertName){
   [String]$command += "-AlertName '$AlertName' "
}
If($Description){
   [String]$command += "-Description '$Description' "
}
If($Enabled){
   [String]$command += "-Enabled `$$Enabled "
}
If($EventSeverities){
   [String]$command += "-EventSeverities `@`(`'$EventSeverities`'`) "
}
If($EventTypes){
   [String]$command += "-EventTypes `@`(`'$EventTypes`'`) "
}
If($ResourceType){
   [String]$command += "-ResourceType $ResourceType "
}
If($ResourceKeys){
   [String]$command += "-ResourceKeys `@`(`'$ResourceKeys`'`) "
}
If($Include){
   [String]$command += "-Include `@`(`'$Include`'`) "
}
If($Exclude){
   [String]$command += "-Exclude `@`(`'$Exclude`'`) "
}
[String]$command += "-IncludeAll `$$IncludeAll "
If($Duration){
   [String]$command += "-Duration $Duration "
}
If($EmailAddresses){
   [String]$command += "-EmailAddresses `@`(`'$EmailAddresses`'`) "
}
If($StartTime){
   [String]$command += "-StartTime $StartTime "
}
If($EndTime){
   [String]$command += "-EndTime $EndTime "
}
If($Null -ne $SnmpTrap){
   [String]$command += "-SnmpTrap `$$SnmpTrap "
}
If($ScriptID){
   [String]$command += "-ScriptID '$ScriptID' "
}
If($ScriptName){
   [String]$command += "-ScriptName $ScriptName "
}
[String]$command += "-Credential `$Credential -ErrorAction Stop"
#'------------------------------------------------------------------------------
#'Query the clusters.
#'------------------------------------------------------------------------------
Try{
   $response = Invoke-Expression -Command $command -ErrorAction Stop
   Write-Host "Executed Command`: $command" -ForegroundColor Cyan
}Catch{
   Write-Warning -Message $("Failed Executing Command`: $command. Error " + $_.Exception.Message)
   $response
}
#'------------------------------------------------------------------------------

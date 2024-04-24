Param(
   [Parameter(Mandatory=$True, HelpMessage="The AIQUM host name or IP Address")]
   [String]$HostName,
   [Parameter(Mandatory=$False, HelpMessage="The AIQUM port number")]
   [Int]$PortNumber=443,
   [Parameter(Mandatory=$False, HelpMessage="The AIQUM timeout in seconds")]
   [Int]$Timeout,
   [Parameter(Mandatory=$True, HelpMessage="The AIQUM Alert name")]
   [String]$AlertName,
   [Parameter(Mandatory=$False, HelpMessage="The AIQUM Alert description")]
   [String]$Description,
   [Parameter(Mandatory=$True, HelpMessage="The AIQUM Alert email addresses")]
   [Array]$EmailAddresses,
   [Parameter(Mandatory=$True, HelpMessage="The AIQUM Alert severities. Valid values are 'Critical', 'Error' or 'Warning'")]
   [ValidateSet("Critical","Error","Warning")]
   [Array]$EventSeverities,
   [Parameter(Mandatory=$True, HelpMessage="The AIQUM Alert Disabled State")]
   [Array]$IsDisabled,
   [Parameter(Mandatory=$False, HelpMessage="The AIQUM Alert resource keys")]
   [Array]$ResourceKeys,
   [Parameter(Mandatory=$False, HelpMessage="The AIQUM Alert resource type. Valid values are 'Aggregate', 'Cloud Tier', 'Cluster', 'Fibre Channel LIF', 'Fibre Channel Port Target', 'LIF', 'LUN', 'Management Station', 'MetroCluster Bridge', 'MetroCluster Bridge Stack Connection', 'MetroCluster Inter Node Connection', 'MetroCluster Inter-Switch Connection', 'MetroCluster Node Bridge Connection', 'MetroCluster Node Stack Switch', 'MetroCluster Node Switch Connection', 'MetroCluster Relationship', 'MetroCluster Switch', 'MetroCluster Switch Bridge Connection', 'Network Port', 'Node', 'NVMe Namespace', 'NVMFf FC LIF', 'Qtree', 'SnapMirror Relationship', 'Storage Class', 'Storage Service', 'Storage Shelf', 'Storage Virtual Machine', 'User or Group Quota' and 'Volume'")]
   [ValidateSet("Aggregate","Cloud Tier","Cluster","Fibre Channel LIF","Fibre Channel Port Target","LIF","LUN","Management Station","MetroCluster Bridge","MetroCluster Bridge Stack Connection","MetroCluster Inter Node Connection","MetroCluster Inter-Switch Connection","MetroCluster Node Bridge Connection","MetroCluster Node Stack Switch","MetroCluster Node Switch Connection","MetroCluster Relationship","MetroCluster Switch","MetroCluster Switch Bridge Connection","Network Port","Node","NVMe Namespace","NVMFf FC LIF","Qtree","SnapMirror Relationship","Storage Class","Storage Service","Storage Shelf","Storage Virtual Machine","User or Group Quota","Volume")]
   [Array]$ResourceTypes,
   [Parameter(Mandatory=$False, HelpMessage="The number of seconds that the AIQUM alert should wait until resending an alert notification")]
   [ValidateRange(1,86400)]
   [Int]$RepeatFrequency,
   [Parameter(Mandatory=$False, HelpMessage="The number of seconds from midnight until the time that the AIQUM alert will stop resending notifications")]
   [ValidateRange(1,86400)]
   [Int]$RepeatFrequencyFrom,
   [Parameter(Mandatory=$False, HelpMessage="The number of seconds from midnight until the time that the AIQUM alert will start resending notifications")]
   [ValidateRange(1,86400)]
   [Int]$RepeatFrequencyTo,
   [Parameter(Mandatory=$True, HelpMessage="The AIQUM Alert SNMP Trap State")]
   [Array]$SendSnmpTrap,
   [Parameter(Mandatory=$True, HelpMessage="The adminstrative credentials to authenticate to OCUM")]
   [System.Management.Automation.PSCredential]$Credentials
)
#'------------------------------------------------------------------------------
Function New-ZapiServer{
   Param(
      [Parameter(Mandatory=$True, HelpMessage="The hostname or IP address to create a ZAPI connection to")]
      [Alias('Host')]
      [String]$HostName,
      [Parameter(Mandatory=$False, HelpMessage="The port number to use for the ZAPI connection")]
      [Alias('Port')]
      [Int]$PortNumber=443,
      [Parameter(Mandatory=$True, HelpMessage="The ZAPI connection type. Valid values are 'FILER' or 'DFM'")]
      [ValidateSet("FILER", "DFM")]
      [Alias('Type')]
      [String]$ZapiType,
      [Parameter(Mandatory=$True, HelpMessage="The Credentials to authenticate the ZAPI connection")]
      [System.Management.Automation.PSCredential]$Credentials,
      [Parameter(Mandatory=$False, HelpMessage="The name of the vfiler or vserver if the ZAPI connection type is set to Filer. Used to set vfiler or vserver tunnelling")]
      [String]$VFiler,
      [Parameter(Mandatory=$False, HelpMessage="The protocol to set for the ZAPI connection. Valid values are 'https' or 'http'")]
      [ValidateSet("https", "http")]
      [String]$Protocol="https",
      [Parameter(Mandatory=$False, HelpMessage="The timeout of the ZAPI connection in seconds")]
      [Int]$TimeOut=60
   )
   #'---------------------------------------------------------------------------
   #'Create the NaServer server object based on the ZAPI type.
   #'---------------------------------------------------------------------------
   $ErrorActionPreference = "Stop"
   Write-Host "Creating ZAPI connection type ""$ZapiType"" to ""$HostName"""
   Try{
      If($ZapiType -eq "DFM"){
         [NetApp.Manage.NaServer]$zapiServer = New-Object NetApp.Manage.NaServer($HostName, "1", "0")
         Write-Host "Created ZAPI connection type ""$ZapiType"" to ""$HostName"""
      }Else{
         [NetApp.Manage.NaServer]$zapiServer = New-Object NetApp.Manage.NaServer($HostName, "1", "14")
         Write-Warning -Message "Created ZAPI connection type ""$ZapiType"" to ""$HostName"""
         If($VFiler -And $VFiler.Length -gt 0){
            $zapiServer.SetVfilerTunneling($VFiler)
            Write-Host "Set VfilerTunnelling for ""$Vfiler"" for ZAPI connection to ""$HostName"""
         }
      }
   }Catch{
      Write-Warning -Message "Failed creating ZAPI connection type ""$ZapiType"" to ""$HostName"""
      Return $Null;
   }
   #'---------------------------------------------------------------------------
   #'Enumerate the username and password from the credential object.
   #'---------------------------------------------------------------------------
   [String]$domain    = $credentials.GetNetworkCredential().domain
   [String]$user      = $credentials.GetNetworkCredential().username
   [String]$password  = $credentials.GetNetworkCredential().password
   If(-Not([String]::IsNullOrEmpty($domain))){
      If($domain.Contains(".")){
         [String]$userName = "$user`@$domain"
      }Else{
         If($credentials.UserName.Contains("\") -And ($credentials.UserName.SubString(0, 1) -ne "\")){
            [String]$userName = $credentials.username
         }Else{
            [String]$userName = "$domain\$user"
         }
      }
   }Else{
      [String]$userName = $user
   }
   #'---------------------------------------------------------------------------
   #'Set the username and password for the NaServer object.
   #'---------------------------------------------------------------------------
   $zapiServer.SetAdminUser($userName, $password)
   $zapiServer.ServerType    = $ZapiType
   $zapiServer.TransportType = $Protocol
   #'---------------------------------------------------------------------------
   #'Set default port number (443) or the port number provided.
   #'---------------------------------------------------------------------------
   If($PortNumber){
      If($zapiServer.Port -ne $PortNumber){
         $zapiServer.Port = $PortNumber
      }
   }
   #'---------------------------------------------------------------------------
   #'Set the timeout default (60) or the timeout number provided.
   #'---------------------------------------------------------------------------
   If($TimeOut){
      $zapiServer.timeout = $TimeOut
   }
   Write-Host "Checking ZAPI connection status to hostname ""$HostName"" type ""$ZapiType"" using protocol ""$Protocol"" as user ""$user"""
   $result = Test-ZapiConnection -ZapiServer $zapiServer -ZapiType $ZapiType -HostName $HostName -ProtocolName $Protocol
   If($result -eq 0){
      Write-Warning -Message "Failed connecting to host ""$HostName"" using protocol ""$Protocol"""
   }
   Return $zapiServer;
}#End Function
#'------------------------------------------------------------------------------
Function Test-ZapiConnection{
   Param(
      [Parameter(Mandatory=$True, HelpMessage="The 'NetApp.Manage.NaServer' ZAPI connection object")]
      [Alias('Server')]
      [NetApp.Manage.NaServer]$ZapiServer,
      [Parameter(Mandatory=$True, HelpMessage="The ZAPI connection type. Valid values are 'FILER' or 'DFM'")]
      [ValidateSet("FILER", "DFM")]
      [Alias('Type')]
      [String]$ZapiType,
      [Parameter(Mandatory=$True, HelpMessage="The ZAPI server hostname")]
      [Alias('Host')]
      [String]$HostName,
      [Parameter(Mandatory=$True, HelpMessage="The ZAPI server protocol. Valid values are 'https' or 'http'")]
      [Alias('Protocol')]
      [ValidateSet("https", "http")]
      [String]$ProtocolName
   )
   #'---------------------------------------------------------------------------  
   #'invoke the API based on the ZAPI type.
   #'---------------------------------------------------------------------------
   $ZapiServer.TRANSPORT_TYPE #Refernce ZAPI property to stop API call failing.
   If($ZapiType -eq "DFM"){
      Try{
         [String]$apiName = "dfm-about"
         Write-Host "Invoking API ""$apiName"" to check connectivity to ""$HostName"" using the ""$ProtocolName"" protocol"
         [Xml]$result = $ZapiServer.Invoke($apiName)
      }Catch{
         Write-Warning -Message $("Failed invoking $ZapiType API ""$apiName"" on ""$HostName"" using the ""$ProtocolName"" protocol. Error " + $_.Exception.Message)
         Return -1
      }
   }Else{
      Try{
         [String]$zapiName = "system-get-version"
         Write-Host "Invoking ZAPI ""$zapiName"" to check connectivity to ""$HostName"" using protocol ""$ProtocolName"""
         [Xml]$result = $ZapiServer.Invoke($zapiName)
      }Catch{
         Write-Warning -Message $("Failed invoking $ZapiType API ""$apiName"" on ""$HostName"" using protocol ""$ProtocolName"". Error " + $_.Exception.Message)
         Return -1
      }
   }
   Return 0;
}#End Function
#'------------------------------------------------------------------------------
Function Import-ManageOntap{
   Param(
      [Parameter(Mandatory=$True, HelpMessage="The folder path to the 'manageontap.dll' file")]
      [String]$FolderPath
   )
   #'---------------------------------------------------------------------------
   #'Load the ManageONTAP.dll file
   #'---------------------------------------------------------------------------
   [String]$fileSpec = "$FolderPath\ManageOntap.dll"
   Try{
      [Reflection.Assembly]::LoadFile($fileSpec) | Out-Null
      Write-Host "Loaded file ""$fileSpec"""
   }Catch{
      Write-Warning -Message $("Failed loading file ""$fileSpec"". Error " + $_.Exception.Message)
      Return $False;
   }
   Return $True;
}#'End Function
#'------------------------------------------------------------------------------
#'Disable certificate CRL check and set TLS.
#'------------------------------------------------------------------------------
[System.Net.ServicePointManager]::CheckCertificateRevocationList = $False;
Add-Type @"
   using System;
   using System.Net;
   using System.Net.Security;
   using System.Security.Cryptography.X509Certificates;
   public class ServerCertificateValidationCallback{
      public static void Ignore(){
         ServicePointManager.ServerCertificateValidationCallback += 
         delegate(
            Object obj, 
            X509Certificate certificate, 
            X509Chain chain, 
            SslPolicyErrors errors
         )
         {
            return true;
         };
      }
   }
"@
[ServerCertificateValidationCallback]::Ignore();
[System.Net.ServicePointManager]::SecurityProtocol = @("Tls12","Tls11","Tls","Ssl3")
#'------------------------------------------------------------------------------
#'Ensure either the resource keys or resource types are provided
#'------------------------------------------------------------------------------
If((-Not($ResourceKeys)) -And (-Not($ResourceTypes))){
   Write-Warning -Message "Either the 'ResourceKeys' or 'ResourceType' input parameter must be provided"
   Break;
}
#'------------------------------------------------------------------------------
#'Import the manageontap.dll file.
#'------------------------------------------------------------------------------
[String]$scriptPath = Split-Path($MyInvocation.MyCommand.Path)
If(-Not(Import-ManageOntap -FolderPath $scriptPath)){
   Write-Warning -Message "The file ""$scriptPath\ManageOntap.dll"" does not exist"
   Break;
}
#'------------------------------------------------------------------------------
#'Create an AIQUM ZAPI connection.
#'------------------------------------------------------------------------------
Try{
   $naServer = New-ZapiServer -Host $HostName -Type DFM -Credentials $Credentials -ErrorAction Stop
}Catch{
   Write-Warning -Message "Failed creating ZAPI connection to ""$HostName"""
   Break;
}
#'------------------------------------------------------------------------------
#'Exit if the AIQUM ZAPI connection failed.
#'------------------------------------------------------------------------------
If($naServer -eq -1){
   Write-Warning -Message "Failed creating ZAPI connection to AIQUM server ""$HostName"""
   Break;
}
$ErrorActionPreference  = "Stop"
[String]$zapiName = "alert-create"
Write-Host "Invoking ZAPI ""$zapiName"""
Try{
   $naElement = New-Object NetApp.Manage.naElement("alert-create")
   $alertInfo = New-Object NetApp.Manage.naElement("alert-info")
   $alertInfo.AddNewChild("alert-name", $AlertName)
   $alertInfo.AddNewChild("alert-description", $Description)
   $addresses = New-Object NetApp.Manage.naElement("email-addresses")
   ForEach($emailAddress In $EmailAddresses){
      $addresses.AddNewChild("email-address", $emailAddress)
   }
   $alertInfo.AddChildElement($addresses)
   $severities = New-Object NetApp.Manage.naElement("event-severities")
   ForEach($eventSeverity In $eventSeverities){
      $severities.AddNewChild("obj-status", $eventSeverity)
   }
   $alertInfo.AddChildElement($severities)
   $alertInfo.AddNewChild("is-disabled", $IsDisabled)
   If($RepeatFrequency){
      $alertInfo.AddNewChild("repeat-interval", $RepeatFrequency)
   }
   $resourceObjectKeys = New-Object NetApp.Manage.naElement("resource-object-keys")
   ForEach($resourceKey In $resourceKeys){
      $resourceObjectKeys.AddNewChild("resource-key", $resourceKey)
   }
   $alertInfo.AddChildElement($resourceObjectKeys)
   If($RepeatFrequency -And ($RepeatFrequencyFrom -And $RepeatFrequencyTo)){
      $alertInfo.AddNewChild("time-from", $RepeatFrequencyFrom)
      $alertInfo.AddNewChild("time-to", $RepeatFrequencyTo)
   }
   $alertInfo.AddNewChild("send-snmp-trap", $SendSnmpTrap)
   $naElement.AddChildElement($alertInfo)
   $alertInfo
   $results = $naServer.InvokeElem($naElement)
   $results
}Catch{
   Write-Warning -Message $("Failed invoking ""$zapiName"". Error " + $_.Exception.Message)
   Throw "Failed invoking ""$zapiName"""
}
#'------------------------------------------------------------------------------

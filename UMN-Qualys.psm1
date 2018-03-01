#region Intro
###
# Copyright 2017 University of Minnesota, Office of Information Technology

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with Foobar.  If not, see <http://www.gnu.org/licenses/>. 

# Based off 
# https://community.qualys.com/community/developer
# https://www.qualys.com/docs/qualys-api-quick-reference.pdf
# https://www.qualys.com/docs/qualys-api-v2-user-guide.pdf
# https://www.qualys.com/docs/qualys-asset-management-tagging-api-v2-user-guide.pdf

#endregion


#region Connect-Qualys
function Connect-Qualys{
    <#
        .Synopsis
        Connect to Qualys API and get back session $cookie for all other functions

        .DESCRIPTION
            Connect to Qualys API and get back session $cookie for all other functions.

        .PARAMETER qualysCred
            use Get-Credential to create a PSCredential with the username and password of an account that has access to Qualys

        .PARAMETER qualysServer
            FQDN of qualys server, see Qualys documentation, based on wich Qualys Platform you're in.
        
        .PARAMETER assetTagging
            There are two different api endpoints, the new one is Asset Management and Tagging.  Use this switch to get a cookie to make calls to Asset Management and Tagging

        .EXAMPLE
            $cookie = Connect-Qualys -qualysCred $qualysCred -qualysServer $qualysServer
        
        .EXAMPLE
            $cookie = Connect-Qualys -qualysCred $qualysCred -qualysServer $qualysServer -assetTagging
            
        .Notes
            Author: Travis Sobeck, Kyle Weeks
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$qualysCred,

        [Parameter(Mandatory)]
        [string]$qualysServer,

        [switch]$assetTagging
        
    )

    Begin{}
    Process
    {
        $qualysuser = $qualysCred.UserName
        $qualysPswd = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($qualysCred.Password))
   
        if ($assetTagging)
        {
            $auth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($qualysuser+':'+$qualysPswd))	
            $header += @{"Authorization" = "Basic $auth"}	    
            $response = Invoke-RestMethod -Uri "https://$qualysServer/qps/rest/portal/version" -Method GET -SessionVariable cookie -Headers $header
            return $cookie

        }
        else
        {
            ############# Log in ############# 
            ## URL for Logging In/OUT
        
            ## Login/out
            $logInBody = @{
                action = "login"
                username = $qualysuser
                password = $qualysPswd
            }

            ## Log in SessionVariable captures the cookie
            $uri = "https://$qualysServer/api/2.0/fo/session/"
            $response = Invoke-RestMethod -Headers @{"X-Requested-With"="powershell"} -Uri $uri -Method Post -Body $logInBody -SessionVariable cookie
            return $cookie
        }
        
    }
    End{}
}
#endregion

#region Disconnect-Qualys
function Disconnect-Qualys{
<#
    .Synopsis
       Disconnect Qaulys API Session, this only works on the old API

    .DESCRIPTION
         Disconnect Qaulys API Session, this only works on the old API

    .PARAMETER qualysServer
            FQDN of qualys server, see Qualys documentation, based on wich Qualys Platform you're in.

    .PARAMETER cookie
        Use Connect-Qualys to get session cookie

    .EXAMPLE
        disconnect-Qualys -uri 'https://qualysapi.qualys.com:443/api/2.0/fo/session/' -header (Get-QualysHeader) 
        
    .Notes
        Author: Travis Sobeck
#>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [string]$qualysServer,

        [Parameter(Mandatory)]
        [Microsoft.PowerShell.Commands.WebRequestSession]$cookie
    )

    Begin{}
    Process
    {
        ## Login/out
        $logInBody = @{action = "logout"}
        $return = (Invoke-RestMethod -Headers @{"X-Requested-With"="powershell"} -Uri "https://$qualysServer/api/2.0/fo/session/" -Method Post -Body $logInBody -WebSession $cookie).SIMPLE_RETURN.RESPONSE.TEXT
        if ($return -eq 'Logged out'){return $true}
        else{Write-Warning "Qualys logout issue" + $return}
    }
    End{}
}
#endregion

#region Get-QualysAssetGrp
function Get-QualysAssetGrp{
    <#
        .Synopsis
            Get a list of AssetGroup IDs or the ID for a specific AssetGroup

        .DESCRIPTION
            Get a list of AssetGroup IDs or the ID for a specific AssetGroup

        .PARAMETER id
            Asset Group ID, use this to get a single Asset Group

        .PARAMETER qualysServer
            FQDN of qualys server, see Qualys documentation, based on wich Qualys Platform you're in.

        .PARAMETER cookie
            Use Connect-Qualys to get session cookie

    #>

    [CmdletBinding()]
    Param
    (
        [string]$id,

        [Parameter(Mandatory)]
        [string]$qualysServer,

        [Parameter(Mandatory)]
        [Microsoft.PowerShell.Commands.WebRequestSession]$cookie
    )

    Begin{}
    Process
    {
        $actionBody = @{action = "list"}
        if($id){$actionBody['ids'] = $id}
        [xml]$returnedXML = Invoke-RestMethod -Headers @{"X-Requested-With"="powershell"} -Uri "https://$qualysServer/api/2.0/fo/asset/group" -Method Get -Body $actionBody -WebSession $cookie
        $data = $returnedXML.ASSET_GROUP_LIST_OUTPUT.RESPONSE.ASSET_GROUP_LIST.ASSET_GROUP        
        if($id){$data;$data.TITLE.'#cdata-section';$data.IP_SET}
        else{foreach ($n in 0..($data.Length -1)){"--------------";"Title: " +$data.Get($n).TITLE.'#cdata-section';$data.Get($n);$data.IP_SET}}
    }
    End{}
}
#endregion

#region Get-QualysHostAsset
function Get-QualysHostAsset{
    <#
        .Synopsis
            Get Host Asset

        .DESCRIPTION
            Get Host Asset
            
        .PARAMETER hostID
            ID of a host

        .PARAMETER searchTerm
            part of the name of Host Asset that will be used in a "Contains" search

        .PARAMETER operator
            operator to apply to searchTerm, options are 'CONTAINS','EQUALS','NOT EQUALS'.  NOTE 'EQUALS' IS case sensative!

        .PARAMETER IP
            Get Host Asset by IP address
        
        .PARAMETER filter
            The search section can take a lot of params, see the Qualys Documentation for details.  us the filter PARAMETER to create your own custom search
        
        .PARAMETER qualysServer
            FQDN of qualys server, see Qualys documentation, based on wich Qualys Platform you're in.

        .PARAMETER cookie
            Use Connect-Qualys to get session cookie

        .EXAMPLE
            

        .EXAMPLE
            
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory,ParameterSetName='ID')]
        [string]$hostID,

        [Parameter(Mandatory,ParameterSetName='Search')]
        [string]$searchTerm,

        [Parameter(ParameterSetName='Search')]
        [ValidateSet('CONTAINS','EQUALS','NOT EQUALS')]
        [string]$operator = 'CONTAINS',

        [Parameter(Mandatory,ParameterSetName='ip')]
        [ValidatePattern("\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}")]
        [string]$ip,

        [Parameter(Mandatory,ParameterSetName='filter')]
        [System.Collections.Hashtable]$filter,

        [Parameter(Mandatory)]
        [string]$qualysServer,

        [Parameter(Mandatory)]
        [Microsoft.PowerShell.Commands.WebRequestSession]$cookie
    )

    Begin{}
    Process
    {
        if ($hostID)
        {
            $response = Invoke-RestMethod -Uri "https://$qualysServer/qps/rest/2.0/get/am/hostasset/$hostID" -Method GET -Headers @{'Content-Type' = 'application/json'} -WebSession $cookie
        }
        elseif ($filter)
        {
            $body = $filter | ConvertTo-Json -Depth 5
            $response = Invoke-RestMethod -Uri "https://$qualysServer/qps/rest/2.0/search/am/hostasset" -Method Post -Headers @{'Content-Type' = 'application/json'} -WebSession $cookie -Body $body
        }
        elseif ($ip)
        {
            $body = @{ServiceRequest = @{filters = @{Criteria = @(@{"field" = "address";"operator" = "EQUALS";"value" = $ip})}}} | ConvertTo-Json -Depth 5
            $response = Invoke-RestMethod -Uri "https://$qualysServer/qps/rest/2.0/search/am/hostasset" -Method Post -Headers @{'Content-Type' = 'application/json'} -WebSession $cookie -Body $body
        }
        else
        {
            $body = @{ServiceRequest = @{filters = @{Criteria = @(@{"field" = "name";"operator" = $operator;"value" = $searchTerm})}}} | ConvertTo-Json -Depth 5
            $response = Invoke-RestMethod -Uri "https://$qualysServer/qps/rest/2.0/search/am/hostasset" -Method Post -Headers @{'Content-Type' = 'application/json'} -WebSession $cookie -Body $body
        }
        return $response.ServiceResponse.data.HostAsset
    }
    End{}
}
#endregion

#region Get-QualysReport
function Get-QualysReport{
<#
    .Synopsis
        Download Qualys Report

    .DESCRIPTION
        Download Qualys Report

    .PARAMETER id
        Report ID, use Get-QualysReportList to find the ID

    .PARAMETER qualysServer
            FQDN of qualys server, see Qualys documentation, based on wich Qualys Platform you're in.

    .PARAMETER cookie
        Use Connect-Qualys to get session cookie

    .EXAMPLE
        

    .EXAMPLE
        
#>

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [string]$id,
        
        [Parameter(Mandatory)]
        [string]$outFilePath,

        [Parameter(Mandatory)]
        [string]$qualysServer,

        [Parameter(Mandatory)]
        [Microsoft.PowerShell.Commands.WebRequestSession]$cookie
    )

    Begin{}
    Process
    {
        ### get the format type
        $format = (Get-QualysReportList -qualysServer $qualysServer -cookie $cookie -id $id).OUTPUT_FORMAT
        $outfile = "$outFilePath\qualysReport$ID.$format"
        ## Create URL, see API docs for path  
        $null = Invoke-RestMethod -Headers @{"X-Requested-With"="powershell"} -Uri "https://$qualysServer/api/2.0/fo/report/" -Method get -Body @{action = "fetch";id = "$id"} -WebSession $cookie -OutFile $outfile
    }
    End{return $outfile}
}
#endregion

#region Get-QualysReportList
function Get-QualysReportList{
    <#
        .Synopsis
            Get list of Qualys Reports

        .DESCRIPTION
            Get list of Qualys Reports
            
        .PARAMETER id
            (Optional) Qualys Report ID, use this to get details on a specific ID

        .PARAMETER qualysServer
                FQDN of qualys server, see Qualys documentation, based on wich Qualys Platform you're in.

        .PARAMETER cookie
            Use Connect-Qualys to get session cookie

        .EXAMPLE
            

        .EXAMPLE
            
    #>

    [CmdletBinding()]
    Param
    (
        [string]$id,

        [Parameter(Mandatory)]
        [string]$qualysServer,

        [Parameter(Mandatory)]
        [Microsoft.PowerShell.Commands.WebRequestSession]$cookie
    )

    Begin{}
    Process
    {
        ## Create URL, see API docs for path
        #########################     
        $actionBody = @{action = "list"}
        if($id){$actionBody['id'] = $id}
        [xml]$returnedXML = Invoke-RestMethod -Headers @{"X-Requested-With"="powershell"} -Uri "https://$qualysServer/api/2.0/fo/report/" -Method Get -Body $actionBody -WebSession $cookie
        $data = $returnedXML.REPORT_LIST_OUTPUT.RESPONSE.REPORT_LIST.REPORT
        if($id){$data;$data.TITLE.'#cdata-section'}
        else{foreach ($n in 0..($data.Length -1)){"--------------";"Title: " +$data.Get($n).TITLE.'#cdata-section';$data.Get($n)}}
    }
    End{}
}
#endregion

#region Get-QualysScanList
function Get-QualysScanList{
    <#
        .Synopsis
            Get list of Qualys Scans

        .DESCRIPTION
            Get list of Qualys Scans
            
        .PARAMETER scanRef
            (Optional) Qualys Scan Reference, use this to get details on a specific Scan

        .PARAMETER additionalOptions
            See documentation for full list of additional options and pass in as hashtable

        .PARAMETER brief
            Use this switch to get just the title and Ref for faster searching
        
        .PARAMETER qualysServer
        FQDN of qualys server, see Qualys documentation, based on wich Qualys Platform you're in.

        .PARAMETER cookie
            Use Connect-Qualys to get session cookie

        .EXAMPLE
            

        .EXAMPLE
            
    #>

    [CmdletBinding()]
    Param
    (
        [string]$scanRef,

        [System.Collections.Hashtable]$additionalOptions,

        [switch]$brief,

        [Parameter(Mandatory)]
        [string]$qualysServer,

        [Parameter(Mandatory)]
        [Microsoft.PowerShell.Commands.WebRequestSession]$cookie
    )

    Begin{}
    Process
    {
        ## Create URL, see API docs for path
        #########################
        $actionBody = @{action = "list"}
        if($scanRef){$actionBody['scan_ref'] = $scanRef}
        if($additionalOptions){$actionBody += $additionalOptions}
        [xml]$returnedXML = Invoke-RestMethod -Headers @{"X-Requested-With"="powershell"} -Uri "https://$qualysServer/api/2.0/fo/scan/" -Method Get -Body $actionBody -WebSession $cookie
        $data = $returnedXML.SCAN_LIST_OUTPUT.RESPONSE.SCAN_LIST.SCAN
        if ($brief)
        {
            if($scanRef){$data.TITLE.'#cdata-section';$data.REF}
            else
            {
                foreach ($n in 0..($data.Length -1)){"--------------";$data.Get($n).TITLE.'#cdata-section';$data[$n].REF}
            }
        }
        else
        {
            if($scanRef){"`n--------------`n";"Title: " +$data.TITLE.'#cdata-section';($data | Select-Object REF,TYPE,USER_LOGIN,LAUNCH_DATETIME,DURATION,PROCESSING_PRIORITY,PROCESSED);"State: " + $data.STATUS.STATE;"Target: " + $data.TARGET.'#cdata-section'}
            else
            {
                foreach ($n in 0..($data.Length -1)){"`n--------------`n";"Title: " +$data.Get($n).TITLE.'#cdata-section';($data.Get($n) | Select-Object REF,TYPE,USER_LOGIN,LAUNCH_DATETIME,DURATION,PROCESSING_PRIORITY,PROCESSED);"State: " + $data[$n].STATUS.STATE;"Target: " + $data[$n].TARGET.'#cdata-section'}
            }
        }
    }
    End{}
}
#endregion

#region Get-QualysScanResults
function Get-QualysScanResults{
    <#
        .Synopsis
            Get results of Qualys Scan

        .DESCRIPTION
            Get reults of Qualys Scan
            
        .PARAMETER scanRef
            Qualys Scan Reference, use Get-QualysScanList to find the reference

        .PARAMETER additionalOptions
            See documentation for full list of additional options and pass in as hashtable

        .PARAMETER summary
            Use this switch to get just the title and Ref for faster searching
        
        .PARAMETER qualysServer
            FQDN of qualys server, see Qualys documentation, based on wich Qualys Platform you're in.

        .PARAMETER cookie
            Use Connect-Qualys to get session cookie

        .EXAMPLE
            

        .EXAMPLE
            
    #>

    [CmdletBinding()]
    Param
    (
        [string]$scanRef,

        [System.Collections.Hashtable]$additionalOptions,

        [switch]$brief,

        [Parameter(Mandatory)]
        [string]$qualysServer,

        [Parameter(Mandatory)]
        [Microsoft.PowerShell.Commands.WebRequestSession]$cookie
    )

    Begin{}
    Process
    {
        ## Create URL, see API docs for path
        #########################
        $actionBody = @{action = "fetch";scan_ref = $scanRef;output_format='json'}
        if($additionalOptions){$actionBody += $additionalOptions}
        if($brief){$actionBody += @{mode='brief'}}
        Invoke-RestMethod -Headers @{"X-Requested-With"="powershell"} -Uri "https://$qualysServer/api/2.0/fo/scan/" -Method Get -Body $actionBody -WebSession $cookie
        
    }
    End{}
}
#endregion

#region Get-QualysSchedReportList
function Get-QualysSchedReportList{
    <#
        .Synopsis
            Get a list of Reports Scheduled

        .DESCRIPTION
            Get a list of Reports Scheduled

        .PARAMETER id
            (Optional) Report Schedule ID

        .PARAMETER qualysServer
        FQDN of qualys server, see Qualys documentation, based on wich Qualys Platform you're in.

        .PARAMETER cookie
            Use Connect-Qualys to get session cookie
    #>

    [CmdletBinding()]
    Param
    (
        [string]$id,
        
        [Parameter(Mandatory)]
        [string]$qualysServer,

        [Parameter(Mandatory)]
        [Microsoft.PowerShell.Commands.WebRequestSession]$cookie
    )

    Begin{}
    Process
    {
        ## Create URL, see API docs for path
        #########################      
        $actionBody = @{action = "list"}
        if($id){$actionBody['id'] = $id}
        [xml]$returnedXML = Invoke-RestMethod -Headers @{"X-Requested-With"="powershell"} -Uri "https://$qualysServer/api/2.0/fo/schedule/report" -Method Get -Body $actionBody -WebSession $cookie
        $data = $returnedXML.SCHEDULE_REPORT_LIST_OUTPUT.RESPONSE.SCHEDULE_REPORT_LIST.REPORT
        if($id){$data;$data.TITLE.'#cdata-section';$data.TEMPLATE_TITLE.'#cdata-section';$data.SCHEDULE}
        else{foreach ($n in 0..($data.Length -1)){"--------------";"Title: " +$data.Get($n).TITLE.'#cdata-section';$data.Get($n);$data.Get($n).TEMPLATE_TITLE.'#cdata-section';$data.Get($n).SCHEDULE}}
    }
    End{}
}
#endregion

#region Get-QualysTagCount
function Get-QualysTagCount{
    <#
        .Synopsis
            Get-QualysTagCount

        .DESCRIPTION
            Get-QualysTagCount
            
        .PARAMETER qualysServer
            FQDN of qualys server, see Qualys documentation, based on wich Qualys Platform you're in.

        .PARAMETER cookie
            Use Connect-Qualys to get session cookie
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [string]$qualysServer,

        [Parameter(Mandatory)]
        [Microsoft.PowerShell.Commands.WebRequestSession]$cookie
    )

    Begin{}
    Process
    {
        $response = Invoke-RestMethod -Uri "https://$qualysServer/qps/rest/2.0/count/am/tag" -Method Post -Headers @{'Content-Type' = 'application/json'} -WebSession $cookie
        if ($response.ServiceResponse.count){return $response.ServiceResponse.count}
        else{throw "Error $($response.ServiceResponse)"}
    }
    End{}
}
#endregion

#region Get-QualysTag
function Get-QualysTag{
    <#
        .Synopsis
            Get Qualys Tag(s)

        .DESCRIPTION
            Get Qualys Tag(s)
            
        .PARAMETER tagID
            ID of a tag

        .PARAMETER searchTerm
            part of the name of tag that will be used in a "Contains" search

        .PARAMETER operator
            operator to apply to searchTerm, options are 'CONTAINS','EQUALS','NOT EQUALS'.  NOTE 'EQUALS' IS case sensative!

        .PARAMETER filter
            The search section can take a lot of params, see the Qualys Documentation for details.  us the filter PARAMETER to create your own custom search
        
        .PARAMETER qualysServer
            FQDN of qualys server, see Qualys documentation, based on wich Qualys Platform you're in.

        .PARAMETER cookie
            Use Connect-Qualys to get session cookie
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory,ParameterSetName='ID')]
        [string]$tagID,

        [Parameter(Mandatory,ParameterSetName='Search')]
        [string]$searchTerm,

        [Parameter(ParameterSetName='Search')]
        [ValidateSet('CONTAINS','EQUALS','NOT EQUALS')]
        [string]$operator = 'CONTAINS',

        [Parameter(Mandatory,ParameterSetName='filter')]
        [System.Collections.Hashtable]$filter,

        [Parameter(Mandatory)]
        [string]$qualysServer,

        [Parameter(Mandatory)]
        [Microsoft.PowerShell.Commands.WebRequestSession]$cookie
    )

    Begin{}
    Process
    {
        if ($tagID)
        {
            $response = Invoke-RestMethod -Uri "https://$qualysServer/qps/rest/2.0/get/am/tag/$tagID" -Method GET -Headers @{'Content-Type' = 'application/json'} -WebSession $cookie
        }
        elseif ($filter)
        {
            $body = $filter | ConvertTo-Json -Depth 5
            $response = Invoke-RestMethod -Uri "https://$qualysServer/qps/rest/2.0/search/am/tag" -Method Post -Headers @{'Content-Type' = 'application/json'} -WebSession $cookie -Body $body
        }
        else
        {
            $body = @{ServiceRequest = @{filters = @{Criteria = @(@{"field" = "name";"operator" = $operator;"value" = $searchTerm})}}} | ConvertTo-Json -Depth 5
            $response = Invoke-RestMethod -Uri "https://$qualysServer/qps/rest/2.0/search/am/tag" -Method Post -Headers @{'Content-Type' = 'application/json'} -WebSession $cookie -Body $body
        }
        return $response.ServiceResponse.data.Tag 
    }
    End{}
}
#endregion

#region New-QualysHostAsset
function New-QualysHostAsset{
    <#
        .Synopsis
            Create New Qualys Asset

        .DESCRIPTION
            Create New Qualys Host Asset
        .PARAMETER assetName
            Host Asset's FQDN to be added           
        .PARAMETER tagID
            ID of tag to add at build time        
        .PARAMETER qualysServer
            FQDN of qualys server, see Qualys documentation, based on wich Qualys Platform you're in.

        .PARAMETER cookie
            Use Connect-Qualys to get session cookie      
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [string]$assetName,

        [Parameter(Mandatory)]
        [string]$ip,

        [string]$tagID,

        [Parameter(Mandatory)]
        [string]$qualysServer,

        [Parameter(Mandatory)]
        [Microsoft.PowerShell.Commands.WebRequestSession]$cookie
    )

    Begin{}
    Process
    {
        
        $body = @{ServiceRequest = @{data = @{HostAsset = @{name = $assetName;address=$ip;trackingMethod='IP'}}}}
        if($tagID){$body['ServiceRequest']['data']['HostAsset']['tags'] = @{set=@{TagSimple = @{id = $tagID}}}}
        $body = $body | ConvertTo-Json -Depth 7
        $response = Invoke-RestMethod -Uri "https://$qualysServer/qps/rest/2.0/create/am/hostasset" -Method Post -Headers @{'Content-Type' = 'application/json'} -WebSession $cookie -Body $body
        if ($response.ServiceResponse.responseCode -eq "SUCCESS"){return $response.ServiceResponse.data.HostAsset}
        else{Throw $($response.ServiceResponse.responseErrorDetails.errorMessage)}
    }
    End{}
}
#endregion

#region Invoke-QualysBase
function Invoke-QualysBase{
    <#
        .Synopsis
            Not currently useable
        .DESCRIPTION
            
        .PARAMETER qualysServer
            FQDN of qualys server, see Qualys documentation, based on wich Qualys Platform you're in.

        .PARAMETER cookie
            Use Connect-Qualys to get session cookie

    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [System.Collections.Hashtable]$body,
        
        [Parameter(Mandatory)]
        [string]$method,

        [Parameter(Mandatory)]
        [string]$qualysServer,

        [Parameter(Mandatory)]
        [Microsoft.PowerShell.Commands.WebRequestSession]$cookie
    )

    Begin{}
    Process
    {
        return (Invoke-RestMethod -Headers @{"X-Requested-With"="powershell"} -Uri "https://$qualysServer/api/2.0/fo/" -Method $method -Body $body -WebSession $cookie)
    }
    End{}
}
#endregion

#region New-QualysIP
function New-QualysIP{
    <#
        .Synopsis
            Add an IP to a specific Group

        .DESCRIPTION
            Add an IP to a specific Group

        .PARAMETER qualysServer
            FQDN of qualys server, see Qualys documentation, based on wich Qualys Platform you're in.

        .PARAMETER cookie
            Use Connect-Qualys to get session cookie

    #>
    [CmdletBinding()]
    Param
    (
        [ValidatePattern("\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}")]
        [string]$ip,

        [Parameter(Mandatory)]
        [string]$groupID,

        [Parameter(Mandatory)]
        [string]$qualysServer,

        [Parameter(Mandatory)]
        [Microsoft.PowerShell.Commands.WebRequestSession]$cookie
    )

    Begin{}
    Process
    {
        $actionBody = @{
            action = "list"
            ids = $groupID
        }        
        ## Run your action, WebSession contains the cookie from login
        [xml]$returnedXML = Invoke-RestMethod -Headers @{"X-Requested-With"="powershell"}-Uri "https://$qualysServer/api/2.0/fo/asset/group/" -Method Post -Body $actionBody -WebSession $cookie

        # Single IPs
        [System.Collections.ArrayList]$ips = $returnedXML.ASSET_GROUP_LIST_OUTPUT.RESPONSE.ASSET_GROUP_LIST.ASSET_GROUP.IP_SET.IP
        # IP Ranges, these will take more work to extrapolate 
        [System.Collections.ArrayList]$ipRanges = $returnedXML.ASSET_GROUP_LIST_OUTPUT.RESPONSE.ASSET_GROUP_LIST.ASSET_GROUP.IP_SET.IP_RANGE

        ## break up the ip range strings, extract all the ips .. blah blah
        foreach ($range in $ipRanges)
        {
            $a,$b = $range -split "-"
            $a1,$a2,$a3,[int]$a4 = $a -split "\."
            $b1,$b2,$b3,[int]$b4 = $b -split "\."
            foreach ($i in $a4 .. $b4)
            {
                $newIP = $a1 + "." + $a2 + "." + $a3 + "." + [string]$i
                # add to the array of IPs, check for doubles
                if ($ips -notcontains $newIP){$null = $ips.Add($newIP)}
            }
    
        }
        ########################### now we have a full list of IPs to check against
        ###  check if IP to be added is is in the list
        if ($ips -notcontains $ip)
        {
            $actionBody = @{
                action = "edit"
                id = $groupID
                add_ips = $ip
            }
            [xml]$response = Invoke-RestMethod -Headers @{"X-Requested-With"="powershell"}-Uri "https://$qualysServer/api/2.0/fo/asset/group/" -Method Post -Body $actionBody -WebSession $cookie
            ## check that it worked
            if (-not ($response.SIMPLE_RETURN.RESPONSE.TEXT -eq 'Asset Group Updated Successfully')){throw "Failed to add IP $ip -- $qualysError"}
            else{return $true}
             
        }
        else{return $true}  
    }
    End
    {
        $returnedXML = $null
    }
}
#endregion

#region New-QualysTag
function New-QualysTag{
    <#
        .Synopsis
            Create New Qualys Tag

        .DESCRIPTION
            Create New Qualys Tag
            
        .PARAMETER tagName
            Name of a tag to create
        
        .PARAMETER qualysServer
            FQDN of qualys server, see Qualys documentation, based on wich Qualys Platform you're in.

        .PARAMETER cookie
            Use Connect-Qualys to get session cookie      
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory,ParameterSetName='ID')]
        [string]$tagName,

        [Parameter(Mandatory)]
        [string]$qualysServer,

        [Parameter(Mandatory)]
        [Microsoft.PowerShell.Commands.WebRequestSession]$cookie
    )

    Begin{}
    Process
    {
        ## Validate tage does not already exist

        $body = @{ServiceRequest = @{data = @{Tag = @{name = $tagName}}}} | ConvertTo-Json -Depth 5
        $response = Invoke-RestMethod -Uri "https://$qualysServer/qps/rest/2.0/create/am/tag" -Method Post -Headers @{'Content-Type' = 'application/json'} -WebSession $cookie -Body $body
        if ($response.ServiceResponse.responseCode -eq "SUCCESS"){return $true}
        else{throw ($response | Select-Object *)}
    }
    End{}
}
#endregion

#region Remove-QualysHostAsset
function Remove-QualysHostAsset{
    <#
        .Synopsis
            Remove Qualys Host Asset

        .DESCRIPTION
            Remove New Qualys Host Asset
            
        .PARAMETER assetID
            Host Asset's ID 
        
        .PARAMETER qualysServer
            FQDN of qualys server, see Qualys documentation, based on wich Qualys Platform you're in.

        .PARAMETER cookie
            Use Connect-Qualys to get session cookie      
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [string]$assetID,

        [Parameter(Mandatory)]
        [string]$qualysServer,

        [Parameter(Mandatory)]
        [Microsoft.PowerShell.Commands.WebRequestSession]$cookie
    )

    Begin{}
    Process
    {
        
        $response = Invoke-RestMethod -Uri "https://$qualysServer/qps/rest/2.0/delete/am/hostasset/$assetID" -Method Post -Headers @{'Content-Type' = 'application/json'} -WebSession $cookie
        if ($response.ServiceResponse.responseCode -eq "SUCCESS"){return $true}
        else{throw ($response | Select-Object *)}
    }
    End{}
}
#endregion

#region Remove-QualysHostAssetTag
function Remove-QualysHostAssetTag{
    <#
        .Synopsis
            Remove tag from a Host Asset

        .DESCRIPTION
            Remove tag from a Host Asset
            
        .PARAMETER hostID
            ID of a host

        .PARAMETER tagID
            ID of tag to apply to Host Asset
                
        .PARAMETER qualysServer
            FQDN of qualys server, see Qualys documentation, based on wich Qualys Platform you're in.

        .PARAMETER cookie
            Use Connect-Qualys to get session cookie
      
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [string]$hostID,

        [Parameter(Mandatory)]
        [string]$tagID,

        [Parameter(Mandatory)]
        [string]$qualysServer,

        [Parameter(Mandatory)]
        [Microsoft.PowerShell.Commands.WebRequestSession]$cookie
    )

    Begin{}
    Process
    {
        $body = @{ServiceRequest = @{data = @{HostAsset = @{tags = @{remove = @{TagSimple = @{id = $tagID}}}}}}} | ConvertTo-Json -Depth 7
        $response = Invoke-RestMethod -Uri "https://$qualysServer/qps/rest/2.0/update/am/hostasset/$hostID" -Method Post -Headers @{'Content-Type' = 'application/json'} -WebSession $cookie -Body $body        
        ## the quayls api response is junk, to a get to test it actually got added
        if ($response.ServiceResponse.responseCode -eq 'SUCCESS'){return $true}
        else{Write-Warning $response.ServiceResponse.responseErrorDetails;return $false}
    }
    End{}
}
#endregion

#region Remove-QualysIP
function Remove-QualysIP{
    <#
        .Synopsis
            Remove IP from a group by groupId

        .DESCRIPTION
            Remove IP from a group by groupId
            
        .PARAMETER qualysServer
            FQDN of qualys server, see Qualys documentation, based on wich Qualys Platform you're in.

        .PARAMETER cookie
            Use Connect-Qualys to get session cookie
    #>
    [CmdletBinding()]
    Param
    (
        [ValidatePattern("\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}")]
        [string]$ip,

        [Parameter(Mandatory)]
        [string]$groupID,

        [Parameter(Mandatory)]
        [string]$qualysServer,

        [Parameter(Mandatory)]
        [Microsoft.PowerShell.Commands.WebRequestSession]$cookie
    )

    Begin{}
    Process
    {
        ## Look at passinging in Asset Group (High or regular) and set IP
        #########################
        $actionBody = @{
            action = "edit"
            id = $groupID
            remove_ips = $ip
        }
        [xml]$returnedXML = Invoke-RestMethod -Headers @{"X-Requested-With"="powershell"} -Uri "https://$qualysServer/api/2.0/fo/asset/group/" -Method Post -Body $actionBody -WebSession $cookie
        if ($returnedXML.SIMPLE_RETURN.RESPONSE.TEXT -ne "Asset Group Updated Successfully"){throw "Error - $ip - " + $returnedXML.SIMPLE_RETURN.RESPONSE.TEXT}
        else{return $true}
    }
    End{}
}
#endregion

#region Set-QualysHostAssetTag
function Set-QualysHostAssetTag{
    <#
        .Synopsis
            Set tag on a Host Asset

        .DESCRIPTION
            Set tag on a Host Asset
            
        .PARAMETER hostID
            ID of a host

        .PARAMETER tagID
            ID of tag to apply to Host Asset
                
        .PARAMETER qualysServer
            FQDN of qualys server, see Qualys documentation, based on wich Qualys Platform you're in.

        .PARAMETER cookie
            Use Connect-Qualys to get session cookie
      
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [string]$hostID,

        [Parameter(Mandatory)]
        [string]$tagID,

        [Parameter(Mandatory)]
        [string]$qualysServer,

        [Parameter(Mandatory)]
        [Microsoft.PowerShell.Commands.WebRequestSession]$cookie
    )

    Begin{}
    Process
    {
        $body = @{ServiceRequest = @{data = @{HostAsset = @{tags = @{add = @{TagSimple = @{id = $tagID}}}}}}} | ConvertTo-Json -Depth 7
        $response = Invoke-RestMethod -Uri "https://$qualysServer/qps/rest/2.0/update/am/hostasset/$hostID" -Method Post -Headers @{'Content-Type' = 'application/json'} -WebSession $cookie -Body $body        
        ## the quayls api response is junk, to a get to test it actually got added
        if ($response.ServiceResponse.responseCode -eq 'SUCCESS'){return $true}
        else{return $($response.ServiceResponse.responseErrorDetails.errorMessage)}
    }
    End{}
}
#endregion

#region Update-QualysIP
function Update-QualysIP{
    <#
        .Synopsis
            Update IP asset in Qualys.

        .DESCRIPTION
            Update the FQDN, NetBIOS, and IP tracking info of the asset.

        .PARAMETER cookie
            Use Connect-Qualys to get session cookie

        .PARAMETER fqdn
            Domain validated and tested FQDN of host. something.ad.umn.edu

        .PARAMETER ip
            Valid IP address asset to be updated

        .PARAMETER qualysServer
            FQDN of qualys server, see Qualys documentation, based on wich Qualys Platform you're in.

        .EXAMPLE
            Update-QualysIP -cookie $cookie -ip $ip -fqdn $fqdn -qualysServer $qualysServer

        .NOTES
            Authors: Kyle Weeks



    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [Microsoft.PowerShell.Commands.WebRequestSession]$cookie,

        [ValidatePattern("\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}")]
        [string]$ip,

        [Parameter(Mandatory)]
        [string]$fqdn,

        [Parameter(Mandatory)]
        [string]$qualysServer
    )

    Begin{}
    Process
    {
        $computer = $fqdn.Split('.')[0]
        $body = "action=update&echo_request=1&ips=$ip&tracking_method=IP&host_dns=$fqdn&host_netbios=$computer"

        [xml]$response = Invoke-RestMethod -Headers @{'X-Requested-With'="powershell"} -Uri "https://$qualysServer/api/2.0/fo/asset/ip/" -Method Post -WebSession $cookie -Body $body
        ## check that it worked

        if (-not ($response.SIMPLE_RETURN.RESPONSE.TEXT -eq 'IP successfully updated')){$return = $response.SIMPLE_RETURN.RESPONSE.TEXT; throw "Failed to update IP $ip - $return"}
        else{return $true}

    }
    End
    {
        $response = $null
    }
}
#endregion

#region Update-QualysAssetGroup
function Update-QualysAssetGroup{
    <#
        .Synopsis
            Update Asset Group

        .DESCRIPTION
            Add or remove specific IP address from Asset Group.

        .PARAMETER action
            Action to be performed. Add or delete.

        .PARAMETER cookie
            Use Connect-Qualys to get session cookie

        .PARAMETER ip
            IP address of entry to add/remove

        .PARAMETER groupID
            Asset group ID number to modify

        .PARAMETER qualysServer
            FQDN of qualys server, see Qualys documentation, based on wich Qualys Platform you're in.


    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [ValidateSet('Add','Remove')]
        [string]$action,

        [Parameter(Mandatory)]
        [Microsoft.PowerShell.Commands.WebRequestSession]$cookie,

        [ValidatePattern("\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}")]
        [string]$ip,

        [Parameter(Mandatory)]
        [int]$groupID,

        [Parameter(Mandatory)]
        [string]$qualysServer
    )

    Begin{}
    Process
    {  
        ## Run your action, WebSession contains the cookie from login
        $uri = "https://$qualysServer/api/2.0/fo/asset/group/?action=list&ids=$groupID"
        [xml]$returnedXML = Invoke-RestMethod -Headers @{"X-Requested-With"="powershell"} -Uri $uri -Method Post -WebSession $cookie

        # Single IPs
        [System.Collections.ArrayList]$ips = $returnedXML.ASSET_GROUP_LIST_OUTPUT.RESPONSE.ASSET_GROUP_LIST.ASSET_GROUP.IP_SET.IP
        # IP Ranges, these will take more work to extrapolate 
        [System.Collections.ArrayList]$ipRanges = $returnedXML.ASSET_GROUP_LIST_OUTPUT.RESPONSE.ASSET_GROUP_LIST.ASSET_GROUP.IP_SET.IP_RANGE

        ## break up the ip range strings, extract all the ips part of asset group.
        foreach ($range in $ipRanges)
        {
            $a,$b = $range -split "-"
            $a1,$a2,$a3,[int]$a4 = $a -split "\."
            $b1,$b2,$b3,[int]$b4 = $b -split "\."
            foreach ($i in $a4 .. $b4)
            {
                $newIP = $a1 + "." + $a2 + "." + $a3 + "." + [string]$i
                # add to the array of IPs, check for doubles
                if ($ips -notcontains $newIP){$null = $ips.Add($newIP)}
            }
    
        }

        ###  check if IP to be added is is in the list
        If ($action -eq 'Remove')
            {
                if ($ips -contains $ip)
                    {
                        $change = 'remove_ips'
                        $uri = "https://$qualysServer/api/2.0/fo/asset/group/?action=edit&id=$groupID&$change=$ip"
                        [xml]$response = Invoke-RestMethod -Headers @{"X-Requested-With"="powershell"}-Uri $uri -Method Post -WebSession $cookie
                        ## check that it worked
                        if (-not ($response.SIMPLE_RETURN.RESPONSE.TEXT -eq 'Asset Group Updated Successfully')){$errorResponse = $response.SIMPLE_RETURN.RESPONSE.TEXT;throw "Failed to update Asset Group IP $ip - $errorResponse"}
                        else{return "Asset Group Updated Successfully"}
                    }
                else{return "IP address $ip was not found in this asset group"} 
            }
        Else
            {
                if ($ips -notcontains $ip)
                                    {
                                        $change = 'add_ips'
                                        $uri = "https://$qualysServer/api/2.0/fo/asset/group/?action=edit&id=$groupID&$change=$ip"
                                        [xml]$response = Invoke-RestMethod -Headers @{"X-Requested-With"="powershell"}-Uri $uri -Method Post -WebSession $cookie
                                        ## check that it worked
                                        if (-not ($response.SIMPLE_RETURN.RESPONSE.TEXT -eq 'Asset Group Updated Successfully')){$errorResponse = $response.SIMPLE_RETURN.RESPONSE.TEXT;throw "Failed to update Asset Group IP $ip - $errorResponse"}
                                        else{return "Asset Group Updated Successfully"}
                                    }
                else{return "IP address $ip was already part of this asset group"} 

            }
    }
    End
    {
        $returnedXML = $null
    }
}
#endregion
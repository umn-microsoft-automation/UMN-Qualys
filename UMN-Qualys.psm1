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

#region Connect-Qualys
function Connect-Qualys{
<#
    .Synopsis
       Connect to Qualys API and get back session $cookie for all other functions

    .DESCRIPTION
        Connect to Qualys API and get back session $cookie for all other functions

    .PARAMETER uri
        This will take the form https://<fqdn>:443/api/<apiversion>/fo

    .PARAMETER header
        Use Get-QualysHeader to get the correctly formatted header for Qualys

    .PARAMETER qualysCred
        use Get-Credential to create a PSCredential with the username and password of an account that has access to Qualys
    
    .EXAMPLE
        $cookie = Connect-Qualys -uri 'https://qualysapi.qualys.com:443/api/2.0/fo/session/' -header (Get-QualysHeader) -qualysCred (Get-Credential)
        
    .Notes
        Author: Travis Sobeck, Kyle Weeks
#>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,HelpMessage="This will take the form https://<fqdn>:443/api/<apiversion>/fo/session")]
        [string]$uri,

        [Parameter(Mandatory=$true,HelpMessage="Use Get-QualysHeader")]
        [System.Collections.Hashtable]$header,

        [Parameter(Mandatory=$true)]
        [System.Management.Automation.PSCredential]$qualysCred
    )

    Begin{}

    Process
    {
        $qualysuser = $qualysCred.UserName
        $qualysPswd = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($qualysCred.Password))
   
        ############# Log in ############# 
        ## URL for Logging In/OUT
        
        ## Login/out
        $logInBody = @{
            action = "login"
            username = $qualysuser
            password = $qualysPswd
        }

        ## Log in SessionVariable captures the cookie
        $uri += 'session/'
        $response = Invoke-RestMethod -Headers $header -Uri $uri -Method Post -Body $logInBody -SessionVariable cookie
        return $cookie
    }

    End{}
}
#endregion

#region disconnect-Qualys
function disconnect-Qualys{
<#
    .Synopsis
       Connect to Qualys API and get back session $cookie for all other functions

    .DESCRIPTION
        Connect to Qualys API and get back session $cookie for all other functions

    .PARAMETER uri
        This will take the form https://<fqdn>:443/api/<apiversion>/fo

    .PARAMETER header
        Use Get-QualysHeader to get the correctly formatted header for Qualys

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
        [Parameter(Mandatory=$true,HelpMessage="This will take the form https://<fqdn>:443/api/<apiversion>/fo/session")]
        [string]$uri,

        [Parameter(Mandatory=$true,HelpMessage="Use Get-QualysHeader")]
        [System.Collections.Hashtable]$header,

        [Parameter(Mandatory=$true)]
        [Microsoft.PowerShell.Commands.WebRequestSession]$cookie
    )

    Begin{}

    Process
    {
        ## Login/out
        $logInBody = @{
            action = "logout"
            username = $qualysuser
            password = $qualysPswd
        }

        ## Log in SessionVariable captures the cookie
        $uri += 'session/'
        Invoke-RestMethod -Headers $header -Uri $uri -Method Post -Body $logInBody -WebSession $cookie
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

    .PARAMETER uri
        This will take the form https://<fqdn>:443/api/<apiversion>/fo see Qualys documentation for specifics

    .PARAMETER header
        Use Get-QualysHeader to get this

    .PARAMETER cookie
        Use Connect-Qualys to get session cookie

    .EXAMPLE
        

    .EXAMPLE
        
#>

    [CmdletBinding()]
    Param
    (
        [string]$id,

        [Parameter(Mandatory=$true,HelpMessage="This will take the form https://<fqdn>:443/api/<apiversion>/fo/session")]
        [string]$uri,

        [Parameter(Mandatory=$true,HelpMessage="Use Get-QualysHeader")]
        [System.Collections.Hashtable]$header,

        [Parameter(Mandatory=$true)]
        [Microsoft.PowerShell.Commands.WebRequestSession]$cookie
    )

    Begin{}
    Process
    {
        ## Create URL, see API docs for path
        #########################
        $uri += "asset/group"      
        $actionBody = @{action = "list"}
        if($id){$actionBody['ids'] = $id}
        [xml]$returnedXML = Invoke-RestMethod -Headers $header -Uri $uri -Method Get -Body $actionBody -WebSession $cookie
        $data = $returnedXML.ASSET_GROUP_LIST_OUTPUT.RESPONSE.ASSET_GROUP_LIST.ASSET_GROUP        
        if($id){$data;$data.TITLE.'#cdata-section';$data.IP_SET}
        else{foreach ($n in 0..($data.Length -1)){"--------------";"Title: " +$data.Get($n).TITLE.'#cdata-section';$data.Get($n);$data.IP_SET}}
    }
    End{}
}
#endregion

#region Get-QualysHeader
function Get-QualysHeader{
<#
    .Synopsis
       Get header for subsequent calls

    .DESCRIPTION
        Place holder in the event future version require a different header.  Future version may take version number as a param.
    
    .EXAMPLE
        $header = Get-QualysHeader
        
    .Notes
        Author: Travis Sobeck, Kyle Weeks
#>
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    Param
    ()

    Begin{}

    Process
    {
        return @{"X-Requested-With"="powershell"}
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

    .PARAMETER uri
        This will take the form https://<fqdn>:443/api/<apiversion>/fo see Qualys documentation for specifics

    .PARAMETER header
        Use Get-QualysHeader to get this

    .PARAMETER cookie
        Use Connect-Qualys to get session cookie

    .EXAMPLE
        

    .EXAMPLE
        
#>

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true)]
        [string]$id,
        
        [Parameter(Mandatory=$true)]
        [string]$outFilePath,

        [Parameter(Mandatory=$true,HelpMessage="This will take the form https://<fqdn>:443/api/<apiversion>/fo/session")]
        [string]$uri,
        
        [Parameter(Mandatory=$true,HelpMessage="Use Get-QualysHeader")]
        [System.Collections.Hashtable]$header,

        [Parameter(Mandatory=$true)]
        [Microsoft.PowerShell.Commands.WebRequestSession]$cookie
    )

    Begin{}
    Process
    {
        ### get the format type
        $format = (Get-QualysReportList -uri $uri -header $header -cookie $cookie -id $id).OUTPUT_FORMAT
        $outfile = "$outFilePath\qualysReport$ID.$format"
        ## Create URL, see API docs for path
        #########################
        $uri += "report/" 
        $actionBody = @{action = "fetch";id = "$id"}  
        $null = Invoke-RestMethod -Headers $header -Uri $uri -Method get -Body $actionBody -WebSession $cookie -OutFile $outfile
    }
    End{}
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

    .PARAMETER uri
        This will take the form https://<fqdn>:443/api/<apiversion>/fo see Qualys documentation for specifics

    .PARAMETER header
        Use Get-QualysHeader to get this

    .PARAMETER cookie
        Use Connect-Qualys to get session cookie

    .EXAMPLE
        

    .EXAMPLE
        
#>

    [CmdletBinding()]
    Param
    (
        [string]$id,

        [Parameter(Mandatory=$true,HelpMessage="This will take the form https://<fqdn>:443/api/<apiversion>/fo/session")]
        [string]$uri,

        [Parameter(Mandatory=$true,HelpMessage="Use Get-QualysHeader")]
        [System.Collections.Hashtable]$header,

        [Parameter(Mandatory=$true)]
        [Microsoft.PowerShell.Commands.WebRequestSession]$cookie
    )

    Begin{}
    Process
    {
        ## Create URL, see API docs for path
        #########################
        $uri += "report/"      
        $actionBody = @{action = "list"}
        if($id){$actionBody['id'] = $id}
        [xml]$returnedXML = Invoke-RestMethod -Headers $header -Uri $uri -Method Get -Body $actionBody -WebSession $cookie
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
    
    .PARAMETER uri
        This will take the form https://<fqdn>:443/api/<apiversion>/fo see Qualys documentation for specifics

    .PARAMETER header
        Use Get-QualysHeader to get this

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

        [Parameter(Mandatory=$true,HelpMessage="This will take the form https://<fqdn>:443/api/<apiversion>/fo/session")]
        [string]$uri,

        [Parameter(Mandatory=$true,HelpMessage="Use Get-QualysHeader")]
        [System.Collections.Hashtable]$header,

        [Parameter(Mandatory=$true)]
        [Microsoft.PowerShell.Commands.WebRequestSession]$cookie
    )

    Begin{}
    Process
    {
        ## Create URL, see API docs for path
        #########################
        $uri += "scan/"
        $actionBody = @{action = "list"}
        if($scanRef){$actionBody['scan_ref'] = $scanRef}
        if($additionalOptions){$actionBody += $additionalOptions}
        [xml]$returnedXML = Invoke-RestMethod -Headers $header -Uri $uri -Method Get -Body $actionBody -WebSession $cookie
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
            if($scanRef){"`n--------------`n";"Title: " +$data.TITLE.'#cdata-section';($data | Select REF,TYPE,USER_LOGIN,LAUNCH_DATETIME,DURATION,PROCESSING_PRIORITY,PROCESSED);"State: " + $data.STATUS.STATE;"Target: " + $data.TARGET.'#cdata-section'}
            else
            {
                foreach ($n in 0..($data.Length -1)){"`n--------------`n";"Title: " +$data.Get($n).TITLE.'#cdata-section';($data.Get($n) | Select REF,TYPE,USER_LOGIN,LAUNCH_DATETIME,DURATION,PROCESSING_PRIORITY,PROCESSED);"State: " + $data[$n].STATUS.STATE;"Target: " + $data[$n].TARGET.'#cdata-section'}
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
    
    .PARAMETER uri
        This will take the form https://<fqdn>:443/api/<apiversion>/fo see Qualys documentation for specifics

    .PARAMETER header
        Use Get-QualysHeader to get this

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

        [Parameter(Mandatory=$true,HelpMessage="This will take the form https://<fqdn>:443/api/<apiversion>/fo/session")]
        [string]$uri,

        [Parameter(Mandatory=$true,HelpMessage="Use Get-QualysHeader")]
        [System.Collections.Hashtable]$header,

        [Parameter(Mandatory=$true)]
        [Microsoft.PowerShell.Commands.WebRequestSession]$cookie
    )

    Begin{}
    Process
    {
        ## Create URL, see API docs for path
        #########################
        $uri += "scan/"
        $actionBody = @{action = "fetch";scan_ref = $scanRef;output_format='json'}
        if($additionalOptions){$actionBody += $additionalOptions}
        if($brief){$actionBody += @{mode='brief'}}
        Invoke-RestMethod -Headers $header -Uri $uri -Method Get -Body $actionBody -WebSession $cookie | ConvertFrom-Json
        
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

    .PARAMETER uri
        This will take the form https://<fqdn>:443/api/<apiversion>/fo see Qualys documentation for specifics

    .PARAMETER header
        Use Get-QualysHeader to get this

    .PARAMETER cookie
        Use Connect-Qualys to get session cookie

    .EXAMPLE
        

    .EXAMPLE
        
#>

    [CmdletBinding()]
    Param
    (
        [string]$id,
        
        [Parameter(Mandatory=$true,HelpMessage="This will take the form https://<fqdn>:443/api/<apiversion>/fo/session")]
        [string]$uri,

        [Parameter(Mandatory=$true,HelpMessage="Use Get-QualysHeader")]
        [System.Collections.Hashtable]$header,

        [Parameter(Mandatory=$true)]
        [Microsoft.PowerShell.Commands.WebRequestSession]$cookie
    )

    Begin{}
    Process
    {
        ## Create URL, see API docs for path
        #########################
        $uri += "schedule/report"      
        $actionBody = @{action = "list"}
        if($id){$actionBody['id'] = $id}
        [xml]$returnedXML = Invoke-RestMethod -Headers $header -Uri $uri -Method Get -Body $actionBody -WebSession $cookie
        $data = $returnedXML.SCHEDULE_REPORT_LIST_OUTPUT.RESPONSE.SCHEDULE_REPORT_LIST.REPORT
        if($id){$data;$data.TITLE.'#cdata-section';$data.TEMPLATE_TITLE.'#cdata-section';$data.SCHEDULE}
        else{foreach ($n in 0..($data.Length -1)){"--------------";"Title: " +$data.Get($n).TITLE.'#cdata-section';$data.Get($n);$data.Get($n).TEMPLATE_TITLE.'#cdata-section';$data.Get($n).SCHEDULE}}
    }
    End{}
}
#endregion

#region Invoke-QualysBase
function Invoke-QualysBase{
<#
    .Synopsis
        

    .DESCRIPTION
        
    .PARAMETER uri
        This will take the form https://<fqdn>:443/api/<apiversion>/fo see Qualys documentation for specifics

    .PARAMETER header
        Use Get-QualysHeader to get this

    .PARAMETER cookie
        Use Connect-Qualys to get session cookie

    .EXAMPLE
        

    .EXAMPLE
        
#>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true)]
        [System.Collections.Hashtable]$body,
        
        [Parameter(Mandatory=$true)]
        [string]$method,

        [Parameter(Mandatory=$true,HelpMessage="This will take the form https://<fqdn>:443/api/<apiversion>/fo/session")]
        [string]$uri,

        [Parameter(Mandatory=$true,HelpMessage="Use Get-QualysHeader")]
        [System.Collections.Hashtable]$header,

        [Parameter(Mandatory=$true)]
        [Microsoft.PowerShell.Commands.WebRequestSession]$cookie
    )

    Begin{}
    Process
    {
        return (Invoke-RestMethod -Headers $header -Uri $uri -Method $method -Body $body -WebSession $cookie)
    }
    End{}
}
#endregion

#region Remove-QualysIP
function Remove-QualysIP{
<#
    .Synopsis
        

    .DESCRIPTION
        
    .PARAMETER uri
        This will take the form https://<fqdn>:443/api/<apiversion>/fo see Qualys documentation for specifics

    .PARAMETER header
        Use Get-QualysHeader to get this

    .PARAMETER cookie
        Use Connect-Qualys to get session cookie

    .EXAMPLE
        

    .EXAMPLE
        
#>
    [CmdletBinding()]
    Param
    (
        [ValidatePattern("\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}")]
        [string]$ip,

        [Parameter(Mandatory=$true)]
        [string]$groupID,

        [Parameter(Mandatory=$true,HelpMessage="This will take the form https://<fqdn>:443/api/<apiversion>/fo/session")]
        [string]$uri,

        [Parameter(Mandatory=$true,HelpMessage="Use Get-QualysHeader")]
        [System.Collections.Hashtable]$header,

        [Parameter(Mandatory=$true)]
        [Microsoft.PowerShell.Commands.WebRequestSession]$cookie
    )

    Begin{}
    Process
    {
        $uri += 'asset/group/'
        ## Remove IP from Asset Group
        ## Look at passinging in Asset Group (High or regular) and set IP
        #########################
        $actionBody = @{
            action = "edit"
            id = $groupID
            remove_ips = $ip
        }        
            ## Run your action, WebSession contains the cookie from login
        [xml]$returnedXML = Invoke-RestMethod -Headers $header -Uri $uri -Method Post -Body $actionBody -WebSession $cookie
        if ($returnedXML.SIMPLE_RETURN.RESPONSE.TEXT -ne $successResponse){throw "$logInit Error - $ip - $returnedXML.SIMPLE_RETURN.RESPONSE.TEXT"}
        else{return $true}
    }
    End
    {
        $returnedXML = $null
    }
}
#endregion



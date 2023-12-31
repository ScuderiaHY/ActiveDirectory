﻿Function Find-NTLMNetworkLogon {
 <#
.SYNOPSIS
 
    Finds NTLM Logons in the security event log.
    
    Function: Find-NTLMNetworkLogon
    Author: Chris Campbell (@obscuresec)
    License: BSD 3-Clause
    Required Dependencies: None
    Optional Dependencies: None
    
.EXAMPLE

    Find-NTLMNetworkLogon | Where-Object {$_.UserName -notlike "ANONYMOUS LOGON"}

.EXAMPLE

    Find-NTLMNetworkLogon

.LINK

    http://www.obscuresec.com/
#>
    
    #Check for admin rights
    if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
    {
        Write-Error "Not running as admin. Run the script with elevated credentials"
        Return
    }
    
    $Filter = "*[EventData[Data = 'NtLmSsp ']]"
    $Events = Get-WinEvent -Logname "security" -FilterXPath $Filter | Where-Object {$_.ID -eq 4624}
                
    if ($Events) {$Events | ForEach-Object {
                
            $ObjectProps = @{'Hostname' = $_.Properties[11].value;
                             'IPAddress' = $_.Properties[18].value;
                             'UserName' = $_.Properties[5].value;
                             'Domain' = $_.Properties[6].value;
                             'Time' = $_.TimeCreated;
                             'Workstation' = $_.MachineName}
                
            $Results = New-Object -TypeName PSObject -Property $ObjectProps
            Write-Output $Results                                      
        }         
    }

    else {
        Write-Output "No Successful NTLM Network Logons found."
    }
}
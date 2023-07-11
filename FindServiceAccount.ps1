<#===========================================================================================================================
 Script Name: FindServiceAccount.ps1
 Description: Find AD account or any user account that has been set a logon in services.
      Inputs: Remote Computer Name and Name of the service you are looking for.
     Outputs: You can export the result That has name of the Service,Computername,service status in Csv just adding 

     |export-csv c:\scripts\data.csv -Notypeinformation

       Notes: Running it form AD server will give you better result.
      Author: Jiten https://community.spiceworks.com/people/jitensh
Date Created: 26/04/2018
     Credits: 
Last Revised: 10/11/2019
=============================================================================================================================
Instructions
------------
save the script as FindServiceAccount.ps1 under c:\scripts for any folder.
And you can 1st run the script and than.

1. single account.
Find-serviceaccount -computer server1 -user backupaccount

2. Entire domain

Find-serviceaccount -computer server1 -user domainname
Find-serviceaccount -computer server1 -user $env:userdomain


3. Multiple users
$users='user1','user2'
foreach($user in $users)
{
Find-serviceaccount -computer server1 -user $user
}

4. Multiple servers in text file

get-content c:\scripts\list|ForEach{Find-serviceaccount -computer $_ -user account1}

5. Multiple users in text file

get-content c:\scripts\list|ForEach{Find-serviceaccount -computer server1 -user $_}


6. On all servers in domain

$computers=get-adcomputer -filter {operatingsystem -like '*server*'}|select -exp Name 
$result=ForEach($computer in $computers)
{
  Find-serviceaccount -computer $computer -user account1
}

$result

To export as CSV
$result |export-csv c:\scripts\data.csv -NoTypeInformation
<#===========================================================================================================================#>

Function Find-serviceaccount {
   [CmdletBinding()]

    Param (
        [Parameter(Mandatory=$False)][string]$Computer=$env:COMPUTERNAME,
        [Parameter(Mandatory=$True)][string]$user
        )
   
    
If(Test-Connection -ComputerName $computer -BufferSize 16 -Count 1 -ea 0 -quiet)
{

Try
{
$ErrorActionPreference ="stop"
get-wmiobject win32_service -computer $computer  |where{$_.startname -match "$user"}|
 Select Name,@{n="ComputerName";e={$_.systemname}},state,startname

}
Catch
{
        Write-Host "$computer `b" -NoNewline -BackgroundColor red
        Write-Warning $error[0]
}
}

Else
{
       Write-Host "$($computer) is offline" -ForegroundColor Red
}
}
<#
    .SYNOPSIS
    RemoveOrphanedSID-AD.ps1

    .DESCRIPTION
    Remove Orphaned SIDs in Active Directory.

    .LINK
    www.alitajran.com/remove-orphaned-sids/

    .NOTES
    Written by: ALI TAJRAN
    Website:    www.alitajran.com
    LinkedIn:   linkedin.com/in/alitajran

    .CHANGELOG
    V1.00, 11/21/2021 - Initial version
    V1.10, 07/22/2023 - Cleaned up the code
#>

# Define script parameters
param ($Action, $folder, $Opt)

# Get Active Directory Forest information
$Forest = Get-ADRootDSE
$Domain = (Get-ADDomain).distinguishedname
$Conf = $Forest.configurationNamingContext
$Schema = $Forest.SchemaNamingContext
$ForestName = $Forest.rootDomainNamingContext
$DomainDNS = "DC=DomainDnsZones,$ForestName"
$ForestDNS = "DC=ForestDnsZones,$ForestName"

# Get the Domain SID
$domsid = (Get-ADDomain).domainsid.tostring()

# Parse command-line parameters
if (($Action) -and ($Action.ToUpper() -like "/LIST")) { $Remove = $False; $OU = $False }
elseif (($Action) -and ($Action.ToUpper() -like "/LISTOU")) { $Remove = $False; $OU = $True }
elseif (($Action) -and ($Action.ToUpper() -like "/REMOVE")) { $Remove = $True; $OU = $False }
elseif (($Action) -and ($Action.ToUpper() -like "/REMOVEOU")) { $Remove = $True; $OU = $True }
else {
    Write-Host -Foregroundcolor 'Cyan' "SYNTAX: RemoveOrphanedSID-AD.ps1 [/LIST|/REMOVE|/LISTOU|/REMOVEOU[/DOMAIN|/CONF|/SCHEMA|/DOMAINDNS|/FORESTDNS|dn[/RO|/SP]"
    Write-Host -Foregroundcolor 'Cyan' "PARAM1: /LISTOU List only CNs&OUs /LIST List all objects, /REMOVE Clean all objects /REMOVEOU Clean only CNs&OUs"
    Write-Host -Foregroundcolor 'Cyan' "PARAM2: /DOMAIN Actual domain /CONF Conf. Part./SCHEMA /DOMAINDNS /FORESTDNS or a specific DN between double-quotes"
    Write-Host -Foregroundcolor 'Cyan' "OPTION1: /RO lists/Removes only objects with orphaned SIDs of the domain"
    Write-Host -Foregroundcolor 'Cyan' "OPTION2: /SP lists access permissions for all analyzed objects"
    Write-Host -Foregroundcolor 'Cyan' "If no DN is indicated, the current domain will be used"
    Write-Host -Foregroundcolor 'Cyan' "SAMPLE1: RemoveOrphanedSID-AD.ps1 /REMOVEOU /DOMAIN /RO"
    Write-Host -Foregroundcolor 'Cyan' 'SAMPLE2: RemoveOrphanedSID-AD.ps1 /LIST "OU=MySite,DC=Domain,DC=local"'
    Break
}

# Start transcript
$Logs = "C:\temp\RemoveOrphanedSID-AD.txt"
Start-Transcript $Logs -Append -Force

# Determine the object to analyze based on the provided folder or default to the current domain
if (($Folder) -and ($Folder.ToUpper() -like "/CONF")) { $Folder = $Conf }
elseif (($Folder) -and ($Folder.ToUpper() -like "/SCHEMA")) { $Folder = $Schema }
elseif (($Folder) -and ($Folder.ToUpper() -like "/DOMAIN")) { $Folder = $Domain }
elseif (($Folder) -and ($Folder.ToUpper() -like "/DOMAINDNS")) { $Folder = $DomainDNS }
elseif (($Folder) -and ($Folder.ToUpper() -like "/FORESTDNS")) { $Folder = $ForestDNS }
elseif (($Folder) -and ($Folder.ToUpper() -match "DC=*")) { Write-Host "This DistinguishedName will be analyzed: $Folder" -ForegroundColor Cyan }
else { $folder = $domain; Write-Host "This current domain will be analyzed: $Domain" -ForegroundColor Cyan }

Write-Host "Analyzing the following object: $Folder" -ForegroundColor Cyan

# Determine whether to show orphaned SIDs or access permissions based on the provided options
if (($Opt) -and ($Opt.ToUpper() -like "/RO")) { $Show = $False } else { $Show = $True }
if (($Opt) -and ($Opt.ToUpper() -like "/SP")) { $ShowPerms = $True } else { $ShowPerms = $False }

# Function to remove orphaned SIDs from access control lists
function RemovePerms($fold) {
    $f = get-item "Microsoft.ActiveDirectory.Management.dll\ActiveDirectory:://RootDSE/$fold"
    $fName = $f.distinguishedname
    if ($Show) { Write-Host $fname }
    $x = [System.DirectoryServices.ActiveDirectorySecurity](get-ACL "Microsoft.ActiveDirectory.Management.dll\ActiveDirectory:://RootDSE/$f")
    if ($ShowPerms) { Write-Host $x.access | sort -property IdentityReference -unique | ft -auto IdentityReference, IsInherited, AccessControlType, ActiveDirectoryRights }
    $mod = $false
    $OldSID = ""

    foreach ($i in $x.access) {
        if ($i.identityReference.value.tostring() -like "$domsid*") {
            $d = $i.identityReference.value.tostring()
            if ($OldSid -ne $d) { Write-Host "Orphaned SID $d on $fname" -ForegroundColor Yellow; $OldSid = $d }
            if ($Remove) { $x.RemoveAccessRuleSpecific($i) ; $Mod = $True }
        }
    }
    # Write-Host $x.access
    if ($mod) { Set-ACL -aclobject $x -path "Microsoft.ActiveDirectory.Management.dll\ActiveDirectory:://RootDSE/$f"; Write-Host "Orphaned SID removed on $fname" -ForegroundColor Red }
}

# Function to recursively analyze the access control lists of nested folders
Function RecurseFolder($fold) {
    $f = $fold
    # if ($Show) { Write-Host $f }
    if ($OU) { $ListFold = get-childitem "Microsoft.ActiveDirectory.Management.dll\ActiveDirectory:://RootDSE/$f" -force | where { ($_.ObjectClass -like "container") -or ($_.ObjectClass -like "OrganizationalUnit") } }
    else { $ListFold = get-childitem "Microsoft.ActiveDirectory.Management.dll\ActiveDirectory:://RootDSE/$f" -force }
    foreach ($e in $ListFold) {
        $FD = $e.Distinguishedname
        # Write-Host $FD
        RemovePerms $FD     
    }
    foreach ($e in $ListFold) { RecurseFolder($e.Distinguishedname) }
}

# Start analyzing the object
RemovePerms($Folder)
RecurseFolder($Folder)

# Stop transcript
Stop-Transcript

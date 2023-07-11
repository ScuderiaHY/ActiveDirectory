Import-Module ActiveDirectory

$list = Import-CSV C:\temp\delete.csv

forEach ($item in $list) {
    $samAccountName = $item.samAccountName

    #Get DistinguishedName from SamAccountName
    $DN = Get-ADuser -Identity $Samaccountname -Properties DistinguishedName |
        Select-Object -ExpandProperty DistinguishedName

    #Remove object using DN
    Remove-ADObject -Identity $DN -Recursive
}
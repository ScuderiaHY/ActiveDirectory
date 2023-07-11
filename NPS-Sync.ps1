$npsSyncDest = "insv-dc01.calumetlubricants.com"
$npsSyncFolder = "\\$($npsSyncDest)\c$\temp\nps-sync.xml"

Export-NpsConfiguration -Path $npsSyncFolder

Invoke-Command -ComputerName $npsSyncDest -ScriptBlock {Import-NpsConfiguration -Path "C:\temp\nps-sync.xml"}
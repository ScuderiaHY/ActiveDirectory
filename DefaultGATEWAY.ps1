$outputfile = “C:\temp\defGe.csv”
$servers = get-content “C:\temp\aa.txt”
$report = @()

foreach ($Computer in $servers)
{
if(Test-Connection -ComputerName $Computer -Count 1 -ea 0)
{
$Networks = $null
$Networks = Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $Computer -ea silentlycontinue | ? {$_.IPEnabled}

if($Networks)
{
foreach ($Network in $Networks)
{
$IPAddress = $null
$SubnetMask = $null
$DefaultGateway= $null
$DNSServers = $null
$WINSPrimaryserver = $null
$WINSSecondaryserver = $null
$IsDHCPEnabled = $null

$IPAddress = $Network.IpAddress[0]
$SubnetMask = $Network.IPSubnet[0]
$DefaultGateway = $Network.DefaultIPGateway -join ‘,’
$DNSServers = $Network.DNSServerSearchOrder -join ‘,’
$WINSPrimaryserver = $Networks.WINSPrimaryServer
$WINSSecondaryserver = $Networks.WINSSecondaryserver
$IsDHCPEnabled = $false

If($network.DHCPEnabled) { $IsDHCPEnabled = $true }

$OutputObj = New-Object -Type PSObject
$OutputObj | Add-Member -MemberType NoteProperty -Name ComputerName -Value $Computer.ToUpper()
$OutputObj | Add-Member -MemberType NoteProperty -Name IPAddress -Value $IPAddress
$OutputObj | Add-Member -MemberType NoteProperty -Name SubnetMask -Value $SubnetMask
$OutputObj | Add-Member -MemberType NoteProperty -Name Gateway -Value $DefaultGateway
$OutputObj | Add-Member -MemberType NoteProperty -Name IsDHCPEnabled -Value $IsDHCPEnabled
$OutputObj | Add-Member -MemberType NoteProperty -Name DNSServers -Value $DNSServers
$OutputObj | Add-Member -MemberType NoteProperty -Name WINSPrimaryserver -Value $WINSPrimaryserver
$OutputObj | Add-Member -MemberType NoteProperty -Name WINSSecondaryserver -Value $WINSSecondaryserver

$OutputObj
$report += $OutputObj

} # foreach ends here
} # if Networks ends here
else { Write-Warning “Could not find any info on networks/NICs on server $Computer” }

} #if ping ends here
else { Write-Warning “Unable to access/ping $Computer” }

}

$report | Export-Csv $outputfile -NoClobber -NoTypeInformation
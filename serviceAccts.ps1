$targets =get-adcomputer -filter * -Property DNSHostName
$vallist = @()
$i = 1
$count = $targets.count

foreach ($targethost in $targets) {
  write-host $i of $count -  $targethost.DNSHostName
  if (Test-Connection -ComputerName $targethost.DNSHostName -count 2 -Quiet) {
    $vallist += Get-WmiObject Win32_service -Computer $targethost.DNSHostName | select-object systemname, displayname, startname, state
    ++$i
    }
  }
$vallist | export-csv c:\temp\all-services.csv

$filtlist = @("LocalService", "LocalSystem", "NetworkService", "NT AUTHORITY\LocalService", "NT AUTHORITY\NetworkService", "NT AUTHORITY\NETWORK SERVICE", "NT AUTHORITY\LOCAL SERVICE")
$TargetServices = $vallist | Where-Object { $filtlist -notcontains $_.startname }

$TargetServices | export-csv c:\temp\bad-services.csv
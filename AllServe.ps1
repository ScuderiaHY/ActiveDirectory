$servers = get-adcomputer -filter {enabled -eq $true -and operatingsystem -like '*Windows Server*'}
$i=0

$servers.Name | foreach {
                        $i  
                        Write-Progress -Activity %u201CPolling Servers%u201D -status %u201CFound Server $_%u201D ` -percentComplete ($i / $servers.length*100)
                        $job = Get-WmiObject -ComputerName $_ -class win32_service -AsJob | Wait-Job -timeout 20
                        if ($job.State -ne 'Completed')    { Write-output "'$_' timed out after 20 seconds" ; return }
                        receive-job -job $job -OutVariable Server | where-object {$_.startname -notin $exclude} | Select-Object SystemName,Name,Startname
                        }
Get-ADComputer -Filter * | Where-Object {$_.Name -like "PRSV*"} | Select -Property Name | Sort Name

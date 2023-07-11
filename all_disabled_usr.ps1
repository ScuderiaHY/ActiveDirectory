﻿Search-ADAccount –AccountDisabled –UsersOnly –ResultPageSize 2000 –ResultSetSize $null | Select-Object SamAccountName, DistinguishedName, Lastlogondate, Description | Where-Object { ($_.DistinguishedName -notlike "*OU=Disabled Lit Hold Users*") | Export-CSV “C:\Temp\DisabledUsers_nolit.CSV” –NoTypeInformation
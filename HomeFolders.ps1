# Connect to Active Directory (modify the domain name if necessary)
$domainName = "calumetlubricants.com"
$adUsers = Get-ADUser -Filter {HomeDirectory -like "*"} -Server $domainName -Properties SamAccountName, HomeDirectory, DisplayName, Enabled, LitigationHoldEnabled

# Create an array to store user data
$userData = @()

# Loop through the users and store their information in the array
foreach ($user in $adUsers) {
    $username = $user.SamAccountName
    $displayName = $user.DisplayName
    $homeDirectory = $user.HomeDirectory
    $status = if ($user.Enabled) { "Enabled" } else { "Disabled" }
    $litigationHold = if ($user.LitigationHoldEnabled) { "Litigation Hold Enabled" } else { "Litigation Hold Disabled" }

    $userData += [PSCustomObject]@{
        User = $username
        DisplayName = $displayName
        HomeDirectory = $homeDirectory
        Status = $status
        LitigationHold = $litigationHold
    }
}

# Output the array to a CSV file
$outputPath = "C:\temp\anotherone.csv"
$userData | Export-Csv -Path $outputPath -NoTypeInformation

Write-Host "CSV file exported to: $outputPath"

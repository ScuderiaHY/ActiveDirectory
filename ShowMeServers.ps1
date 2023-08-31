# Import Active Directory module if not already loaded
if (-not (Get-Module -Name ActiveDirectory -ErrorAction SilentlyContinue)) {
    Import-Module ActiveDirectory
}

# Define output file path
$outputPath = "C:\temp\srvrs.csv"

# Initialize an array to store server information
$serverInfoArray = @()

# Get a list of all servers in the domain
$servers = Get-ADComputer -Filter {OperatingSystem -like "Windows Server*"} -Properties OperatingSystem,IPv4Address,Enabled,Description

# Iterate through each server
foreach ($server in $servers) {
    $serverInfo = [PSCustomObject]@{
        ServerName    = $server.Name
        OSVersion     = $server.OperatingSystem
        IPAddress     = $server.IPv4Address
        DNSName       = $server.DNSHostName
        ObjectStatus  = if ($server.Enabled) { "Enabled" } else { "Disabled" }
        Description   = $server.Description
    }

    $serverInfoArray += $serverInfo
}

# Export server information to CSV
$serverInfoArray | Export-Csv -Path $outputPath -NoTypeInformation
Write-Host "Server information exported to $outputPath"

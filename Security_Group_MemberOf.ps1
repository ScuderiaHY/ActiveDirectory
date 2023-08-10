# Define the name of the security group
$groupName = "group"

# Get the security group object
$group = Get-ADGroup -Filter { Name -eq $groupName }

if ($group) {
    # Get the list of security groups that this group is a member of
    $memberOfGroups = Get-ADGroup -LDAPFilter "(member=$($group.DistinguishedName))" | Where-Object { $_.ObjectClass -eq 'group' }
    
    # Display the list of security groups
    Write-Host "Security groups that '$groupName' is a member of:"
    foreach ($memberOfGroup in $memberOfGroups) {
        Write-Host "Group: $($memberOfGroup.Name)"
    }
} else {
    Write-Host "Security group '$groupName' not found."
}

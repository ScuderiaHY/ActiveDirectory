$DHCPServers = Get-DhcpServerInDC
foreach ($computername in $DHCPServers)
{
##Export List of DHCP Servers
$computername | Export-Csv C:\temp\DHCPServer.csv -Append -NoTypeInformation
$scopes = Get-DHCPServerv4Scope -ComputerName $computername.DnsName |
Select-Object "Name","SubnetMask","StartRange","EndRange","ScopeID","State"


$serveroptions = Get-DHCPServerv4OptionValue -ComputerName $computername.DnsName | 
Select-Object OptionID,Name,Value,VendorClass,UserClass,PolicyName

ForEach ($scope in $scopes) {
$DHCPServer = $computername.DnsName

##Export List of scopes on each server
$scope | Export-Csv "C:\temp\$DHCPServer-Scopes.csv" -Append -NoTypeInformation

    ForEach ($option in $serveroptions) {
    $lines = @()
    $Serverproperties = @{
    Name = $scope.Name
    SubnetMask = $scope.SubnetMask
    StartRange = $scope.StartRange
    EndRange = $scope.EndRange
    ScopeId = $scope.ScopeId
    OptionID = $option.OptionID
    OptionName = $option.name
    OptionValue =$option.Value
    OptionVendorClass = $option.VendorClass
    OptionUserClass = $option.UserClass
}

$lines += New-Object psobject -Property $Serverproperties
$lines | select Name,SubnetMask,StartRange,EndRange,ScopeId,OptionID,OptionName,{OptionValue},OptionVendorClass,OptionUserClass | Export-Csv C:\temp\$dhcpserver-ServerOption.csv -Append -NoTypeInformation
    }



    $scopeoptions = Get-DhcpServerv4OptionValue -ComputerName $computername.DnsName -ScopeId "$($scope.ScopeId)" -All | 
    Select-Object OptionID,Name,Value,VendorClass,UserClass,PolicyName

    ForEach ($option2 in $scopeoptions) {
    $lines2 = @()
    $Scopeproperties = @{
    Name = $scope.Name
    SubnetMask = $scope.SubnetMask
    StartRange = $scope.StartRange
    EndRange = $scope.EndRange
    ScopeId = $scope.ScopeId
    OptionID = $option2.OptionID
    OptionName = $option2.name
    OptionValue =$option2.Value
    OptionVendorClass = $option2.VendorClass
    OptionUserClass = $option2.UserClass
}

$lines2 += New-Object psobject -Property $Scopeproperties
$lines2 | select Name,SubnetMask,StartRange,EndRange,ScopeId,OptionID,OptionName,{OptionValue},OptionVendorClass,OptionUserClass |Export-Csv C:\temp\$dhcpserver-ScopeOption.csv -Append -NoTypeInformation
    }
  }
 }
$Hours = 777

$DCs = Get-ADDomainController -filter *

$InsecureLDAPBinds = @()

ForEach ($DC in $DCs) {

$Events = Get-WinEvent -ComputerName $DC.Hostname -FilterHashtable @{Logname='Directory Service';Id=2889; StartTime=(Get-Date).AddHours("-$Hours")}

ForEach ($Event in $Events) {

   $eventXML = [xml]$Event.ToXml()

   $Client = ($eventXML.event.EventData.Data[0])

   $IPAddress = $Client.SubString(0,$Client.LastIndexOf(":"))

   $User = $eventXML.event.EventData.Data[1]

   Switch ($eventXML.event.EventData.Data[2])

      {

      0 {$BindType = "Unsigned"}

      1 {$BindType = "Simple"}

      }

   $Row = "" | select IPAddress,User,BindType

   $Row.IPAddress = $IPAddress

   $Row.User = $User

   $Row.BindType = $BindType

   $InsecureLDAPBinds += $Row

   }

}

$InsecureLDAPBinds | Out-Gridview
$users = Get-WmiObject -class win32_groupuser -ComputerName $($env:COMPUTERNAME)
$users = $users | where {$_.GroupComponent -match "Administrator"}

 $users | foreach {

$_.Partcomponent -match ".+Domain\=(.+)\,Name\=(.+)" > $nul

 $Matches[1].trim('"') + "\" + $Matches[2].trim('"')
}
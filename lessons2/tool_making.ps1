$DebugPreference = "silentlycontinue"

function get-inventoryinfo {

BEGIN {}

PROCESS {
$obj = New-Object psobject
$obj | Add-Member noteproperty ComputerName ($_)

$compsystem  = Get-WmiObject win32_computersystem -ComputerName $_

$obj | Add-Member NoteProperty Processors ($compsystem.numberoflogicalprocessors)
$obj | Add-Member NoteProperty Architecture ($compsystem.systemtype)




$os = Get-WmiObject win32_operatingsystem -ComputerName $_

$obj | Add-Member NoteProperty SPVersion ($os.servicepackmajorversion)

$obj | Add-Member NoteProperty Build ($os.buildnumber)

Write-Output $obj


}

END {}



}

"localhost","localhost" | get-inventoryinfo |  Export-Csv "test1.csv"
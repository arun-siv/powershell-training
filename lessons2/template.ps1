function Get-Inventory
{
[cmdletbinding()]
 
param (
[String[]]$ComputerName,
[Switch]$Hardware,
[Switch]$LastPatch,
[Switch]$Roles,
[Switch]$Components,
[Switch]$AllReports
)
 
End {
 
foreach ($ComputerName in $ComputerNames)
{
$PropHash = [ordered]@{}
 
Switch -Regex ($PSBoundParameters.GetEnumerator().
Where({$_.Value -eq $true}).Key)
{
'Hardware|AllReports'
{ 'Manufacturer','Model','CPU','RAM','Disks' | Get-ReportProp }
 
'LastPatch|AllReports'
{ 'LastPatch','LastReboot' | Get-ReportProp }
 
'Roles|AllReports'
{ 'ServerRoles'| Get-ReportProp }
 
'Components|AllReports'
{ 'Components' | Get-ReportProp }
 
} #End Switch
 
[PSCustomObject]$PropHash
 
} #End ForEach
 
} #End End Block
 
 
Begin{
 
[Array]$ComputerNames = $ComputerName
 
function Get-Manufacturer {}
function Get-Model {}
function Get-CPU {}
function Get-Disks {}
function Get-LastPatch {}
function Get-LastReboot {}
function Get-ServerRoles {}
function Get-Components {}
 
filter Get-ReportProp { $PropHash[$_] = Invoke-Expression "Get-$_ $ComputerName" }
 
} #End Begin block
 
Process { $ComputerNames += $_ } #Process Block
 
}#End Get-Inventory Function
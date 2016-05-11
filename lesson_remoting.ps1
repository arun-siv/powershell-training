Enable-PSRemoting

#one to one . Certain dos and donts
Enter-PSSession -ComputerName 10.0.0.10

$s = New-PSSession -ComputerName "SRV1"
Invoke-Command -Session $s -ScriptBlock {$services = Get-Service}
Invoke-Command -Session $s -ScriptBlock {$services | Where-Object {$_.Status -eq "Stopped"}}
Remove-PSSession $s



Invoke-Command -ComputerName 10.0.0.10 -ScriptBlock {Get-Service}  
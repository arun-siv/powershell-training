$nodes = 0..20 |
  % { "10.0.0.$_"}

 $mySession =  New-PSSession -ComputerName $nodes -ea SilentlyContinue

 Invoke-Command -Session $mySession -ScriptBlock{Get-Process | select -First 2}  -ea SilentlyContinue
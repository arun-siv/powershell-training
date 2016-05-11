$nodes = 0..20 |
  % { "10.0.0.$_"}

Invoke-Command -ComputerName $nodes -ScriptBlock {Get-EventLog security | select -First 2} -ErrorAction SilentlyContinue | select PScomputername

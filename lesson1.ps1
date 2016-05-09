#variables
$x  = 10
$x.GetType() #  should return integer


#DIFFERENCE BTW WRITE-OUTPUT AND WRITE HOST
#WRITE-OUTPUT OUTPUTS THE OBJECT INTO THE CONSOLE
Write-Output "hello" | where {$_.length -ge 4 }

Write-Output 1,2,3 | where { $_ -gt 2 }
Write-host 1,2,3 | where { $_ -gt 2 }

#A simple script
write-host "Enter your name:"
$name = Read-Host
write-host "enter the first number:"
[int]$x = Read-Host
write-host "enter the second number:"
[int]$y = Read-Host
$a = $x + $y
write-host "Welcome to Powershell $name  , the sum of numbers you entered is $a"
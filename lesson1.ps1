#variables
$x  = 10
$x.GetType() #  should return integer


#DIFFERENCE BTW WRITE-OUTPUT AND WRITE HOST
#WRITE-OUTPUT OUTPUTS THE OBJECT INTO THE CONSOLE
Write-Output "hello" | where {$_.length -ge 4 }

Write-Output 1,2,3 | where { $_ -gt 2 }
Write-host 1,2,3 | where { $_ -gt 2 }
Write-Host " Enter the operator" 

$op = read-host

$x = 10 

$y = 30

switch ($op ) {

'*'  { "Output is $($x * $y)" } 
'+'  { "Output is $($x + $y)" }
'-'  { "output is $($y - $x)" }
'/'  { "Output is $([math]::round($x/$y , 2))" }

     default { " Exiting the code"  } 
}
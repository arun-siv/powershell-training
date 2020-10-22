$total = 0 
$path = "D:\tutorial-ps"
$file = "access-log"
 get-content($(Join-Path -Path $path -ChildPath $file))|
foreach  {
 $byte = $_.Split()[-1]
  if ($byte -ne "-") { $total = $total + $byte }
}
$total = [math]::Round($total/1mb,2)
$total

$total = 0 
$path = "D:\tutorial-ps"
$file = "access-log"
$content = get-content($(Join-Path -Path $path -ChildPath $file))
 foreach ($c in $content)  {
 $byte = $c.Split()[-1]
  if ($byte -ne "-") { $total = $total + $byte }
}
$total = [math]::Round($total/1mb,2)
Write-Output $total


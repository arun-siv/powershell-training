$path = "D:\Tutorials\tutorial-ps\access-log"

$header = 0..15

$header[0] = "IP"
$header[5] = "PAGE"
$header[7] = "BytesTransferred"

$result = import-csv -path $path -Delimiter ' ' -Header $header | where { ($_.BytesTransferred -ne '-') -and  ($_.PAGE -like '*gif*') } | select IP , PAGE , BytesTransferred

#$result = get-content -path $path  | 
# where {$_  -like '*gif*'  } |
# convertFrom-csv -Delimiter ' ' -Header $header |  foreach { $_.BytesTransferred -ne '-' } | 
# Select IP , PAGE , BytesTransferred

$result.count
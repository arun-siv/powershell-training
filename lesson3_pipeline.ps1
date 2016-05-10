@"
OBJECTS OF POWERSHELL ARE FILTERABLE , SORTABLE  , SELECTABLE AND FORMATABLE
get-service | select name , status

we also studied about where , select , format , and how to include custom properties
"@

Get-Service | where {$_.status -eq "Running" } |
 select name , status, @{n="DisplayName";e={$_.name.toUpper()}} -First 3 | ft -AutoSize

$global:query =@'
SELECT * FROM `listofservices` WHERE 1
'@

$mysqlresults = Get-SqlDataTable $Query

$servicename=(Get-Service).Name
$servicestatus=(Get-Service).Status

for($i=0;$i -le $servicename.Count;$i++)
{
$global:Query = 'INSERT INTO `listofservices` VALUES("'+$servicename[$i]+'","'+$servicestatus[$i]+'")'

$mysqlresults = Get-SqlDataTable $Query
}

$global:Query='SELECT * FROM `listofservices`'
$mysqlresults = Get-SqlDataTable $Query
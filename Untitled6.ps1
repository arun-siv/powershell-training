$a = systeminfo.exe /FO CSV | ConvertFrom-Csv | select 'OS Name' , 'OS Version'

$b = getmac.exe /FO CSV 




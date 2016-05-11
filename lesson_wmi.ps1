Get-WmiObject -Namespace 'root' -Class "__Namespace"

Get-WmiObject -Namespace "root\cimv2" -List

Get-WmiObject -Namespace "root\cimv2" -List | where name -Like 'win*'

Get-WmiObject -Class win32_bios 





Get-WmiObject -Class win32_logicalDisk -Filter "DriveType='3'"
gwmi -Query "select Domain , Manufacturer from win32_computerSystem"

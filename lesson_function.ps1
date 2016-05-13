
function get-Disk {

[CmdletBinding()]

param(
 [parameter(Mandatory=$true,valuefromPipeline=$true)]
 [string[]]$computerName = 'localhost'

)


PROCESS {

foreach ($comp in $computerName ) {

    $disk=Get-WmiObject -Class win32_logicaldisk -Filter "deviceId='c:'" -ComputerName $comp |
          select deviceid ,
                 @{n="Size(GB)";e={$_.size/1gb -as [int]}} , 
                 @{n="FreeSpace(GB)";e={$_.Freespace/1gb -as [int]}}

    $result = [ordered] @{
            
      'Drive' = $disk.deviceid;
      'Size(GB)'= $disk.'Size(GB)';
      'Freespace(GB)' = $disk.'Freespace(GB)'
       
    }

    New-Object -TypeName psobject -Property $result

}


} 

}
$path = "D:\Tutorials\tutorial-ps\access-log"

$a = '86.157.119.197 - - [26/Feb/2008:12:53:36 -0600] "GET /favicon.ico HTTP/1.1" 404 133'
$b = '140.180.132.213 - - [24/Feb/2008:00:08:59 -0600] "GET /ply/ply.html HTTP/1.1" 200 97238'


 $pattern = '^(?<IP>\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}).{0,}(?<Date>\d{2}\/\w{3}\/\d{4}).{0,}\s+(?<PAGE>\/.{0,})\s+.{0,}\s+\d+\s+(?<BytesTransfer>\d+)$'
        
        
 $result =  Get-Content -Path $path -Encoding UTF8  | 
 
 foreach  {  
 
         
        $line = $_
        $hashable = [ordered]@{}

        if ( $line -match $pattern) {
        
        $hashable.ip = $matches.IP
        $hashable.Date = $matches.Date
        $hashable.Page = $matches.PAGE
        $hashable.BytesTransfer = $matches.BytesTransfer

        New-Object -TypeName PSObject -Property $hashable
        }
   
 
 
}
        
 $result.count   

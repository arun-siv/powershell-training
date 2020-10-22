$path = "D:\Tutorials\tutorial-ps\access-log"

 $log = Get-Content -Path $path -Encoding UTF8 -ReadCount 0
        
        
 $result =  foreach ($line in $log) {  
 
         
 
        $data = $line -split " "
              
        $hashable = [ordered]@{} 

        if ( $data[-1] -ne '-') {
        
        $hashable.ip = $data[0]
        $hashable.page = $data[6]
        $hashable.dataTransfer = $data[-1]

        New-Object -TypeName PSObject -Property $hashable
        }
   
 
 
 }
        
       
$result.count
        
        
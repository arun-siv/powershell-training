$path = "D:\Tutorials\tutorial-ps\access-log"

 $result = Get-Content -Path $path | where {$_ -like '*gif*'} | 
        foreach { 
        
        $line = $_ 

        $data = $line -split " "

        if($data[-1] -ne '-'){
    
    
        $hashable = [ordered]@{} 

        $hashable.ip = $data[0]
        $hashable.page = $data[6]
        $hashable.dataTransfer = $data[-1]

        New-Object -TypeName PSObject -Property $hashable
        
        }

        
        } 

        $result.count
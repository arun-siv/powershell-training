$path = 'C:\Users\taiindia\powershell-training'
$file = 'serverlist.txt'

$fullpath = Join-Path -Path $path -ChildPath $file

if (test-path $path\prod.csv) { Clear-Item $path\prod.csv } 
if (test-path $path\dev.csv) { Clear-Item $path\dev.csv }
if (test-path $path\test.csv) { Clear-Item $path\test.csv }


Get-Content $fullpath |  foreach { 

if ( $_ -like '*prod*' ) {
         
         $_ | Out-File -FilePath $path\prod.csv -Append

    } elseif ($_ -like '*dev*') { 
        $_ | out-file -FilePath $path\dev.csv -Append
      
    } else {

      $_ | Out-File -FilePath $path\test.csv -Append
    }
  
    
}
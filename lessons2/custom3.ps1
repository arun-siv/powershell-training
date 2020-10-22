
$csv = @'
Presidency,President,WikipediaEntry,TookOffice,LeftOffice
1,George Washington,http://en.wikipedia.org/wiki/George_Washington,30/04/1789,4/03/1797
2,John Adams,http://en.wikipedia.org/wiki/John_Adams,4/03/1797,4/03/1801
'@

$path = "D:\tutorial-ps\president.csv"


function Create-CustomObject
{
    process {
        $myobj = New-Object PSObject -Property @{
            President = $_.President;
            TookOffice = $_.TookOffice;
            LeftOffice = $_.LeftOffice
        }
        
        Write-Host $myobj
    }
}

import-csv .\president.csv | Create-CustomObject | ft -AutoSize


$csv | set-content $path 

0  | select "abc" , "def " | gm

Get-Content $csv 
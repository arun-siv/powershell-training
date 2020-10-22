
$path = "D:\transfer to new laptop\RDU4FY1617\tp-cfs\cfs.csv"

$file = Import-Csv $path

function ql { $args }

$keyword = ql \bsupport\b \bamc\b  \bannual\b \bSubscription\b \bMaintenence\b



$out = {

 param($string, $pattern)

 

 process {
   
    if ( $string -match $pattern) {
      "AMC"
      
    } else {
    
     "Others"
    }

 }

}


$file |  select * , @{n="AMC/Others";e={& $out $_."PO Description/SW details" $($keyword -join "|" )}}  | Export-Csv 'D:\transfer to new laptop\RDU4FY1617\tp-cfs\cfs_out1.csv' 
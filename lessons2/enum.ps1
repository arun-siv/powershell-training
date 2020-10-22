$replace_nonWords = {$_.short_description -replace '\b\W+\b',' '}


$import_csv = Import-Csv "Ticket Dump 7-4.csv" | select * , @{n='s'; e= {& $replace_nonWords}}

$s = @"
<Device/Application>: unable to login in cyberark,cleared the pin ,provided new passcode ,still same error
                      ''Sign in has failed with the following error: ITATS004E Authentication failure for User ad09664.
"@


$y = @"
Line 1
Line 2
Line 3
Line 4
Line 5
"@

#do loop

$i = 1 
Do {
 "Powershell is Great! $i"
 $i++


} while ($i -le 5 ) #also do-untils


#while
$i = 5
while ($i -ge 1) {
" Scripting is great! $i"
$i--
}


#foreach
1..5 | foreach { Start-Process calc }

#logical construct 
 if ($x -lt $y)
 {
    #command 
 }
 elseif ($a -gt $b)
 {
   #command  
 } else {
  
 }

 
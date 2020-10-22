function start-demo {
[Cmdletbinding()]
 param ( $file=".\demo.txt", 
  [int]$command=0, 
  [System.ConsoleColor]$promptColor="Yellow", 
  [System.ConsoleColor]$commandColor="White", 
  [System.ConsoleColor]$commentColor="Green"
  )



$lines = @(Get-Content $file)
$random = New-Object System.Random
$interkeypause = 200

  
Clear-Host





 Write-Host  -back black -fore yellow @"
<Demo Started :: $(split-path $file -leaf)
"@

for($i = $command ; $i -lt $lines.Length ; $i++) {

  if ($lines[$i].trim(" ").StartsWith("#") -or $lines[$i].trim(" ").Length -eq 0) {
    Write-Host -NoNewLine $("`n[$i]PS> ")
    Write-Host -NoNewLine -Foreground $CommentColor $($($Lines[$i]) + "  ")
    continue
   
  } else {
    Write-Host -NoNewLine $("`n[$i]PS> ")
    $simulatedLine = $lines[$i] + " "
    for($j =  0 ; $j -lt $simulatedLine.length ;$j++) {
    	Write-Host -nonew -fore $commandColor  $simulatedLine[$j]
        start-sleep -Milliseconds $(10 + $random.next($interkeypause))
        
    }#end of for
  } #end of else
  if ($lines[$i] -notmatch '`') {
  $input = read-host
  }
   

  switch ($input) {
 

  "?" { 
   
   write-host "You typed Help"

  }

   default {
   trap [System.Exception] {Write-Error $_; continue;}
   Invoke-Expression ($lines[$i]) | out-default 
   }

  }
  }#end of main for

}#end function
#replace operator is used in strings

$a = @"
the quick brown fox jumps over
the lazy dog
"@

$a -replace "FOX" , "dog"


#contain is used in array

$a = 1, 3 ,4 
$a -contains 1

#other operators
# -eq , -ge , -gt , -le , lt , -or , -and 
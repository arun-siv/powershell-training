﻿Function Get-OddNumber {
param (
$InitialValue,
$ConditionValue
)
For ($i=$InitialValue;$i -lt $ConditionValue;$i++) {
if ($i % 2 -eq 0) {
Continue
}
"Value is $i"
}
}
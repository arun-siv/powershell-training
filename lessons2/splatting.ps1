function Test() {

param(

[string] $vc,
[string] $cluster1,
[string] $cluster2

)

write-host "The vc name is $vc"
Write-host "The cluster name is $cluster1"
Write-host "The cluster name is $cluster2"

}
 
$i = @{

#'cluster1' = 'abc'
'cluster2' ='def'
}


Test -vc 'aaa' -cluster1 'dd' @i




Function Outer-Method
{
    Param
    (
        [string]
        $First,
        
        [string]
        $Second
    )
    
    Write-Host ($First) -NoNewline
    
    Inner-Method @PSBoundParameters
}

Function Inner-Method
{
    Param
    (
        [string]
        $Second
    )
    
    Write-Host (" {0}!" -f $Second)
}

$parameters = @{
    First = "Hello"
    Second = "World"
}

Clear-Host
Outer-Method @parameters
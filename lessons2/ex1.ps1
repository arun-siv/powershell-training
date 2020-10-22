# example to show the function scope

function quickping
{

 ping -n 1 -w 100 $args
}

# example to show what is a lexical scope or block
$n = "PowerShell"
$closure = {"Hello $n"}



#block within function

function greeting
{
$n = "PowerShell"
$n
& {"Hello $n"}

}
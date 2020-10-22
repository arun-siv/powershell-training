
 $TicketMaker = {

        param($transport)

             { 
                param ($name)
                "Here is your Transport ticket via $transport `n Welcome $name"
                }.GetNewClosure()

}


$subTicket = & $TicketMaker "Submarine"

function foo {
  $value = 5
  function bar {
    return $value
  }
  return bar
}
foo

function Get-Block {
  $b = "PowerShell"
  $value = {"Hello $b"}
  return $value
}
$block = Get-Block
& $block
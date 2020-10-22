$allSubscriptions = Get-AzSubscription | Where-Object { $_.State -eq "Enabled" }

foreach ($sub in $allSubscriptions) {
  $subName = $sub.Name
  $subId = $sub.Id
  try {
    Get-AzSubscription -SubscriptionId $subId | Set-AzContext  -ErrorAction stop | Out-Null

    Get-AzResourceGroup  | ForEach-Object {
      # $pattern = "\w{4,}-\w{4,}-\w{4,}-\w{4,}-\w{4,}"
      # $_.ResourceId -match $pattern | Out-Null
      $rg = $_.ResourceGroupName

       if($null -ne $_.tags) {
         $_.tags.GetEnumerator() | ForEach-Object {
          [PSCustomObject]@{
            # SubId = $Matches[0]
            SubId = $subId
            SubName = $subName
            ResourceGroupName = $rg
            key = $_.Key
            value = $_.Value
         }
        }
       }
       else {
        [PSCustomObject]@{
          SubId = $subId
          SubName = $subName
          # SubId = $Matches[0]
          ResourceGroupName = $rg
          key = $null
          value = $null
       }

    }
    }
  }
  catch {
    [PSCustomObject]@{
      SubId = $subId
      SubName = $subName
      # SubId = $Matches[0]
      ResourceGroupName = 'Could not connect to Subscription.Network Issue'
      key = $null
      value = $null
  }
  continue


}
}


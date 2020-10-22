
$allSubscriptions = Get-AzSubscription | Where-Object { $_.State -eq "Enabled" }



foreach($sub in $allSubscriptions) {

  $subName = $sub.Name
  $subId = $sub.Id
  try {
    Get-AzSubscription -SubscriptionId $subId | Set-AzContext -ErrorAction Stop | Out-Null

    Get-AzResource | Where-Object {$_.ResourceType -notmatch "extensions"}| ForEach-Object {
    # $pattern = "\w{4,}-\w{4,}-\w{4,}-\w{4,}-\w{4,}"
    # $_.ResourceId -match $pattern | Out-Null
    $rg = $_.ResourceGroupName
    $resourceName = $_.Name
    $resourceType = $_.ResourceType

     if(($null -ne $_.tags) -or ($_.tags.count -ne 0)) {
       $_.tags.GetEnumerator() | ForEach-Object {
        [PSCustomObject]@{
          SubId = $subId
          SubName = $subName
          ResourceGroup = $rg
          ResourceName = $resourceName
          ResourceType = $resourceType

          # SubId = $Matches[0]
          key = $_.Key
          value = $_.Value
       }

      }
     }
     else {
      [PSCustomObject]@{
          SubId = $subId
          SubName = $subName
          ResourceGroup = $rg
          ResourceName = $resourceName
          ResourceType = $resourceType

          # SubId = $Matches[0]
          key = $null
          value = $null
     }

  }
  }
  } catch {
    [PSCustomObject]@{
      SubId = $subId
      SubName = $subName
      ResourceGroup = 'Could not connect to Subscription.Network Issue'
      ResourceName = 'Could not connect to Subscription.Network Issue'

      # SubId = $Matches[0]
      key = $null
      value = $null
 }

  }



}





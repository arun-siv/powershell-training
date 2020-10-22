function Get-TimeStamp
{
  get-date -Format 'yyyy-MM-dd HH:mm:ss'
}
function Write-OutputLog
{
  param (
    [parameter(position = 0, mandatory = $true, ValueFromPipeLine = $true)]
    [String]$outString,
    [switch]$warning,
    [switch]$toHost,
    [String]$logFile
  )
  $logfilepath = $PSScriptRoot + "\Scenario5\$(get-date -format yyyyMMdd)_log"
  if ($warning)
  {
    Write-Warning $("$(Get-TimeStamp)" + " [WARNING] " + $outString)
  }
  elseif ($toHost)
  {
    Write-Host $("$(Get-TimeStamp)" + " [INFO] " + $outString)
  }
  else
  {
    Write-Verbose $("$(Get-TimeStamp)" + " [VERBOSE] " + $outString)
  }
  if (!$(Test-Path $logFilePath))
  {
    New-Item -ItemType Directory -Force -Path $logfilepath | Out-Null
  }
  if ($logFile)
  {
    "[$(Get-TimeStamp)] $outString" |
    Add-Content -path $(Join-Path -Path $logfilepath -ChildPath $logfile
    )
  }
}

function GenerateDataScenario5
{
  <#
.Synopsis
    The Scenario 5 is for applying costCenter,assetManagerproductCode and client tags to a given
    resource under a given subscription
.Description
    Allows to validate the data
    Check with the existing tenants if the input Subs are valid
    Removes spaces
.Example
#>
  [CmdletBinding()]
  param()
  Begin
  {

    $mytemplate = @"
subscriptionId,resourceName,costCenter,assetManager,productCode,client
10decf3a-85a5-4a35-b6fe-889bfe3278b2,apghacpmweb001,3000,Carl,11000,Client1
10decf3a-85a5-4a35-b6fe-889bfe3278b2,apghaelkelnk001,3000,Carl,12000,Client2
10decf3a-85a5-4a35-b6fe-889bfe3278b2,adghabossdoc02,4000,Mark,13000,Client3
10decf3a-85a5-4a35-b6fe-889bfe3278b2,apghascmhelc001,4000,Mark,13000,Client3
10decf3a-85a5-4a35-b6fe-889bfe3278b2,apghascmcons002,5000,Lisa,13000,Client3
10decf3a-85a5-4a35-b6fe-889bfe3278b2,apghacpmmart001,5000,Lisa,13000,Client3
10decf3a-85a5-4a35-b6fe-889bfe3278b2,apghascmrdsh002,5000,Lisa,14000,Client4
10decf3a-85a5-4a35-b6fe-889bfe3278b2,apghascmweb001,6000,Ken,15000,Client4
10decf3a-85a5-4a35-b6fe-889bfe3278b2,apghascmhelc003,6000,Ken,15000,Client4
"@

    $header1 = @{
      "Name"       = "subscriptionId"
      "Expression" = { $_.subscriptionId | Optimize-Text }
    }

    $header2 = @{
      "Name"       = "resourceName"
      "Expression" = { $_.resourceName | Optimize-Text }
    }
    $header3 = @{
      "Name"       = "costCenter"
      "Expression" = { $_.costCenter | Optimize-Text }
    }
    $header4 = @{
      "Name"       = "assetManager"
      "Expression" = { $_.assetManager | Optimize-Text }
    }

    $header5 = @{
      "Name"       = "productCode"
      "Expression" = { $_.productCode | Optimize-Text }
    }
    $header6 = @{
      "Name"       = "client"
      "Expression" = { $_.client | Optimize-Text }
    }

    function Test-CsvHeader
    {
      [CmdletBinding()]
      param(
        [Parameter(Position = 0, Mandatory = $true)]
        [String []]
        $CsvHeaders
      )

      enum CsvHeaders
      {
        subscriptionId
        resourceName
        costCenter
        assetManager
        productCode
        client
      }
      $condition1 = $([enum]::IsDefined([CsvHeaders], $CsvHeaders[0]))
      $condition2 = $([enum]::IsDefined([CsvHeaders], $CsvHeaders[1]))
      $condition3 = $([enum]::IsDefined([CsvHeaders], $CsvHeaders[2]))
      $condition4 = $([enum]::IsDefined([CsvHeaders], $CsvHeaders[3]))
      $condition5 = $([enum]::IsDefined([CsvHeaders], $CsvHeaders[4]))
      $condition6 = $([enum]::IsDefined([CsvHeaders], $CsvHeaders[5]))


      if ($condition1 -and $condition2 -and $condition3 -and $condition4 -and $condition5 -and $condition6 )
      {
        return $true
      }
      else
      {
        Write-OutputLog "Please check the input file for headers !!" -warning -logFile error.log
        return $false
      }
    }
    function Optimize-Text
    {
      [CmdletBinding()]
      param(
        # Parameter help description
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [String]
        $text
      )
      Begin
      {
      }
      Process
      {
        if ($text -match "\S+")
        { $text.Trim()
        }
      }
      End
      {
      }
    }

  }
  Process
  {
    $CsvData = $mytemplate | ConvertFrom-Csv -Delimiter ","
    if (Test-CsvHeader -CsvHeaders $CsvData[0].psobject.properties.Name)
    {
      $CsvData = $CsvData | Select-Object $header1, $header2, $header3, $header4, $header5, $header6

      if ($AzureSubId = Get-AzureSubId)
      {
        $AzureSubIndex = buildIndex $AzureSubId 'Id'
        $CsvData | ForEach-Object { if ($AzureSubIndex.Contains($_.subscriptionId) )
          { $_ | Where-Object { $_.resourceName }
          } }
      }
      else
      {
        Write-OutputLog "The program did not retrieve any data.Please try later" -warning -logFile error.log
        return
      }
    }

  }

}

function buildIndex($csv, [string]$keyName)
{
  $index = [ordered] @{ }
  foreach ($row in $csv)
  {
    $key = $row.($keyName)
    $data = $index[$key]
    if ($data -is [Collections.ArrayList])
    {
      $data.add($row) >$null
    }
    elseif ($data)
    {
      $index[$key] = [Collections.ArrayList]@($data, $row)
    }
    else
    {
      $index[$key] = $row
    }

  }
  $index
}

function Get-AzureSubId
{

  # Get the Subs for all tenants
  try
  {

    $AzureSubId = Get-AzSubscription -ErrorAction Stop | Where-Object { $_.State -eq "Enabled" }
    Write-Output $AzureSubId

  }
  catch #[System.Net.Http.HttpRequestException]
  {
    Write-OutputLog "Connection issue.Azure portal not reachable." -warning -logFile error.log
    Write-outputlog "Error details $($_)" -logFile error.log
    return
  }

}

function Set-TaggingScenario5
{
  [cmdletBinding()]
  param (
    $csvHash = [ordered]@{ }

  )
  foreach ($sub in $csvHash.Keys)
  {
    try
    {
      $subContext = Get-AzSubscription -SubscriptionId $sub  -ErrorAction Stop | Set-AzContext
      Write-OutputLog "Connected to the $sub" -logFile common.log
      Write-Host ""
      write-host ""
      write-host "**************************************************************************************"
      write-host "Switching to Azure Subscription $($subcontext.Name)" -BackgroundColor red -ForegroundColor Yellow
      write-host "**************************************************************************************"
      write-host ""
      write-host ""


      foreach ($resource in $csvHash[$sub].resourceName)
      {
        try
        {
          $r = Get-AzResource -ResourceName $resource -ErrorAction Stop |
          Where-Object { $_.ResourceType -notmatch "extensions" }

          Write-OutputLog "Connected to the resource $($r.Name) RG $($r.ResourceGroupName) in the SUBID $sub" -logFile common.log
          write-host ""
          write-host "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
          write-host "[Subscription]::$sub  [Resource Group]::$($r.ResourceGroupName)  [Resource]::$($r.Name)" -BackgroundColor Yellow -ForegroundColor Red
          write-host "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
          write-host ""
          $resourcetags = $r.Tags
          if ($resourcetags)
          {
            $resourcetags['costCenter'] = $($csvHash[$sub] |
              Where-Object { $_.resourceName -eq $resource }).costCenter

            $resourcetags['assetManager'] = $($csvHash[$sub] |
              Where-Object { $_.resourceName -eq $resource }).assetManager

            $resourcetags['productCode'] = $($csvHash[$sub] |
              Where-Object { $_.resourceName -eq $resource }).productCode

            $resourcetags['client'] = $($csvHash[$sub] |
              Where-Object { $_.resourceName -eq $resource }).client

            Set-AzResource -Tag $resourcetags -ResourceId $r.ResourceId -Force | Out-Null

            Write-OutputLog "Updated Tags.costCenter,assetManager,productCode and client Tag applied" -toHost -logFile common.log
          }
          else
          {
            $resourcetags = @{ }
            $resourcetags['costCenter'] = $($csvHash[$sub] |
              Where-Object { $_.resourceName -eq $resource }).costCenter

            $resourcetags['assetManager'] = $($csvHash[$sub] |
              Where-Object { $_.resourceName -eq $resource }).assetManager

            $resourcetags['productCode'] = $($csvHash[$sub] |
              Where-Object { $_.resourceName -eq $resource }).productCode

            $resourcetags['client'] = $($csvHash[$sub] |
              Where-Object { $_.resourceName -eq $resource }).client

            Set-AzResource -Tag $resourcetags -ResourceId $r.ResourceId -Force | Out-Null

            Write-OutputLog "Added Tags.costCenter,assetManager,productCode and client Tag applied" -toHost -logFile common.log
          }
        }
        catch
        {
          Write-OutputLog "Couldn't apply tag to  $($r.Name) under $($r.ResourceGroupName) and $sub" -warning -logFile error.log
          Write-outputlog "Error details $($_)" -logFile error.log
          continue
        }
      }

    }
    catch
    {
      Write-OutputLog "Couldn't set the Subscription context to $sub" -warning -logFile error.log
      Write-outputlog "Error details $($_)" -logFile error.log
      Continue
    }
  }
  Write-OutputLog "***********************FINISHED************************************" -logFile common.log
  Write-OutputLog "***********************FINISHED************************************" -logFile error.log
}


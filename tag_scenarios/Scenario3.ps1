
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
  $logfilepath = $PSScriptRoot + "\Scenario3\$(get-date -format yyyyMMdd)_log"
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
function GenerateDataScenario3
{
  <#
.Synopsis
    The Scenario 3 is for applying costCenter and assetManager tags to all RG in a subscription
    If you want to apply all the tags(costCenter,assetManager,productCode,client)
    to all resources within a subscription please use scenario1
.Description
    Allows to validate the data
    Check with the existing tenants if the input Subs are valid
    Removes spaces
    Make sure the input data doesnt have any Blank data
.Example
  #>
  [CmdletBinding()]
  param()
  Begin
  {

    $mytemplate = @"
subscriptionId,costCenter,assetManager
4464d424-b12c-4fcc-853d-6d1c00640cc7,12000,Carol
7484ec2d-e33a-478e-b532-1fbcd9980b2e,10000,Nick
56ef2c84-7e57-4c9f-8d23-787f4c9ae9d2,20000,Jose
b61837ec-d496-4bac-9cd2-89819fdd2ffd,23000,Chris
b61837ec-d496-4bac-9cd2-89819fdd2ffd,25000,Mary
b61837ec-d496-5edf-9cd2-89819fdd2ggd,24000,Mary
b42434ed-d494-5edf-9cc2-89819fdd2ggd,24002,Mary
"@

    $header1 = @{
      "Name"       = "subscriptionId"
      "Expression" = { $_.subscriptionId | Optimize-Text }
    }

    $header2 = @{
      "Name"       = "costCenter"
      "Expression" = { $_.costCenter | Optimize-Text }
    }

    $header3 = @{
      "Name"       = "assetManager"
      "Expression" = { $_.assetManager | Optimize-Text }
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
        costCenter
        assetManager

      }
      $condition1 = $([enum]::IsDefined([CsvHeaders], $CsvHeaders[0]))
      $condition2 = $([enum]::IsDefined([CsvHeaders], $CsvHeaders[1]))
      $condition3 = $([enum]::IsDefined([CsvHeaders], $CsvHeaders[2]))


      if ($condition1 -and $condition2 -and $condition3 )
      {
        return $true
      }
      else
      {
        Write-OutputLog "Please check the input file for headers !!" -warning -logFile error.log
        Write-OutputLog "Please ensure use subscriptionId,costCenter,assetManager as headers !!" -toHost
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
      $CsvData = $CsvData | Select-Object $header1, $header2, $header3

      if ($AzureSubId = Get-AzureSubId)
      {
        $AzureSubIndex = buildIndex $AzureSubId 'Id'
        $CsvData | ForEach-Object { if ($AzureSubIndex.Contains($_.subscriptionId) )
          { $_
          } }
      }
      else
      {
        Write-OutputLog "The program did not retrieve any data.Please try later" -warning -logFile error.log
        return
      }
    }

  }

  End
  {
  }

}


function buildIndex($csv, [string]$keyName)
{
  $index = [ordered] @{ }
  foreach ($row in $csv)
  {
    $key = $row.($keyName)
    $index[$key] = [Collections.ArrayList]@($row)
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
    Write-outputlog "Error details $($_)" -logFile errordetails.log
    return
  }

}

function Set-TaggingScenario3
{
  [CmdletBinding()]
  param (
    $csvHash = [ordered]@{ }
  )
  foreach ($sub in $csvHash.Keys)
  {
    try
    {
      $subContext = Get-AzSubscription -SubscriptionId $sub  -ErrorAction Stop | Set-AzContext
      Write-OutputLog "Connected to the $sub" -logFile common.log
      write-host ""
      write-host ""
      Write-Host "**************************************************************************************"
      Write-host "Switching to Azure Subscription $($subcontext.Name)" -ForegroundColor Yellow -BackgroundColor Red
      Write-Host "**************************************************************************************"
      write-host ""
      write-host ""
      try
      {
        Get-AzResourceGroup -ea Stop |
        ForEach-Object {
          Write-OutputLog "Connected to RG $($_.ResourceGroupName) and in SUBID $sub" -logFile common.log

          $tags = $_.Tags
          if ($tags)
          {
            $tags['costCenter'] = $($csvHash[$sub].costCenter)
            $tags['assetManager'] = $($csvHash[$sub].assetManager)
            # Set-AzResourceGroup -Tag $tags -Name $_.ResourceGroupName
            Write-OutputLog "Updated Tags. costCenter and assetManager Tag applied" -toHost -logFile common.log
          }
          else
          {
            $tags = @{ }
            $tags['costCenter'] = $($csvHash[$sub].costCenter)
            $tags['assetManager'] = $($csvHash[$sub].assetManager)
            # Set-AzResourceGroup -Tag $tags -Name $_.ResourceGroupName
            Write-OutputLog "New Tags. costCenter and assetManager Tag applied" -tohost -logFile common.log
          }

        }
      }

      catch
      {
        Write-OutputLog "Couldn't apply the tags to $($_.ResourceGroupName) and $sub" -warning -logFile error.log
        Write-outputlog "Error details $($_)" -logFile errordetails.log
        Continue
      }

    }

    catch
    {
      Write-OutputLog "Couldn't set the Subscription context to $sub" -warning -logFile error.log
      Write-outputlog "Error details $($_)" -logFile errordetails.log
      Continue
    }

  }
  Write-OutputLog "**************************************************************" -logFile common.log
  Write-OutputLog "**************************************************************" -logFile error.log

}
# $csv = GenerateDataScenario3
# $csvHash = buildIndex $csv 'subscriptionId'
# Set-TaggingScenario3 $csvHash

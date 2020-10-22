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
  $logfilepath = $PSScriptRoot + "\Scenario4\$(get-date -format yyyyMMdd)_log"
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

function GenerateDataScenario4
{
<#
.Synopsis
    The Scenario 4 is for applying costCenter and assetManager tags to a given
    resource group.

    If you want to apply all the tags (costCenter,assetManager,produceCode,client)
    to all resources within a RG please use scenario2
.Description
    Allows to validate the data
    Check with the existing tenants if the input Subs are valid
    Removes spaces
    Make sure the resource group data doesnt have any Blank data
.Example
#>
[CmdletBinding()]
param()
  Begin
  {

    $mytemplate = @"
subscriptionId,resourceGroupName,costCenter,assetManager
10decf3a-85a5-4a35-b6fe-889bfe3278b2,a-d-gha-bossnet-rg,12000,Carol
10decf3a-85a5-4a35-b6fe-889bfe3278b2,a-d-gha-elk-rg-1.0,22000,Mark
10decf3a-85a5-4a35-b6fe-889bfe3278b2,a-d-gha-scm-rg-17.3,10000,Nick
"@

    $header1 = @{
      "Name"       = "subscriptionId"
      "Expression" = { $_.subscriptionId | Optimize-Text }
    }

    $header2 = @{
      "Name"       = "resourceGroupName"
      "Expression" = { $_.resourceGroupName | Optimize-Text }
    }


    $header3 = @{
      "Name"       = "costCenter"
      "Expression" = { $_.costCenter | Optimize-Text }
    }

    $header4 = @{
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
        resourceGroupName
        costCenter
        assetManager

      }
      $condition1 = $([enum]::IsDefined([CsvHeaders], $CsvHeaders[0]))
      $condition2 = $([enum]::IsDefined([CsvHeaders], $CsvHeaders[1]))
      $condition3 = $([enum]::IsDefined([CsvHeaders], $CsvHeaders[2]))
      $condition4 = $([enum]::IsDefined([CsvHeaders], $CsvHeaders[3]))

      if ($condition1 -and $condition2 -and $condition3 -and $condition4)
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
      $CsvData = $CsvData | Select-Object $header1, $header2, $header3,$header4

      if ($AzureSubId = Get-AzureSubId)
      {
        $AzureSubIndex = buildIndex $AzureSubId 'Id'
        $CsvData | ForEach-Object { if ($AzureSubIndex.Contains($_.subscriptionId) )
          { $_ | Where-Object {$_.resourceGroupName}
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

function Set-TaggingScenario4
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


      foreach ($rg in $csvHash[$sub].resourceGroupName)
      {

        try
        {
          $RgTags = (Get-AzResourceGroup -Name $rg -ErrorAction Stop).Tags

          Write-OutputLog "Connected to the RG $rg in the SUBID $sub" -logFile common.log
          write-Host "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
          Write-Host ""
          write-Host "[Subscription]::$sub  [Resource Group]::$rg" -BackgroundColor white -ForegroundColor DarkCyan
          write-host ""
          write-Host "|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
          if ($RgTags)
          {
            $RgTags['costCenter'] = $($csvHash[$sub] |
                Where-Object { $_.resourceGroupName -eq $rg }).costCenter

            $RgTags['assetManager'] = $($csvHash[$sub] |
                Where-Object { $_.resourceGroupName -eq $rg }).assetManager

            Set-AzResourceGroup -Tag $RgTags -Name $rg
            Write-OutputLog "Updated Tags. costCenter and assetManager Tag applied" -toHost -logFile common.log
          }
          else
          {
            $RgTags = @{ }
            $RgTags['costCenter'] = $($csvHash[$sub] |
            Where-Object { $_.resourceGroupName -eq $rg }).costCenter

           $RgTags['assetManager'] = $($csvHash[$sub] |
            Where-Object { $_.resourceGroupName -eq $rg }).assetManager

           Set-AzResourceGroup -Tag $RgTags -Name $rg | Out-Null

            Write-OutputLog "New Tags. costCenter and assetManager Tag applied" -toHost -logFile common.log


          }
        }
        catch
        {
          Write-OutputLog "Couldn't apply tag to $rg and $sub" -warning -logFile error.log
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


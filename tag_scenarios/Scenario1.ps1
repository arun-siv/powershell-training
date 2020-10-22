
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
  $logfilepath = $PSScriptRoot + "\Scenario1\$(get-date -format yyyyMMdd)_log"
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

function GenerateDataScenario1
{
  <#
.Synopsis
    The Scenario 1 is for applying costCenter and assetManager tags to
    all resource groups and costcenter , assetManager, productCode and client
    to resources given a subscription data
.Description
    ->Allows to validate the data
    ->Check with the existing tenants if the input Subs are valid
    ->Removes spaces
    ->Make sure the input data doesnt have any Blank data
.Example
#>
  [CmdletBinding()]
  param()
  Begin
  {

    $mytemplate = @"
subscriptionId,costCenter,assetManager,productCode,client
4464d424-b12c-4fcc-853d-6d1c00640cc7,12000,Carol,1111,xyz
7484ec2d-e33a-478e-b532-1fbcd9980b2e,10000,Nick,2222,abc
56ef2c84-7e57-4c9f-8d23-787f4c9ae9d2,20000,Jose
b61837ec-d496-4bac-9cd2-89819fdd2ffd,23000,Chris,4444,ijk
b61837ec-d496-4bac-9cd2-89819fdd2ffd,25000,Mary,5555,kkkkk
b61837ec-d496-5edf-9cd2-89819fdd2ggd,24000,Mary
b42434ed-d494-5edf-9cc2-89819fdd2ggd,24002,Mary,9999
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
    $header4 = @{
      "Name"       = "productCode"
      "Expression" = { $_.productCode | Optimize-Text }
    }
    $header5 = @{
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


      if ($condition1 -and $condition2 -and $condition3 -and $condition4 -and $condition5 )
      {
        return $true
      }
      else
      {
        Write-Verbose "Please check the input file!!"
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
      $CsvData = $CsvData |
      Select-Object  $header1,
      $header2,
      $header3,
      $header4,
      $header5
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
function Set-TaggingScenario1
{
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
        $groups = Get-AzResourceGroup -ea Stop

        foreach ($rg in $groups)
        {

          Write-OutputLog "Connected to the RG $rg in the SUBID $sub" -logFile common.log
          Write-OutputLog "<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>"  -logFile common.log

          write-Host "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
          write-host ""
          write-Host "[Subscription]::$sub  [Resource Group]::$($rg.ResourceGroupName)" -BackgroundColor white -ForegroundColor DarkCyan
          write-host ""
          write-Host "|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"

          $tags = $rg.Tags
          if ($tags)
          {
            $tags['costCenter'] = $($csvHash[$sub]).costCenter
            $tags['assetManager'] = $($csvHash[$sub]).assetManager
            # Set-AzResourceGroup -Tag $RgTags -Name $rg.ResourceGroupName
            Write-OutputLog "Updated Tags. costCenter and assetManager Tag applied" -toHost -logFile common.log
          }
          else
          {
            $tags = @{ }
            $tags['costCenter'] = $($csvHash[$sub]).costCenter
            $tags['assetManager'] = $($csvHash[$sub]).assetManager
            # Set-AzResourceGroup -Tag $RgTags -Name $rg.ResourceGroupName
            Write-OutputLog "New Tags. costCenter and assetManager Tag applied" -toHost -logFile common.log
          }
          try
          {
            $resources = Get-AzResource -ResourceGroupName $rg.ResourceGroupName -ErrorAction Stop |
               Where-Object {$_.ResourceType -notmatch "extensions" }
            foreach ($r in $resources)
            {
              Write-OutputLog "Connected to the resource $($r.Name) RG $($rg.ResourceGroupName) in the SUBID $sub" -logFile common.log
              write-host ""
              write-host "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
              write-host "[Subscription]::$sub  [Resource Group]::$($rg.ResourceGroupName)  [Resource]::$($r.Name)" -BackgroundColor Yellow -ForegroundColor Red
              write-host "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
              write-host ""
              $resourcetags = $r.Tags
              if ($resourcetags)
              {
                $resourcetags['costCenter'] = $($csvHash[$sub]).costCenter
                $resourcetags['assetManager'] = $($csvHash[$sub]).assetManager
                $resourcetags['productCode'] = $($csvHash[$sub]).productCode
                $resourcetags['client'] = $($csvHash[$sub]).client
                # Set-AzResource -Tag $resourcetags -ResourceId $r.ResourceId -Force | Out-Null
                Write-OutputLog "Updated Tags.cosCenter,assetManger,productCode and client Tag applied" -toHost -logFile common.log
              }
              else
              {
                $resourcetags = @{ }
                $resourcetags['costCenter'] = $($csvHash[$sub]).costCenter
                $resourcetags['assetManager'] = $($csvHash[$sub]).assetManager
                $resourcetags['productCode'] = $($csvHash[$sub]).productCode
                $resourcetags['client'] = $($csvHash[$sub]).client
                # Set-AzResource -Tag $resourcetags -ResourceId $r.ResourceId -force | out-null
                Write-OutputLog "Updated Tags.costCenter,assetManger,productCode and client Tag applied" -toHost -logFile common.log
              }

            }

          }
          catch
          {
            Write-OutputLog "Couldn't apply tag to  $($r.Name) under $rg and $sub" -warning -logFile error.log
            Write-outputlog "Error details $($_)" -logFile error.log
            continue
          }
        }
      }
      catch
      {
        Write-OutputLog "Couldn't apply tag to $rg and $sub" -warning -logFile error.log
        Write-outputlog "Error details $($_)" -logFile error.log
        continue
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
# $csv = GenerateDataScenario1
# $csvHash = buildIndex $csv 'subscriptionId'
# Set-TaggingScenario1 $csvHash


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
  $logfilepath = $PSScriptRoot + "\Scenario2\$(get-date -format yyyyMMdd)_log"
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

function GenerateDataScenario2
{
  <#
.Synopsis
    The Scenario 2 is for applying costCenter and assetManager tags to a given
    resource group and the costcenter,assetmanager, productCode and client to all
    resources under that resource groups
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
subscriptionId,resourceGroupName,costCenter,assetManager,productCode,client
4464d424-b12c-4fcc-853d-6d1c00640cc7,a-p2-sdo-nas-rg-001,12000,Carol,1111,Shared
4464d424-b12c-4fcc-853d-6d1c00640cc7,a-p2-sdo-test-rg-001,22000,Mark,,
7484ec2d-e33a-478e-b532-1fbcd9980b2e,a-p2-sdo-test-rg-001,10000,Nick,2222,abc
7484ec2d-e33a-478e-b532-1fbcd9980b2e,a-d-sws-bp-rg-1.0,10000,Nick,2222,abc
7484ec2d-e33a-478e-b532-1fbcd9980b2e,a-d-sws-med-rg-1.0-18.1,10000,Nick,2222,abc
56ef2c84-7e57-4c9f-8d23-787f4c9ae9d2,a-x-pha-f5-rg-001 ,20000,Jose
56ef2c84-7e57-4c9f-8d23-787f4c9ae9d2,AzureBackupRG_southcentralus_1,20000,Jose,88383,Shared
b61837ec-d496-4bac-9cd2-89819fdd2ffd,shd-5-deploy-001-rg,23000,Chris,4444,ijk
b61837ec-d496-4bac-9cd2-89819fdd2ffd,,25000,Mary,5555,kkkkk
b61837ec-d496-5edf-9cd2-89819fdd2ggd,,24000,Mary
b42434ed-d494-5edf-9cc2-89819fdd2ggd,,24002,Mary,9999
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
        resourceGroupName
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

      if ($condition1 -and $condition2 -and $condition3 -and $condition4 -and $condition5 -and $condition6)
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
      $CsvData = $CsvData | Select-Object $header1, $header2, $header3, $header4, $header5, $header6

      if ($AzureSubId = Get-AzureSubId)
      {
        $AzureSubIndex = buildIndex $AzureSubId 'Id'
        $CsvData | ForEach-Object { if ($AzureSubIndex.Contains($_.subscriptionId) )
          { $_ | Where-Object { $_.resourceGroupName }
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

function Set-TaggingScenario2
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
        Write-OutputLog "Connected to the RG $rg in the SUBID $sub" -logFile common.log
        Write-OutputLog "<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>"  -logFile common.log

        write-Host "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
        Write-Host ""
        write-Host "[Subscription]::$sub  [Resource Group]::$rg" -BackgroundColor white -ForegroundColor DarkCyan
        write-host ""
        write-Host "|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
        try
        {
          $RgTags = (Get-AzResourceGroup -Name $rg -ErrorAction Stop).Tags
          if ($RgTags)
          {
            $RgTags['costCenter'] = $($csvHash[$sub] |
              Where-Object { $_.resourceGroupName -eq $rg }).costCenter

            $RgTags['assetManager'] = $($csvHash[$sub] |
              Where-Object { $_.resourceGroupName -eq $rg }).assetManager
            # Set-AzResourceGroup -Tag $RgTags -Name $rg
            Write-OutputLog "Updated Tags. costCenter and assetManager Tag applied" -toHost -logFile common.log
          }
          else
          {
            $RgTags = @{ }
            $RgTags['costCenter'] = $($csvHash[$sub] |
              Where-Object { $_.resourceGroupName -eq $rg }).costCenter

            $RgTags['assetManager'] = $($csvHash[$sub] |
              Where-Object { $_.resourceGroupName -eq $rg }).assetManager
            # Set-AzResourceGroup -Tag $RgTags -Name $rg

            Write-OutputLog "New Tags. costCenter and assetManager Tag applied" -toHost -logFile common.log


          }
          try
          {
            $resources = Get-AzResource -ResourceGroupName $rg -ErrorAction Stop |
            Where-Object { $_.ResourceType -notmatch "extensions" }

            foreach ($r in $resources)
            {
              Write-OutputLog "Connected to the resource $($r.Name) RG $rg in the SUBID $sub" -logFile common.log
              write-host ""
              write-host "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
              write-host "[Subscription]::$sub  [Resource Group]::$rg  [Resource]::$($r.Name)" -BackgroundColor Yellow -ForegroundColor Red
              write-host "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
              write-host ""
              $resourcetags = $r.Tags
              if ($resourcetags)
              {
                $resourcetags['costCenter'] = $($csvHash[$sub] |
                  Where-Object { $_.resourceGroupName -eq $rg }).costCenter

                $resourcetags['assetManager'] = $($csvHash[$sub] |
                  Where-Object { $_.resourceGroupName -eq $rg }).assetManager

                $resourcetags['productCode'] = $($csvHash[$sub] |
                  Where-Object { $_.resourceGroupName -eq $rg }).productCode

                $resourcetags['client'] = $($csvHash[$sub] |
                  Where-Object { $_.resourceGroupName -eq $rg }).client

                # Set-AzResource -Tag $resourcetags -ResourceId $r.ResourceId -Force

                Write-OutputLog "Updated Tags. productCode and client Tag applied" -toHost -logFile common.log
              }
              else
              {
                $resourcetags = @{ }
                $resourcetags['costCenter'] = $($csvHash[$sub] |
                  Where-Object { $_.resourceGroupName -eq $rg }).costCenter

                $resourcetags['assetManager'] = $($csvHash[$sub] |
                  Where-Object { $_.resourceGroupName -eq $rg }).assetManager

                $resourcetags['productCode'] = $($csvHash[$sub] |
                  Where-Object { $_.resourceGroupName -eq $rg }).productCode

                $resourcetags['client'] = $($csvHash[$sub] |
                  Where-Object { $_.resourceGroupName -eq $rg }).client

                #  Set-AzResource -Tag $resourcetags -ResourceId $r.ResourceId -Force | out-null

                Write-OutputLog "Updated Tags. productCode and client Tag applied" -toHost -logFile common.log
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

# $csv = GenerateDataScenario2
# $csvHash = buildIndex $csv 'subscriptionId'
# Set-TaggingScenario2 $csvHash

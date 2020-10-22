# Scenario 1
## Data Input format

subscriptionId,costCenter,assetManager,productCode,client

4464d424-b12c-4fcc-853d-6d1c00640cc7,12000,Carol,1111,xyz

7484ec2d-e33a-478e-b532-1fbcd9980b2e,10000,Nick,2222,abc

## Description
    The Scenario 1 is for applying costCenter and assetManager tags to
    all resource groups and costcenter , assetManager, productCode and client
    to resources given a subscription data

<br>

# Scenario 2
## Data Input format

subscriptionId,resourceGroupName,costCenter,assetManager,productCode,client

4464d424-b12c-4fcc-853d-6d1c00640cc7,a-p2-sdo-nas-rg-001,12000,Carol,1111,Shared

4464d424-b12c-4fcc-853d-6d1c00640cc7,a-p2-sdo-test-rg-001,22000,Mark,33333,vipclient

7484ec2d-e33a-478e-b532-1fbcd9980b2e,a-p2-sdo-test-rg-001,10000,Nick,2222,abc

## Description

    The Scenario 2 is for applying costCenter and assetManager tags to a given
    resource group and the costcenter,assetmanager, productCode and client to all
    resources under that resource groups

<br>

# Scenario 3
## Data Input format

subscriptionId,costCenter,assetManager

4464d424-b12c-4fcc-853d-6d1c00640cc7,12000,Carol

7484ec2d-e33a-478e-b532-1fbcd9980b2e,10000,Nick

56ef2c84-7e57-4c9f-8d23-787f4c9ae9d2,20000,Jose

b61837ec-d496-4bac-9cd2-89819fdd2ffd,23000,Chris


## Description

    The Scenario 3 is for applying costCenter and assetManager tags to all RG in a subscription

    If you want to apply all the tags(costCenter,assetManager,productCode,client)
    to all resources within a subscription please use scenario1
<br>

# Scenario 4

## Data Input
subscriptionId,resourceGroupName,costCenter,assetManager

10decf3a-85a5-4a35-b6fe-889bfe3278b2,a-d-gha-bossnet-rg,12000,Carol

10decf3a-85a5-4a35-b6fe-889bfe3278b2,a-d-gha-elk-rg-1.0,22000,Mark

10decf3a-85a5-4a35-b6fe-889bfe3278b2,a-d-gha-scm-rg-17.3,10000,Nick

## Description
    The Scenario 4 is for applying costCenter and assetManager tags to a given
    resource group.

    If you want to apply all the tags (costCenter,assetManager,produceCode,client)
    to all resources within a RG please use scenario2

<br>

# Scenario 5

## Data Input
subscriptionId,resourceName,costCenter,assetManager,productCode,client
10decf3a-85a5-4a35-b6fe-889bfe3278b2,apghacpmweb001,3000,Carl,11000,Client1
10decf3a-85a5-4a35-b6fe-889bfe3278b2,apghaelkelnk001,3000,Carl,12000,Client2
10decf3a-85a5-4a35-b6fe-889bfe3278b2,adghabossdoc02,4000,Mark,13000,Client3
10decf3a-85a5-4a35-b6fe-889bfe3278b2,apghascmhelc001,4000,Mark,13000,Client3

## Description
    The Scenario 5 is for applying costCenter,assetManager,productCode and client tags to a given
    resource under a given subscription

<br>



# How to run and Log file path
```
Example talks about how to run Scenario3
========================================

dot source the script based on scenario
-------------------------------------
 . .\scenario3.ps1

Generate the csv based on the scenario
--------------------------------------
$csv = GenerateScenario3

Build the index of subscriptionId
-----------------------------------------
$csvHash = buildIndex $csv 'subscriptionId'

Set the tagging
-------------------------------------------
Set-TaggingScenario3 $csvHash


Log file
==============
There will be 2 log files generated . Common log and error log
The log file will be generated in the path $PSSCRIPTROOT\Scenario3\yyyyMMdd_log directory
The configuration are specified in Write-Outputlog function

```


$a = "pgh1234" , "kgh3456" , "mgh4566", "glm3445"

$myregexp = "(?:p|g)(?:gh|lm)\d{4}"

$hash = @{}
for( $i = 0 ; $i -le 3 ; $i ++ ) {
 $hash[$i] = & { if ($a[$i] -match $myregexp ) { $a[$i]}} 
 
 }
 
 $a = get-process 
 $s = { 0..($a.Count -1) |
        where {$a[$_] -match 'armsvc'} 
        }


 $a[$(& $s)]


 $cred = Get-VICredentialStoreItem -Host $MyHost  -file "Anyfile"
                                    $user = $cred.user
                                    $pass = ConvertTo-SecureString $cred.password -AsPlainText -Force
                                    $encrypted_pass = ConvertFrom-SecureString $pass 
                                    try {
                                        $conn = Connect-VI -server $MyHost -user $user -password $encrypted_pass -EV myerr -EA stop
                                        if($conn.IsConnected) {$connected = $true}
                                    } catch {

                                    Write-Verbose "Oopsie .. Something has gone wrong!!!!"
                                    Write-Output "[$(get-date -format 'dd/MM/yyyy-HH:mm:ss')] $myerr" | out-file -FilePath -Append "ErrorLog.txt" -force
                                    break
                                }
                               
                            }


                    }




                    

function get-NetBackupProperties {


	<#
		.Synopsis
		Returns the customfield properties
	
		.Description
		
		
		.Parameter vCenterName
		
		
		.Parameter clusterName
		
		
		.Example

		
		.Example

		
		.Link
		Author:    Arun
		Date:      05/04/11
		Website:   http://www.cm.utexas.edu

	#>
   [CmdletBinding()]

    param(
    [Parameter(Mandatory=$false,
                ValueFromPipeline=$true,
                ValueFromPipelineByPropertyName=$true)]
    [string]$vCenterName,

    [Parameter(Mandatory=$false,
                ValueFromPipeline=$true,
                ValueFromPipelineByPropertyName=$true)]
    [string]$clusterName,

    [switch]$log
    )

    BEGIN {
    
    
    if($log) {
        $i = 0 
        $j = get-date -f "MM-dd-YY"
        $folderPath = "D:\tutorial-ps"

            do {
            $logfile = "netbackup-$j_$i.txt"
            $i++

        } while (Test-path $logfile)

        $logfile = $(join-path -Path $folderPath -ChildPath $logfile) 

    } else {

        write-verbose "No log file selected" 

    }
    
    }


    PROCESS {
            #check if clusterName is provided
            if(-not $clusterName) {

                Write-Verbose "Getting vms on vcenter"
                #$vms = get-vm -server $vcCenterName  | where powerstate -eq "PoweredOn"
                } else {

                Write-Verbose "Getting vms from cluster"
                #$vms = get-vm -server $vCenterName -location (get-cluster $clusterName)
                }


            foreach ($vm in $vms ) {

                #text parsing



            }

            

             
    
    
    }

    END {}




}
If ((Get-PSSnapin -Name VMware.VimAutomation.Core -ErrorAction SilentlyContinue) -eq $null )
{
    Try {
        Add-PsSnapin VMware.VimAutomation.Core -ErrorAction stop -ErrorVariable myerr
    } Catch {
        Write-Output "[$(get-date -format 'dd/MM/yyyy-HH:mm:ss')] $myerr" | out-file -FilePath -Append "ErrorLog.txt" -force
        Exit 1
    }
}
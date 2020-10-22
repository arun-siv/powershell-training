

function test-VcenterConnectivity {

    [CmdletBinding()]

    param(
    
    [parameter(ValueFromPipeline=$true)]
    [string]$MyHost
    
    )

    BEGIN {
         
         #initialize to false
         $connected = $false 
         #script block to find index of Defaultviservers
         $conn_status = { (0..($Global:defaultviservers - 1)) | where {$Global:defaultviservers[$_] -match $MyHost}} 

         $pass_file = "D:\tutorial-ps\p.xml"

         function get-VCCredential { 
            param([string]$user,[string]$password)
            $encrypted_password = ConvertTo-SecureString $password -AsPlainText -Force
            $credential = New-Object System.Management.Automation.PsCredential($user, $encrypted_password)
            Write-Output $credential
         
         }
    }

    PROCESS {

         #check if the connection already exists 
                 
         if ( $($Global:defaultviservers).Name -contains $MyHost) {
                                
            if ($($Global:defaultviservers[$(& $conn_status)]).Isconnected -eq 'True') {
                 $connected = $true 
                 Write-Verbose "Already connected to the the vCenter $MyHost"
                 }

            } else {
                   
                    try {
                        Write-Verbose "Getting Credentials from Credential Store"
                        $cred = Get-VICredentialStoreItem -Host $MyHost  -file $pass_file  -WarningAction SilentlyContinue  -ErrorAction Stop -ErrorVariable myerr
                        Write-Debug $cred
       
                       
                        } catch {
                            #write verbose and log in error 
                            $connected = $false
                            Write-Verbose "No entry of Host $MyHost in the credential Store!!! Kindly create before proceeding"
                            Write-Output "[$(get-date -format 'dd/MM/yyyy-HH:mm:ss')] $myerr" | out-file -FilePath  "D:\tutorial-ps\ErrorLog.txt" -Append -Force
                            return
                
                        }
                    try {
                        $credential = get-VCCredential -user $($cred.user) -password $($cred.Password)
                        Write-Debug $credential
                        
                        Connect-ViServer -ea Stop -ev myerr -server $MyHost -Credential $credential

                        if ($($Global:defaultviservers[$(& $conn_status)]).Isconnected -eq 'True') {
                            $connected = $true 
                            }

                    } catch {

                        Write-Verbose "Connectivity cannot be established for $MyHost"
                        Write-Output "[$(get-date -format 'dd/MM/yyyy-HH:mm:ss')] $myerr" | out-file -FilePath  "D:\tutorial-ps\ErrorLog.txt" -Append -Force
                        return
                        
                        
                    }

        }
     
         #preparing for output

         if($connected) { Write-Output $MyHost }
     
     
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
            if (test-VcenterConnectivity $vCenterName) {
                #check if clusterName is provided
                if(-not $clusterName) {

                    Write-Verbose "Getting vms on vcenter"
                    try {

                        $vms = get-vm -server $vcCenterName  | where powerstate -eq "PoweredOn"
                        } catch {

                            Write-Verbose "Failed to get VMs from $vCenterName"
                            return
                        }
                    } else {

                            Write-Verbose "Getting vms from cluster"
                    
                            try {
                                $vms = get-vm -server $vCenterName -location (get-cluster $clusterName) | where powerstate -eq "PoweredOn"

                                } catch {

                                        Write-Verbose "Failed to get VMs from $vCenterName and Cluster $clusterName"
                                        return 
                                }
                    }
                }

            foreach ($vm in $vms ) {

                if ( ($vm | select -ExpandProperty Customfield).key -ne $null -and (($vm | select -ExpandProperty Customfield).Value).count -ge 1)
                {
                    $properties = [ordered]@{

                                    'VM' = $vm;
                                    'Key' = ($vm | select -ExpandProperty Customfield).key;
                                    'Value' = ($vm | select -ExpandProperty Customfield).Value;
                    }


               
                $obj =[pscutomobject]$properties
                Write-Output $obj
               
                }


                #text parsing



            }


     
    }

    END {}
}





   if (-not (Get-Module vmware.vimautomation.core)) { Import-Module vmware.vimautomation.core }   
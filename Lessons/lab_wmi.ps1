$continue = $false

$result = 'aBC'  | 
            foreach {
            $srv = $_

            try {
                $server = Get-WmiObject -ea stop -Class win32_computerSystem -ComputerName $srv
                $continue = $true

            } catch {

             "Failed to get wmi for $srv"
              

            }

            if($continue){

            $cpu = Get-WmiObject -class win32_Processor -ComputerName $_ | select -First 1
            $os = Get-WmiObject -Class win32_operatingSystem -ComputerName $_
            
            $system = @{}

            $system.Name = $server.Name
            $system.Model = $server.Model
            $system.Make = $server.Manufacturer
            $system.Memory = $server.TotalPhysicalMemory
            $system.CPUs = $server.NumberOfProcessors
            
            $system.speed = $cpu.MaxClockSpeed

            $system.Windows = $os.Caption
            $system.SP = $os.ServicePackmajorVersion

            if(($os.version -split '\.')[0] -ge 6 ){
            $system.Cores = $cpu.NumberOfCores
            $system.LogProc = $cpu.NumberOfLogicalProcessors
            
            } else {
            $system.CPUs = ""
            $system.Cores = $server.NumberOfProcessors
            }
            New-Object -TypeName PSObject -Property $system
            
            
            }
            

            }
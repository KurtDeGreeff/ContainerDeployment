function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $ContainerName,

        [parameter(Mandatory = $true)]
        [System.String]
        $PortMapping,

        [parameter(Mandatory = $true)]
        [System.String]
        $ProjectRootPath,

        [parameter(Mandatory = $true)]
        [System.String]
        $GitProjectURL,

        [parameter(Mandatory = $true)]
        [ValidateSet("sample-golang","sample-python","iis")]
        [System.String]
        $ProjectType,

        [parameter(Mandatory = $true)]
        [System.String]
        $ContainerImage,

        [parameter(Mandatory = $true)]
        [ValidateSet("Absent","Present")]
        [System.String]
        $Ensure
    )

    
    $returnValue = @{
    ContainerName   = [System.String]$ContainerName
    PortMapping     = [System.String]$PortMapping
    ProjectRootPath = [System.String]$ProjectRootPath
    GitProjectURL   = [System.String]$GitProjectURL
    ProjectType     = [System.String]$ProjectType
    ContainerImage  = [System.String]$ContainerImage
    Ensure          = [System.String]$Ensure
    }

    $returnValue
    
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $ContainerName,

        [parameter(Mandatory = $true)]
        [System.String]
        $PortMapping,

        [parameter(Mandatory = $true)]
        [System.String]
        $ProjectRootPath,

        [parameter(Mandatory = $true)]
        [System.String]
        $GitProjectURL,

        [parameter(Mandatory = $true)]
        [ValidateSet("sample-golang","sample-python","IIS")]
        [System.String]
        $ProjectType,

        [parameter(Mandatory = $true)]
        [System.String]
        $ContainerImage,

        [parameter(Mandatory = $true)]
        [ValidateSet("Absent","Present")]
        [System.String]
        $Ensure
    )

New-Alias -name git -value 'C:\Program Files\git\bin\git.exe' -Force

if ($Ensure -eq 'Present') {
    if (-not(Test-Path $ProjectRootPath)){
        Write-Verbose "Creating and cloning $GitProjectURL"
        New-Item -ItemType Directory -Path $ProjectRootPath
        try {
        git clone --quiet $GitProjectURL $ProjectRootPath
            } catch [Exception]{
            throw "failed when attempting to clone $GitProjectURL to local path: $ProjectRootPath"
            }

        
        $LocalVersion = (Get-Content $ProjectRootPath\files\$ProjectType\dockerfile | Select-String 'Version.*').Matches.Value
        $LocalVersion = ($LocalVersion | Select-String \d+\.\d+\.\d+ -AllMatches ).Matches.Value

        if ((docker images) -match "microsoft/$ProjectType"){
            Write-Verbose "Image specified in Dockerfile is microsoft/$ProjectType - no need to download"
            } else {
            Write-Verbose "microsoft/$projecttype cannot be found locally, downloading"
            try {
            Write-Verbose "running command: docker pull microsoft/$projecttype`:windowsservercore"
            docker pull "microsoft/$projecttype`:windowsservercore"
                } catch [Exception] {
                throw 'Image cannot be downloaded using docker pull'
                }
            }
 
        if (docker images -q $ContainerImage){
                Write-Verbose "Removing Container Image:$ContainerImage"
                docker rmi $ContainerImage
                }
        if (-not (docker images -q $ContainerImage)){
                Write-Verbose "Running: docker build -t $ContainerImage $ProjectRootPath\files\$ProjectType\"
    	        docker build -t $ContainerImage $ProjectRootPath\files\$ProjectType\
                }

        $ContainerPort = ($Portmapping -split ':')[0]
        if (Get-NetNatStaticMapping | Where {$PsItem.ExternalPort -eq $ContainerPort}){
            Write-Verbose "Found current static mapping for $PortMapping, Removing."
            Get-NetNatStaticMapping | Where {$PsItem.ExternalPort -eq $ContainerPort} | Remove-NetNatStaticMapping -confirm:$false
                }


        Write-Verbose "Creating Container $ContainerName Image: $ContainerImage Version: $LocalVersion Type: $ProjectType"
    	docker run -d -it --name $ContainerName -p $PortMapping $ContainerImage

    	Write-Verbose "Container $ContainerName $LocalVersion running $ContainerImage - Port Mapping: $PortMapping is now online" 
        } else {

    Write-Verbose 'Verison mismatch has been identified - pulling latest content'

    Set-Location $ProjectRootPath  
    git pull --quiet | Out-null
    $LocalVersion = (Get-Content $ProjectRootPath\files\$ProjectType\dockerfile | Select-String 'Version.*').Matches.Value
    $LocalVersion = ($LocalVersion | Select-String \d+\.\d+\.\d+ -AllMatches ).Matches.Value
    
    if ($LocalVersion -match $GitVersion){
        try {
        if ((docker ps --filter name=$ContainerName --filter 'status=running' -a -q )){
                Write-Verbose "Stopping Container: $ContainerName"
                docker stop $ContainerName 
                } else {
                    Write-Verbose "No Container named $ContainerName currently running"
                    }
        if((docker ps --filter name=$ContainerName --filter 'status=exited' -a -q )){
                Write-Verbose "Removing Container: $ContainerName"
                docker rm $ContainerName
            }
        if (docker images -q $ContainerImage){
                Write-Verbose "Removing Container Image:$ContainerImage"
                docker rmi $ContainerImage
                }
        if (-not (docker images -q $ContainerImage)){
                Write-Verbose "Running: docker build -t $ContainerImage $ProjectRootPath\files\$ProjectType\"
    	        docker build -t $ContainerImage $ProjectRootPath\files\$ProjectType\
                }

        $ContainerPort = ($Portmapping -split ':')[0]
        if (Get-NetNatStaticMapping | Where {$PsItem.ExternalPort -eq $ContainerPort}){
            Write-Verbose "Found current static mapping for $PortMapping, Removing."
            Get-NetNatStaticMapping | Where {$PsItem.ExternalPort -eq $ContainerPort} | Remove-NetNatStaticMapping -confirm:$false
                }

        Write-Verbose "Running: docker run -d -it --name $ContainerName -p $PortMapping $ContainerImage"
    	docker run -d -it --name $ContainerName -p $PortMapping $ContainerImage 
        Write-Verbose "Container $ContainerName $LocalVersion running $ContainerImage - Port Mapping: $PortMapping is now online"

        } catch [Exception] {
    	throw 'Something went horribly wrong!'
       }
    }
  }
} else {

    if (docker ps --filter name=$ContainerName --filter 'status=running' -a -q ){
        Write-Verbose "Stopping Container: $ContainerName"
        docker stop $ContainerName 
           } else {
             Write-Verbose "No Container named $ContainerName currently running"
                    }
    if(docker ps --filter name=$ContainerName --filter 'status=exited' -a -q ){
            Write-Verbose "Removing Container: $ContainerName"
            docker rm $ContainerName
            }
    if (docker images -q $ContainerImage){
            Write-Verbose "Removing Container Image:$ContainerImage"
            docker rmi $ContainerImage
                }
     Write-Verbose "Removed $Containname and $ContainerImage"

    }

}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $ContainerName,

        [parameter(Mandatory = $true)]
        [System.String]
        $PortMapping,

        [parameter(Mandatory = $true)]
        [System.String]
        $ProjectRootPath,

        [parameter(Mandatory = $true)]
        [System.String]
        $GitProjectURL,

        [parameter(Mandatory = $true)]
        [ValidateSet("sample-golang","sample-python","IIS")]
        [System.String]
        $ProjectType,

        [parameter(Mandatory = $true)]
        [System.String]
        $ContainerImage,

        [parameter(Mandatory = $true)]
        [ValidateSet("Absent","Present")]
        [System.String]
        $Ensure
    )

Write-Verbose "Starting Test DSC Configuration"

New-Alias -name git -value 'C:\Program Files\git\bin\git.exe' -Force
try {
    Import-Module posh-git -ErrorAction Stop | Out-Null
    }
        catch [Exception] {
        throw 'This DSC resource requires that posh-git be installed the container host, please install this with Install-Module posh-git'
        }

    if ($Ensure -eq 'Present'){
        if (-not(Test-Path $ProjectRootPath)){
            Write-Verbose "$ProjectRootPath does not exist, calling SET"
            return $false
        } else {
        Write-Verbose "$ProjectRootPath already exists"
            
        $LocalVersion = (Get-Content "$ProjectRootPath\files\$ProjectType\dockerfile" | Select-String 'Version.*').Matches.Value
        Write-Verbose "Local Version: $LocalVersion"        
        
        Set-Location $ProjectRootPath
        git pull --quiet | Out-null #pull the latest content to check for new versioning
        $GitVersion = (Get-Content "$ProjectRootPath\files\$ProjectType\dockerfile" | Select-String 'Version.*').Matches.Value
        Write-Verbose "Pulled version: $GitVersion"

        if ($GitVersion -ne $LocalVersion){
                Write-Verbose 'Version mismatch, Calling SET' 
            	return [boolean]$false 
            } else {
                Write-Verbose 'Versions match, Currently in desired state' 
                return [boolean]$true 
            }
        }
    } else {
        Write-Verbose "Ensure is set to $Ensure - Calling SET to remove container"
        return [boolean]$false 
    }


}

Export-ModuleMember -Function *-TargetResource -Alias git

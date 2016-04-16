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
        [ValidateSet("Golang","Python","IIS")]
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
        [ValidateSet("Golang","Python","IIS")]
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
        Write-Verbose "$ProjectRootPath does not exist, creating and cloning $GitProjectURL"
        New-Item -ItemType Directory -Path $ProjectRootPath
        git clone --quiet $GitProjectURL $ProjectRootPath

        
        $LocalVersion = (Get-Content $ProjectRootPath\files\$ProjectType\dockerfile | Select-String 'Version.*').Matches.Value
        $LocalVersion = ($LocalVersion | Select-String \d+\.\d+\.\d+ -AllMatches ).Matches.Value

        Write-Verbose "Creating Container $ContainerName Image: $ContainerImage Version: $LocalVersion Type: $ProjectType"
        docker build -t $ContainerImage $ProjectRootPath\files\$ProjectType
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
        Write-Verbose "Stopping Container: $ContainerName"
        docker stop $ContainerName 
        Write-Verbose "Removing Container: $ContainerName"
        docker rm $ContainerName
        Write-Verbose "Removing Container Image:$ContainerImage"
        docker rmi $ContainerImage
        Write-Verbose "Running: docker build -t $ContainerImage $ProjectRootPath\files\$ProjectType\"
    	docker build -t $ContainerImage $ProjectRootPath\files\$ProjectType\
        Write-Verbose "Running: docker run -d -it --name $ContainerName -p $PortMapping $ContainerImage"
    	docker run -d -it --name $ContainerName -p $PortMapping $ContainerImage
        Write-Verbose "Container $ContainerName $LocalVersion running $ContainerImage - Port Mapping: $PortMapping is now online"
        } catch [Exception] {
    	throw 'Something went horribly wrong!'
       }
    }
    }
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
        [ValidateSet("Golang","Python","IIS")]
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


Export-ModuleMember -Function *-TargetResource 


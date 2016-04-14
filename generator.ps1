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
        $ContainerImage,

        [parameter(Mandatory = $true)]
        [ValidateSet("Absent","Present")]
        [System.String]
        $Ensure
    )

    $returnValue = @{
    ContainerName = [System.String]$ContainerName
    PortMapping = [System.String]$PortMapping
    GitRootPath = [System.String]$GitRootPath
    ContainerImage = [System.String]$ContainerImage
    Ensure = [System.String]$Ensure
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

        [System.String] 
        $PortMapping,

        [System.String]
        $GitRootPath,

        [parameter(Mandatory = $true)]
        [System.String]
        $ContainerImage,

        [parameter(Mandatory = $true)]
        [ValidateSet("Absent","Present")]
        [System.String]
        $Ensure
    )
if ($Ensure -eq 'Present') {
    Write-Verbose 'Entered SET - verison mismatch has been identified - pulling latest content'
    Set-Location $GitRootPath

    git pull
    $LocalVersion = (cat $GitRootPath\*\dockerfile | Select-String 'Version.*' -AllMatches).Matches.Value
    Write-Verbose "Current version of Docker file locally is now $LocalVersion - the same as Git version: $GitVersion"

    if ($LocalVersion -match $GitVersion){
    docker build -t $ContainerImage $GitRootPath\files\
    docker run -d $ContainerName -p $PortMapping $ContainerImage cmd

    Write-Verbose "Container $ContainerName running $ContainerImage - Port Mapping: $PortMapping is now online"
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

        [System.String]
        $PortMapping,

        [System.String]
        $GitRootPath,

        [parameter(Mandatory = $true)]
        [System.String]
        $ContainerImage,

        [parameter(Mandatory = $true)]
        [ValidateSet("Absent","Present")]
        [System.String]
        $Ensure
    )

    if ($Ensure -eq 'Present'){
        Write-Verbose "Starting Test DSC COnfiguration"
        Set-Location $GitRootPath
        Import-module 'C:\Program Files\WindowsPowerShell\Modules\posh-git\0.6.1.20160330\posh-git.psm1' -Scope Global

        $Version = git grep "Version"
        $GitVersion = ($Version | Select-String 'Version.*' -AllMatches).Matches.Value
        Write-Verbose "Current version of Docker file in Github is $GitVersion"

        $LocalVersion = (cat $GitRootPath\*\dockerfile | Select-String 'Version.*' -AllMatches).Matches.Value
        Write-Verbose "Current version of Docker file locally is $LocalVersion"

        if ($GitVersion -match $LocalVersion){
            Write-Verbose "Version of dockerfile in Github:($GitVersion) matches local version of Docker file:($LocalVersion)"
            return $true
            } else {
                Write-Verbose "Version of dockerfile in Github:($GitVersion) does NOT match the local version of Docker file:($LocalVersion)"
                return $false
            }
    
    } else {
        Write-Verbose "Ensure is set to $Ensure - Calling SET to remove container"
        return $False
    } 
 
}


Export-ModuleMember -Function *-TargetResource


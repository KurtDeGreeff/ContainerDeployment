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
        $ProjectRoot,

        [parameter(Mandatory = $true)]
        [System.String]
        $ContainerImage,

        [parameter(Mandatory = $true)]
        [ValidateSet("Absent","Present")]
        [System.String]
        $Ensure
    )
    
    $returnValue = @{
    ContainerName = [System.String]
    PortMapping = [System.String]
    ProjectRoot = [System.String]
    ContainerImage = [System.String]
    Ensure = [System.String]
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
        $ProjectRoot,

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
    Write-Verbose 'Entered SET - verison mismatch has been identified - pulling latest content'
    Set-Location $ProjectRoot
    
    git pull --quiet | Out-null
    $LocalVersion = (Get-Content $ProjectRoot\files\dockerfile | Select-String 'Version.*' -AllMatches).Matches.Value
    $LocalVersion = ($LocalVersion | Select-String \d+\.\d+\.\d+ -AllMatches ).Matches.Value
    
    if ($LocalVersion -match $GitVersion){
    	docker build -t $ContainerImage $ProjectRoot\files\
    	docker run -d -it --name "$ContainerName_$LocalVersion" -P $ContainerImage

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

        [parameter(Mandatory = $true)]
        [System.String]
        $PortMapping,

        [parameter(Mandatory = $true)]
        [System.String]
        $ProjectRoot,

        [parameter(Mandatory = $true)]
        [System.String]
        $ContainerImage,

        [parameter(Mandatory = $true)]
        [ValidateSet("Absent","Present")]
        [System.String]
        $Ensure
    )
New-Alias -name git -value 'C:\Program Files\git\bin\git.exe' -Force

    if ($Ensure -eq 'Present'){
        Write-Verbose "Starting Test DSC Configuration"
        Set-Location $ProjectRoot
        Import-module 'C:\Program Files\WindowsPowerShell\Modules\posh-git\0.6.1.20160330\posh-git.psm1' -Scope Global
        
        $LocalVersion = (cat $ProjectRoot\files\dockerfile | Select-String 'Version.*' -AllMatches).Matches.Value
        Write-Verbose "Local Version: $LocalVersion"        

        git pull --quiet | Out-null
        $GitVersion = (cat $ProjectRoot\files\dockerfile | Select-String 'Version.*' -AllMatches).Matches.Value
        Write-Verbose "Pulled version: $GitVersion"

        if ($GitVersion -ne $LocalVersion){
            	return $FALSE
            } 
        if ($GitVersion -eq $LocalVersion) {
                return $TRUE
            }
    
    } else {
        Write-Verbose "Ensure is set to $Ensure - Calling SET to remove container"
        return [boolean]$false 
    }



}


Export-ModuleMember -Function *-TargetResource -Variable GitVersion -Alias git


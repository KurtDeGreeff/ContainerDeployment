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
        [ValidateSet("Golang","IIS")]
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

    #Write-Verbose "Use this cmdlet to deliver information about command processing."

    #Write-Debug "Use this cmdlet to write debug information while troubleshooting."


    <#
    $returnValue = @{
    ContainerName = [System.String]
    PortMapping = [System.String]
    ProjectRootPath = [System.String]
    GitProjectURL = [System.String]
    ProjectType = [System.String]
    ContainerImage = [System.String]
    Ensure = [System.String]
    }

    $returnValue
    #>
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
        [ValidateSet("Golang","IIS")]
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

    #Write-Verbose "Use this cmdlet to deliver information about command processing."

    #Write-Debug "Use this cmdlet to write debug information while troubleshooting."

    #Include this line if the resource requires a system reboot.
    #$global:DSCMachineStatus = 1


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
        [ValidateSet("Golang","IIS")]
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

    #Write-Verbose "Use this cmdlet to deliver information about command processing."

    #Write-Debug "Use this cmdlet to write debug information while troubleshooting."


    <#
    $result = [System.Boolean]
    
    $result
    #>
}


Export-ModuleMember -Function *-TargetResource


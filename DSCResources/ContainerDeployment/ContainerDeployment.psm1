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
        $SlackWebHook,

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
        $SlackWebHook,

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
    	docker run -d -p $PortMapping --name $ContainerName $ContainerImage
    	
    	$props = @{
        Fallback = 'Container Bot'
        Title = 'New Container'
        Text =  "New Container: $ContainerName - $LocalVersion running $ContainerImage mapped to port $PortMapping is now online. Quicklink: 'http://' + $((gip).ipv4address.ipaddress) + '$ContainerPort'"
        Severity = 'good'
        Username = 'Container Bot'
        }

        New-SlackRichNotification @props | Send-SlackNotification -Url $SlackWebHook

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

        Write-Verbose "Running: docker run -d -p $PortMapping --name $ContainerName $ContainerImage"
    	docker run -d -p $PortMapping --name $ContainerName $ContainerImage
        Write-Verbose "Container $ContainerName $LocalVersion running $ContainerImage - Port Mapping: $PortMapping is now online"
        
        $props = @{
        Fallback = 'Container Bot'
        Title = 'New Container'
        Text =  "New Container: $ContainerName - $LocalVersion running $ContainerImage mapped to port $PortMapping is now online. Quicklink: 'http://' + $((gip).ipv4address.ipaddress) + '$ContainerPort'"
        Severity = 'good'
        Username = 'Container Bot'
        }

        New-SlackRichNotification @props | Send-SlackNotification -Url $SlackWebHook

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
        $SlackWebHook,

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
function Send-SlackNotification
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,
                   Position=0)]
        [String]
        $Url,

        [Parameter(Mandatory=$true,
                   ValueFromPipeline = $true,
                   Position=1)]
        [System.Collections.Hashtable]
        $Notification
    )

    Begin
    {
    }
    Process
    {
        $json = $Notification | ConvertTo-Json -Depth 4
        $json = [regex]::replace($json,'\\u[a-fA-F0-9]{4}',{[char]::ConvertFromUtf32(($args[0].Value -replace '\\u','0x'))})
        $json = $json -replace "\\\\", "\"
        
        try
        {
            Invoke-RestMethod -Method POST -Uri $Url -Body $json
        }

        catch
        {
            Write-Warning $_
        }
    }
    End
    {
    }
}

function New-SlackRichNotification
{
    [CmdletBinding(SupportsShouldProcess=$false)]
    [OutputType([System.Collections.Hashtable])]
    Param
    (
        #<Attachment>
        [Parameter(Mandatory=$true,
                    Position=0
                    )]
        [String]
        $Fallback,
        
        [Parameter(Mandatory=$false,
                    ParameterSetName='SeverityOrColour')]
        [ValidateSet("good",
                     "warning", 
                     "danger"
                     )]
        [String]
        $Severity,
        
        [Parameter(Mandatory=$false,
                    ParameterSetName='ColourOrSeverity'
                    )]
        [Alias("Colour")]
        [string]
        $Color,

        [Parameter(Mandatory=$false)]
        [String]
        $AuthorName,

        [Parameter(Mandatory=$false)]
        [String]
        $Pretext,

        [Parameter(Mandatory=$false)]
        [String]
        $AuthorLink,

        [Parameter(Mandatory=$false)]
        [String]
        $AuthorIcon,

        [Parameter(Mandatory=$false)] 
        [String]
        $Title,

        [Parameter(Mandatory=$false)]
        [String]
        $TitleLink,
        
        [Parameter(Mandatory=$false,
                    Position=1
                    )]
        [String]
        $Text,

        [Parameter(Mandatory=$false)]
        [String]
        $ImageURL,

        [Parameter(Mandatory=$false)]
        [String]
        $ThumbURL,
        
        [Parameter(Mandatory=$false)]
        [Array]
        $Fields,
        #</Attachment>
        #<postMessage Arguments>
        [Parameter(Mandatory=$false)]
        [String]
        $Channel,

        [Parameter(Mandatory=$false)]
        [String]
        $UserName,

        [Parameter(Mandatory=$false)]
        [String]
        $IconUrl
        #</postMessage Arguments>
    )

    Begin
    {
    }
    Process
    {
        #consolidate the colour and severity parameters for the API.
        If($Severity -match 'good|warning|danger')
        {
            $Color = $Severity
        }
        
        $SlackNotification = @{
            username = $UserName
            icon_url = $IconUrl
            attachments = @(
                @{                    
                    fallback = $Fallback
                    color = $Color
                    pretext = $Pretext
                    author_name = $AuthorName
                    author_link = $AuthorLink
                    author_icon = $AuthorIcon
                    title = $Title
                    title_link = $TitleLink
                    text = $Text
                    fields = $Fields #Fields are defined by the user as an Array of HashTables.
                    image_url = $ImageURL
                    thumb_url = $ThumbURL
                }    
            )
        }

        Write-Output $SlackNotification
    }
    End
    {
    }
}

Export-ModuleMember -Function * -Alias git

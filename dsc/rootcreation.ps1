New-xDscResource –Name ContainerDeployment -Property @(
    New-xDscResourceProperty –Name ContainerName –Type String –Attribute Key
    New-xDscResourceProperty –Name PortMapping –Type String –Attribute Key
    New-xDscResourceProperty –Name ProjectRootPath –Type String  –Attribute Key
    New-xDscResourceProperty –Name GitProjectURL –Type String  –Attribute Key
    New-xDscResourceProperty –Name ProjectType –Type String  –Attribute Key -ValidateSet 'Golang','IIS'
    New-xDscResourceProperty –Name ContainerImage –Type String –Attribute Key
    New-xDscResourceProperty –Name Ensure –Type String –Attribute Key -ValidateSet 'Absent','Present'
) -Path "C:\Program Files\WindowsPowerShell\Modules\ContainerDeploy" -Verbose

New-ModuleManifest -Path "C:\Program Files\WindowsPowerShell\Modules\ContainerDeploy\ContainerDeploy.psd1" -CompanyName bundyfx -Guid (New-Guid) -Author 'Flynn Bundy' -ModuleVersion '1.0.0'

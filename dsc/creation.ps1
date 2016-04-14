#Install-module xDSCResourceDesigner

New-xDscResource –Name ContainerDeploy -Property @(
    New-xDscResourceProperty –Name ContainerName –Type String –Attribute Key
    New-xDscResourceProperty –Name PortMapping –Type String –Attribute Write, Read
    New-xDscResourceProperty –Name GitRootPath –Type String  –Attribute Write, Read
    New-xDscResourceProperty –Name ContainerImage –Type String –Attribute Key 
    New-xDscResourceProperty –Name Ensure –Type String –Attribute Key -ValidateSet 'Absent','Present'
) -Path "C:\Program Files\WindowsPowerShell\Modules\ContainerDeploy" -Verbose

New-ModuleManifest -Path "C:\Program Files\WindowsPowerShell\Modules\ContainerDeploy\ContainerDeploy.psd1" -CompanyName bundyfx -Guid (New-Guid) -Author 'Flynn Bundy' -ModuleVersion '1.0.0'

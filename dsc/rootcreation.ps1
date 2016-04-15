New-xDscResource –Name ContainerDeployment -Property @(
    New-xDscResourceProperty –Name ContainerName –Type String –Attribute Key
    New-xDscResourceProperty –Name PortMapping –Type String –Attribute Key 
    New-xDscResourceProperty –Name ProjectRoot –Type String  –Attribute Key
    New-xDscResourceProperty –Name GitProject –Type String  –Attribute Key
    New-xDscResourceProperty –Name ContainerImage –Type String –Attribute Key 
    New-xDscResourceProperty –Name Ensure –Type String –Attribute Key -ValidateSet 'Absent','Present'
) -Path "C:\Program Files\WindowsPowerShell\Modules\ContainerDeploy" -Verbose

New-ModuleManifest -Path "C:\Program Files\WindowsPowerShell\Modules\ContainerDeploy\ContainerDeploy.psd1" -CompanyName Coolblue -Guid (New-Guid) -Author 'Flynn Bundy' -ModuleVersion '1.0.0'


$LocalVersion = (Get-Content $ProjectRoot\files\dockerfile | Select-String 'Version.*' -AllMatches).Matches.Value

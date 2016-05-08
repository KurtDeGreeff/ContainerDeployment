configuration ContainerDeployment
{

Import-DscResource -ModuleName ContainerDeployment

    node ("localhost")
    {
        ContainerDeployment 'WebContainer' {
            ContainerName = 'webdev'
            PortMapping = '86:80'
            ProjectRootPath = 'C:\git\iis'
            ContainerImage = 'mywebapp'
            ProjectType = 'iis'
            GitProjectURL = 'https://github.com/bundyfx/ContainerDeployment.git'
            Ensure = 'Present'
        }
        ContainerDeployment 'DevGoContainer' {
            ContainerName = 'godev'
            PortMapping = '88:8000'
            ProjectRootPath = 'C:\git\golang'
            ContainerImage = 'mygolangapp'
            GitProjectURL = 'https://github.com/bundyfx/ContainerDeployment.git'
            ProjectType = 'sample-golang'
            Ensure = 'Present'
        }
       
    }
}

ContainerDeployment -outputpath C:\DSC

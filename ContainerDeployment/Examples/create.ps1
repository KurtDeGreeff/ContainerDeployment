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
            ProjectType = 'IIS'
            GitProjectURL = 'https://github.com/bundyfx/dockerimages.git'
            Ensure = 'Present'
        }
        ContainerDeployment 'DevGoContainer' {
            ContainerName = 'godev'
            PortMapping = '88:8000'
            ProjectRootPath = 'C:\git\golang'
            ContainerImage = 'mygolangapp'
            GitProjectURL = 'https://github.com/bundyfx/dockerimages.git'
            ProjectType = 'sample-golang'
            Ensure = 'Present'
        }
       
    }
}

ContainerDeploy -outputpath C:\DSC

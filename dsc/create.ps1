configuration ContainerDeploy
{

Import-DscResource -ModuleName ContainerDeploy

    node ("localhost")
    {
        ContainerDeployment myapp {
            ContainerName = 'MyAwesomeContainer'
            PortMapping = '86:80'
            GitRootPath = 'C:\git'
            ContainerImage = 'myapp'
            Ensure = 'Present'
        }
       
    }
}

ContainerDeploy -outputpath C:\

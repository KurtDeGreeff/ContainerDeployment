configuration ContainerDeploy
{

Import-DscResource -ModuleName ContainerDeploy

    node ("localhost")
    {
        ContainerDeployment 'DevC#Container' {
            ContainerName = 'Csharpdev'
            PortMapping = '86:80'
            GitRootPath = 'C:\git\iis'
            ContainerImage = 'myapp'
            Ensure = 'Present'
        }
        ContainerDeployment 'DevPythonContainer' {
            ContainerName = 'pythondev'
            PortMapping = '87:80'
            GitRootPath = 'C:\git\python'
            ContainerImage = 'pythonWeb'
            Ensure = 'Present'
        }
        ContainerDeployment 'DevGoContainer' {
            ContainerName = 'goev'
            PortMapping = '88:80'
            GitRootPath = 'C:\git\golang'
            ContainerImage = 'goWeb'
            Ensure = 'Present'
        }
       
    }
}

ContainerDeploy -outputpath C:\

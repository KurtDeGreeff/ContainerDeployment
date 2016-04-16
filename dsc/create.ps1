configuration ContainerDeploy
{

Import-DscResource -ModuleName ContainerDeploy

    node ("localhost")
    {
        ContainerDeployment 'WebContainer' {
            ContainerName = 'Web-dev'
            PortMapping = '86:80'
            ProjectRootPath = 'C:\git\iis'
            ContainerImage = 'MyWebAPP'
            ProjectType = 'IIS'
            GitProjectURL = 'https://github.com/bundyfx/dockerimages.git'
            Ensure = 'Present'
        }
        ContainerDeployment 'DevDjangoContainer' {
            ContainerName = 'Django-dev'
            PortMapping = '87:80'
            ProjectRootPath = 'C:\git\Django'
            ContainerImage = 'MyDjangoAPP'
            ProjectType = 'Python'
            GitProjectURL = 'https://github.com/bundyfx/dockerimages.git'
            Ensure = 'Present'
        }
        ContainerDeployment 'DevGoContainer' {
            ContainerName = 'go-dev'
            PortMapping = '88:80'
            ProjectRootPath = 'C:\git\golang'
            ContainerImage = 'MyGoAPP'
            GitProjectURL = 'https://github.com/bundyfx/dockerimages.git'
            ProjectType = 'Golang'
            Ensure = 'Present'
        }
       
    }
}

ContainerDeploy -outputpath C:\

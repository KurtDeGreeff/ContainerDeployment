configuration ContainerDeploy
{

Import-DscResource -ModuleName ContainerDeploy

    node ("localhost")
    {
        ContainerDeployment 'WebContainer' {
            ContainerName = 'Web-dev'
            PortMapping = '86:80'
            ProjectRootPath = 'C:\git\iis'
            ContainerImage = 'mywebapp'
            ProjectType = 'IIS'
            GitProjectURL = 'https://github.com/bundyfx/dockerimages.git'
            Ensure = 'Present'
        }
        ContainerDeployment 'DevDjangoContainer' {
            ContainerName = 'Django-dev'
            PortMapping = '87:80'
            ProjectRootPath = 'C:\git\Django'
            ContainerImage = 'mydjangoapp'
            ProjectType = 'Python'
            GitProjectURL = 'https://github.com/bundyfx/dockerimages.git'
            Ensure = 'Present'
        }
        ContainerDeployment 'DevGoContainer' {
            ContainerName = 'go-dev'
            PortMapping = '88:80'
            ProjectRootPath = 'C:\git\golang'
            ContainerImage = 'mygolangapp'
            GitProjectURL = 'https://github.com/bundyfx/dockerimages.git'
            ProjectType = 'Golang'
            Ensure = 'Present'
        }
       
    }
}

ContainerDeploy -outputpath C:\

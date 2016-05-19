$Containers = docker ps -a -q

if ($Containers -ge 1){
    foreach ($Container in $Containers){

        $Config = docker inspect $Container | ConvertFrom-Json 
        if ($config.State.Status -eq 'running'){

        $Uptime = ((New-TimeSpan -Start ($($config.State.StartedAt | Get-Date)) -End (Get-Date) | Select TotalMinutes).TotalMinutes) -as [Int]
        $Status = "$($config.State.Status) | Uptime: $Uptime Minutes"
        $Ports = (($Config.networksettings.Ports | Get-Member).Name[-1])
        $Link = $Config.Networksettings.Ports.$Ports.Hostport
        $Name = "http://$((gip).Ipv4address.IpAddress):$Link"
            if($Config.Config.Entrypoint -eq $null){
            $Command = $Config.Config.cmd
            }
            else {
            $Command = $Config.Config.Entrypoint[-1]
             }
          }
         
            else {
            $Status = $Config.State.Status
            $Ports = "N/A"
            $Command = "N/A"
            }

         $TableAdd = [pscustomobject]@{
                    Name            = $Config.name
                    Image           = $Config.config.image
                    Port            = $Ports
                    Status          = $Status
                    PID             = $Config.State.PID
                    Command         = $Command
                    }

     [Array]$Output +=      
                 @"
                </tr>
                <tr>
                <td align="left"><a href="$Name">$($TableAdd.Name)</a></td>
                <td align="left">$($TableAdd.Image)</td>
                <td align="left">$($TableAdd.Port)</td>
                <td align="left">$($TableAdd.Status)</td>
                <td align="left">$($TableAdd.PID)</td>
                <td align="left">$($TableAdd.Command)</td>
                </tr>   
"@  

}

$Table = @"
    		<table BORDER=1 WIDTH=200>
                <tr>
                <th>Name</th>
                <th>Image</th>
                <th>Port</th>
                <th>Status</th>
                <th>PID</th>
                <th>Command</th>
                $Output
                </table>
"@

@"
    <!DOCTYPE HTML>
    <html>
	    <head>
		    <title>Shipyard</title>
		    <meta charset="utf-8" />
		    <meta name="viewport" content="width=device-width, initial-scale=1" />
		    <!--[if lte IE 8]><script src="assets/js/ie/html5shiv.js"></script><![endif]-->
		    <link rel="stylesheet" href="assets/css/main.css" />
		    <!--[if lte IE 8]><link rel="stylesheet" href="assets/css/ie8.css" /><![endif]-->
		    <!--[if lte IE 9]><link rel="stylesheet" href="assets/css/ie9.css" /><![endif]-->
                    <meta http-equiv="refresh" content="30" >
	    </head>
	    <body class="landing">

		    <!-- Page Wrapper -->
			    <div id="page-wrapper">

				    <!-- Header -->
					    <header id="header" class="alt">
						    <h1><a href="index.html">Shipyard</a></h1>
					    </header>

				    <!-- Banner -->
					    <section id="banner">
						    <div class="inner">
							    <h2>Shipyard</h2>
							    <p>Deploy, Manage and Monitor Windows Server Containers</p>
                                $Table
						    </div>
					    </section>


			    </div>

		    <!-- Scripts -->
			    <script src="assets/js/jquery.min.js"></script>
			    <script src="assets/js/jquery.scrollex.min.js"></script>
			    <script src="assets/js/jquery.scrolly.min.js"></script>
			    <script src="assets/js/skel.min.js"></script>
			    <script src="assets/js/util.js"></script>
			    <!--[if lte IE 8]><script src="assets/js/ie/respond.min.js"></script><![endif]-->
			    <script src="assets/js/main.js"></script>

	    </body>
    </html>
"@ | Out-File C:\inetpub\wwwroot\index.html -Encoding utf8 -Force

} else {
@"
    <!DOCTYPE HTML>
    <html>
	    <head>
		    <title>Shipyard</title>
		    <meta charset="utf-8" />
		    <meta name="viewport" content="width=device-width, initial-scale=1" />
		    <!--[if lte IE 8]><script src="assets/js/ie/html5shiv.js"></script><![endif]-->
		    <link rel="stylesheet" href="assets/css/main.css" />
		    <!--[if lte IE 8]><link rel="stylesheet" href="assets/css/ie8.css" /><![endif]-->
		    <!--[if lte IE 9]><link rel="stylesheet" href="assets/css/ie9.css" /><![endif]-->
                    <meta http-equiv="refresh" content="30" >
	    </head>
	    <body class="landing">

		    <!-- Page Wrapper -->
			    <div id="page-wrapper">

				    <!-- Header -->
					    <header id="header" class="alt">
						    <h1><a href="index.html">Shipyard</a></h1>
					    </header>

				    <!-- Banner -->
					    <section id="banner">
						    <div class="inner">
							    <h2>Shipyard</h2>
							    <p>Deploy, Manage and Monitor Windows Server Containers</p>
                                                            <p>Currently there are no Containers running</p>
						    </div>
					    </section>


			    </div>

		    <!-- Scripts -->
			    <script src="assets/js/jquery.min.js"></script>
			    <script src="assets/js/jquery.scrollex.min.js"></script>
			    <script src="assets/js/jquery.scrolly.min.js"></script>
			    <script src="assets/js/skel.min.js"></script>
			    <script src="assets/js/util.js"></script>
			    <!--[if lte IE 8]><script src="assets/js/ie/respond.min.js"></script><![endif]-->
			    <script src="assets/js/main.js"></script>

	    </body>
    </html>
"@ | Out-File C:\inetpub\wwwroot\index.html -Encoding utf8 -Force

	
}

$Containers = docker ps -a -q

if ($Containers -ne $null){
    foreach ($Container in $Containers){

        $Config = docker inspect $Containers | ConvertFrom-Json 
        if ($config.State.Status -eq 'running'){
        $Status = "$($config.State.Status) - Started: $($config.State.StartedAt | Get-Date -f g)"
        } 
            else {
            $Status = $Config.State.Status
            }

         $TableAdd = [pscustomobject]@{
                    Name            = $Config.name
                    Image           = $Config.config.image
                    Port            = ($Config.networksettings.ports | Get-Member)[-1].Name
                    Status          = $Status
                    PID             = $Config.State.PID
                    Command         = $Config.Path
                    }

     [Array]$Output +=      
                 @"
                </tr>
                <tr>
                <td>$($TableAdd.Name)</td>
                <td>$($TableAdd.Image)</td>
                <td>$($TableAdd.Port)</td>
                <td>$($TableAdd.Status)</td>
                <td>$($TableAdd.PID)</td>
                <td>$($TableAdd.Command)</td>
                </tr>   
"@  

}

$Table = @"
    			<table border="1">
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
    <!--
	    Spectral by HTML5 UP
	    html5up.net | @n33co
	    Free for personal and commercial use under the CCA 3.0 license (html5up.net/license)
    -->
    <html>
	    <head>
		    <title>Shipyard</title>
		    <meta charset="utf-8" />
		    <meta name="viewport" content="width=device-width, initial-scale=1" />
		    <!--[if lte IE 8]><script src="assets/js/ie/html5shiv.js"></script><![endif]-->
		    <link rel="stylesheet" href="assets/css/main.css" />
		    <!--[if lte IE 8]><link rel="stylesheet" href="assets/css/ie8.css" /><![endif]-->
		    <!--[if lte IE 9]><link rel="stylesheet" href="assets/css/ie9.css" /><![endif]-->
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

}

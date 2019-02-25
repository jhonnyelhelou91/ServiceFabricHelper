$ErrorActionPreference = "Stop"

function Connect-SF {
    Param(
        #default connection is empty to link to localhost. Example: "10.2.10.1:19000"
        [string]
         $connectionEndpoint = "localhost:19000"
    )

    Write-Host 'Connecting to Service Fabric Cluster';
    if ((Get-Variable 'ClusterConnection' -Scope Global -ErrorAction 'Ignore') -and $global:ClusterConnection.ConnectionEndpoint -eq $connectionEndpoint) {
        Write-Host 'Cluster connection already exists';
    } else {
        Write-Host "Connected to Service Fabric Cluster $connectionEndpoint";
                
        [void](Connect-ServiceFabricCluster -KeepAliveIntervalInSec 10 -ConnectionEndpoint $connectionEndpoint);
        $global:ClusterConnection = $clusterConnection;
    }
}
function Get-SFDetails {
    Param(
		[Parameter(Mandatory=$true)]
		[string]
		$projectName,
		
		[string]
		$appName = '',
		
		[string]
		$path = '',
		
		[string]
		$node = "Local.1Node"
    )

    $obj = New-Object PSObject;
    $obj | add-member NoteProperty -TypeName HashTable Parameter @{};

    if ($appName -Like 'fabric:/*') {
        $obj | add-member NoteProperty Name $appName;

        return $obj;
    }

    if ($node -NotLike "*.xml") {
        $node = $node + ".xml";
    }

    Write-Host "SF Application Name - $($node): $($obj.Name)";
	$applicationParametersPath = (Get-ChildItem -Path "$path" -Include "ApplicationParameters" -Directory -Recurse).FullName;
	
	[xml]$xml = Get-Content -Path "$applicationParametersPath\$node";
	
    return $xml.Application;
}
function Update-ServiceFabricApplication {
	Param (		
		[Parameter(Mandatory=$true)]
		[string]
		$projectName,
		
		[string]
		$appName = '',

        [string]
        $solutionName = '',

		[Parameter(Mandatory=$true)]
		[string]
		$path,

        [boolean]
        $deleteType = $true,

		[string]
		$msbuildPath = (Get-Item Env:Dev.MSBuildPath -ErrorAction SilentlyContinue).Value,
		
		[string]
		$node = "Local.1Node"
    )	
    if ($node -NotLike "*.xml") {
        $node = $node + ".xml";
    }

    #when it is not provided try to resolve it automatically
    if ([string]::IsNullOrEmpty($appName)) {
        $appName = "fabric:/$($projectName)";
    }

    [System.Console]::Title = "Update SF App $appName";

    Connect-SF;
	Remove-ServiceFabricApplication -projectName $projectName -appName $appName -path "$path" -deleteType $deleteType;
	
	#remove bin, obj, pkg folders
	Remove-BuildDirectories -Path "$path";
	
	#build project
    $project = (Get-ChildItem -Path $path -Include "*$projectName*.sfproj" -Recurse | Select -First 1).FullName;
	
	If (-not(Test-Path $project)) {
		throw [System.IO.FileNotFoundException] "$project not found."
	}
	
    if ([string]::IsNullOrEmpty($solutionName)) {
        $solutionName = (Get-ChildItem -Path "$path" -Include "*.sln" -Recurse | Select -First 1).FullName;
    }

    if ($solutionName -NotLike "*.sln") {
        $solutionName = "$solutionName.sln";
    }
	
	If (-not(Test-Path $solutionName)) {
		throw [System.IO.FileNotFoundException] "$solutionName not found."
	}


	Write-Host "Restoring Packages"
    dotnet restore $solutionName --verbosity quiet
	Write-Host "Building solution $solutionName"
	& $msbuildPath $solutionName /restore /property:Platform=x64 /t:Build /clp:ErrorsOnly /m;
	if ($LASTEXITCODE -ne 0) {
		Write-Host 'Build Failed'
	}
	else {	
		Write-Host "Building/Packaging Project $project"
		& $msBuildPath $project /nologo /restore /property:Platform=x64 /t:Package /clp:ErrorsOnly;
		if ($LASTEXITCODE -ne 0) {
			Write-Host 'Build Failed'
		}
		else {
			Write-Host 'Build Succeeded'
			
			#deploy application
			$publishProfile = (Get-ChildItem -Directory -Path "$path" -Include "PublishProfiles" -Recurse | Select-Object -First 1).FullName;
			$deployAppScript = (Get-ChildItem -Path "$path" -Include "Deploy-FabricApplication.ps1" -Recurse | Select-Object -First 1).FullName;
			cd $publishProfile
			& $deployAppScript -ApplicationPackagePath '..\pkg\Debug' -PublishProfileFile $node -UseExistingClusterConnection: $True
		}
	}
}
function Remove-ServiceFabricApplication {
	Param (
		[Parameter(Mandatory=$true)]
		[string]
		$projectName,
		
		[string]
		$appName = '',

		[string]
		$path,

        [boolean]
        $deleteType = $true
	)

    $details = Get-SFDetails -projectName $projectName -appName $appName -path $path;
    $appName = $details.Name;
	Connect-SF;

    [System.Console]::Title = "Remove SF App $appName";
	#remove application
	$app = Get-ServiceFabricApplication -ApplicationName $appName
	
	#check if app already exists before deleting
	if ($app -ne $null) {
        Write-Host "SF Application $($appName) successfully Deleted";
		Remove-ServiceFabricApplication -ApplicationName $appName -Force: $true
        if ($deleteType -eq $true) {
            Unregister-ServiceFabricApplicationType -Force -ApplicationTypeName $app.ApplicationTypeName -ApplicationTypeVersion $app.ApplicationTypeVersion;
        }
	}
    else {
        Write-Host "SF Application $($appName) does not exist";
    }
}
function Remove-AllServiceFabricApplications {
    Connect-SF
	Get-ServiceFabricApplication | Foreach {
		Remove-ServiceFabricApplication -projectName $_.ApplicationName -appName $_.ApplicationName
	}
}

Export-ModuleMember -Function Update-ServiceFabricApplication
Export-ModuleMember -Function Remove-ServiceFabricApplication
Export-ModuleMember -Function Remove-AllServiceFabricApplications

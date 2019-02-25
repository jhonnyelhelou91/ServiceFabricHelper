# Service Fabric Helper

PowerShell Helper scripts to manage Service Fabric services.

## Getting Started

* Copy the files
* Open Command Line or PowerShell (*Window + X, A*)
* If you opened Command Prompt, then type *powershell* in order to use PowerShell commands
* Navigate to the scripts directory <br />`cd your_directory`
* Type <br />`Import-Module .\ServiceFabricHelper.psm1`
* Now you can use the methods from your PowerShell session

### Adding Script to Profile [Optional]

* Enable execution policy using PowerShell Admin <br /> `Set-ExecutionPolicy Unrestricted`
* Navigate to the profile path <br />`cd (Split-Path -parent $PROFILE)`
* Open the location in Explorer <br />`ii .`
* Create the user profile if it does not exist <br />`If (!(Test-Path -Path $PROFILE )) { New-Item -Type File -Path $PROFILE -Force }`
* Import the module in the PowerShell profile <br />`Import-Module -Path script_directory -ErrorAction SilentlyContinue`

# Examples

## Remove-AllServiceFabricServices Example
Remove all Service Fabric applications from your local cluster
<details>
   <summary>Remove all Service Fabric services</summary>
   <p>Remove-AllServiceFabricServices</p>
</details>

## Remove-ServiceFabricApplication Example
Remove Service Fabric application
<details>
   <summary>Remove service fabric application by project name and path</summary>
   <p>Remove-ServiceFabricApplication -ProjectName 'Test' -Path 'C:\git\Service Fabric\TestProject\'</p>
</details>
<details>
   <summary>Remove service fabric application by project name, path and application name</summary>
   <p>Remove-ServiceFabricApplication -ProjectName 'Test' -Path 'C:\git\Service Fabric\TestProject\' -AppName 'fabric:\MyTestProject.Test@0'</p>
</details>
<details>
   <summary>Remove service fabric application by project name, path and application name without deleting application type</summary>
   <p>Remove-ServiceFabricApplication -ProjectName 'Test' -Path 'C:\git\Service Fabric\TestProject\' -AppName 'fabric:\MyTestProject.Test@0' -DeleteType $false</p>
</details>

## Update-ServiceFabricApplication Example
Update Service Fabric application
<details>
   <summary>Update service fabric application by project name and path</summary>
   <p>Update-ServiceFabricApplication -ProjectName 'Test' -Path 'C:\git\Service Fabric\TestProject\'</p>
</details>
<details>
   <summary>Update service fabric application by project name and path using a different publish profile</summary>
   <p>Update-ServiceFabricApplication -ProjectName 'Test' -Path 'C:\git\Service Fabric\TestProject\' -Node 'Local.5Node'</p>
</details>
<details>
   <summary>Update service fabric application by project name, path and solution name</summary>
   <p>Update-ServiceFabricApplication -ProjectName 'Test' -Path 'C:\git\Service Fabric\TestProject\'  -SolutionName 'C:\git\Service Fabric\TestProject\TestProject.sln'</p>
</details>
<details>
   <summary>Update service fabric application by project name and path using specific msbuild</summary>
   <p>Update-ServiceFabricApplication -ProjectName 'Test' -Path 'C:\git\Service Fabric\TestProject\' -MsbuildPath 'C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\MSBuild\15.0\Bin\MSBuild.exe'</p>
</details>
<details>
   <summary>Update service fabric application by project name, path and application name</summary>
   <p>Update-ServiceFabricApplication -ProjectName 'Test' -Path 'C:\git\Service Fabric\TestProject\' -AppName 'fabric:\MyTestProject.Test@0'</p>
</details>
<details>
   <summary>Update service fabric application by project name, path and application name without deleting application type</summary>
   <p>Update-ServiceFabricApplication -ProjectName 'Test' -Path 'C:\git\Service Fabric\TestProject\' -AppName 'fabric:\MyTestProject.Test@0' -DeleteType $false</p>
</details>

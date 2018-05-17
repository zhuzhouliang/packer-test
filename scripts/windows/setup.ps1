#appDisplayName = WinCompliance Deployment
#appTypeName =WinCompliance Source Setup Module

#Version 1.01
#Modified By: Chris Yantha
#Modified On: 11-07-2016
#Reason for change: Updated Link from SSP Portal to C3

#Modified By: Hari GN
#Modified On: 05-01-2017
#Reason for change: Added reinstall and update features

#Powershell version prerequisite -  the below comment automatically verifies the ps version
#requires -Version 3.0

	<#
	.SYNOPSIS
	Script will Deploy the WinCompliance Tool

	.DESCRIPTION
    This script is intended to deploy the WinCompliance toolset.

    .PARAMETER LogFilePath - The Location for log file.
	
	.PARAMETER wcSourcePath - Source Path for WinCompliance zip package
	
	.PARAMETER wcTargetPath - Target Path where WC has to be stored by default C:\SUPPORT
	
	.PARAMETER ReInstall - Remove all traces of exiisting WinCompliance and deploy a new version
	
	.PARAMETER Revert - Unisntall WinCompliance
	
	.PARAMETER Update - Perform Update of scripts in the local WinCompliance Source from the package.
	
	.EXAMPLE
    .\SETUP.PS1 -LogFilePath C:\SUPPORT\LOGS\<LogFileName>.Log 
	 
	 .EXAMPLE
	 .\SETUP.PS1 -wcSourcePath C:\SUPPORT\WC.ZIP
	 
	 .EXAMPLE
	 .\SETUP.PS1 -ReInstall
	 
	  .EXAMPLE
	 .\SETUP.PS1 -Revert
	 
	  .EXAMPLE
	 .\SETUP.PS1 -Update
	 
 	 .NOTES
	 WinCompliance tool is designed to analyze a Windows Server OS compliance against CSC Global standards.This script is intended to deploy the WinCompliance toolset.
    - Exit 0 = Success
	- Exit 1 = Failure
	- Exit 2 = Unable to setup C:\SUPPORT
	- Exit 3 = Unable to unzip winCompliance zip
    - Exit 4 = WinCompliance package is missing
    - Exit 5 = WinCompliance Source is detected in the build.Error trying to rename the existing source.
	- Exit 6 = WinCompliance Uninstall process failed. 
    - Exit 10 = Unable to create Log Files. function Set-SOELog
    - Exit 11 = Script not executed in Admin Approval Mode
    - Exit 12 = AutoUpdater Script Exited with Error
    - Exit 14 = AutoUpdater didnt run because it was not able detect existing WinCompliance version
    - Exit 15 = WCRepo doesnt have write acess
    - Exit 16 = Error Creating wcRepo
	- Exit 17 = Existing WinCompliance Local Source Detected
    - Exit 18 = WinCompliance is not Installed
	
	.LINK
	https://c3.csc.com/groups/global-windows-server-solutions

	#>

[CmdletBinding(DefaultParameterSetName="soeModuleParams")]
Param(
$LogFilePath = "$env:SystemDrive\SUPPORT\LOGS\WinComplianceSetup.Log", # Mandatory Field
[Parameter(ParameterSetName="soeModuleParams")]
[Parameter(ParameterSetName="repo")]
[Parameter(ParameterSetName="Update")]
[Parameter(ParameterSetName="ReInstall")]
[ValidateScript({([System.IO.File]::Exists((resolve-path $_).path)) -and $_.trim().split(".")[-1] -eq 'zip'})] $wcSourcePath = "$psScriptRoot\WinCompliance.zip",
[Parameter(ParameterSetName="soeModuleParams")]$wcTargetFolder = "$env:SystemDrive\SUPPORT",
[Parameter(ParameterSetName="repo")] [Switch] $Revert,
[Parameter(ParameterSetName="ReInstall")][Switch] $ReInstall,
[Parameter(ParameterSetName="Update")][Switch] $Update,
[Parameter(ParameterSetName="repo")]
[ValidateScript({(([uri]($_)).IsUNC)})]$wcRepositoryPath #repo Path should be empty and should be a UNC
)

#region Common Functions
#Function to Set-Log
Function Set-SOELog($LogFilePath) {
    Try {
        if (!(Test-Path $LogFilePath)) {
            New-Item $LogFilePath -Type File -Force | Out-Null;
        }
        $Script:LogPath = $LogFilePath
    }
    Catch {
        Exit 10; #Exit 10  failed
    }

}

#Function to Write messages to the log file that was set using Set-SOELog function
Function Write-SOELog($Message) { 
    
    if($Message -ne $NULL) {
        Write-Verbose $Message -Verbose;

        if(Test-Path $Script:LogPath) {
            Add-Content -Path $Script:LogPath -Value "$(get-date -format "MM/dd/yyyy hh:mm:ss") : $Message";
        }
    }

}

#Function to Verify Admin approval Mode - whether script is launched using Administrative credentials
Function Test-AdminApprovalMode() {
    return ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator");
}

# This function will return whether current server provisioning method is SOE build or SOE modules
Function Get-InstallMode{
    If ($psScriptRoot.ToUpper().contains("SUPPORT") -and $psScriptRoot.ToUpper().contains("BOOT") `
        -and $psScriptRoot.ToUpper().contains("_APPS") -and (Test-Path -Path "$env:systemdrive\SUPPORT\sbmConfig.xml")){
        Return "Build" #Detected as running within the original Windows Server SOE Install process
    }
    Else {
        Return "Modular" #Detected as running as a standalone modue
     }
}

# If module need to set branding information in Registry, this function can be used
Function Set-SOEBrandingRegistry {    
    param(
        $SOERegPath = "HKLM:\SOFTWARE\CSC\SOE", # default SOE registry location
        $BrandingName, # name of branding element..like SNMP, IPv6, etc.
        $BrandingValue # value for branding element
    )

    # if SOE registry location doesn't exist then create it
    if(!(Test-Path $SOERegPath)){New-Item $SOERegPath -Force | Out-Null}

    #Append Script InstallMode with Branding
    Set-ItemProperty -Path $SOERegPath -Name $BrandingName -Value $BrandingValue
}
#endregion

#region Functions copied from wcManagement Console
#Function to check whether repo already exists in wmc Config File or share
Function Test-WMCRepoExists {
Param (
$RepositoryLocation,
[Switch]$WriteAccess
)
    try {
        #check to see a connection can be established to RepositoryLocation
        if((Test-Path $RepositoryLocation) -eq $false) { return "Error : Unable to connect to specified repo Location: $RepositoryLocation" }

		#check to see if we have write access  to the share
        if($WriteAccess.IsPresent) {
            $wcTime = (date).ToString('MMddyyhhmmss');
            New-Item "$RepositoryLocation\wcrepowatest_$wcTime.txt" -ErrorAction SilentlyContinue | Out-Null
            if((Test-Path "$RepositoryLocation\wcrepowatest_$wcTime.txt") -eq $false) {
                return "Error : Unable to create repository on the specified Repository Location.Please check the access to repository location"
            }
			else {
				Remove-Item "$RepositoryLocation\wcrepowatest_$wcTime.txt" -Force
			}
        }

        #else return success
        return "Success"
    }
    catch {
        return "Error : $($_.Exception.Message)"
    }  
}

#Function to create a new repository
function New-WMCRepository { 

Param (
    [Parameter(Mandatory=$true)][String]$RepositoryLocation,
    $RepoLocationStructure = @("Inventory","WinCompliance","Reports","Logs")
    )
    try {
        #create the repository folder structure   
        foreach($RepositoryDirectory in $RepoLocationStructure) {
            if(!(Test-Path "$RepositoryLocation\$RepositoryName\$RepositoryDirectory")) {
                New-Item -ItemType Directory -Path "$RepositoryLocation\$RepositoryName\$RepositoryDirectory" -Force | Out-Null
            }
        }
        #create structure for Inventory File
        $repoValue =@"
            {
                "HostID": "1",

                "Hosts": [

                ],

                "Groups": 
                {
                }
            }
"@

        #create Inventory File     
        if(!(Test-Path "$RepositoryLocation\$RepositoryName\Inventory\wcInventory.JSON")) { #skip in case of existing repo
            ConvertFrom-JSON $repoValue | Convertto-JSON | Out-File "$RepositoryLocation\$RepositoryName\Inventory\wcInventory.JSON"
        }
		return "Success"
    }
    catch {
        return "Error : $($_.Exception.Message)"
    }
}
#endregion
#region Functions related to this script
#Function to create the WC Source Paths -folders for Logging etc
Function Set-WCSource($SourcePath) {
    try {
        if(!(test-Path $SourcePath)) {
            Write-SOELog -Message "Creating Directory : $SourcePath"
            New-Item -ItemType "Directory" -Path $SourcePath -Force | Out-Null;
        }
    }
    catch {
        Write-SOELog -Message $_.Exception.Message
        Exit 4;
    }
}
Function Expand-ZIPFile($sourceFile,$targetFolder) {
	try {
		Write-SOELog -Message "Extracting $sourceFile to $targetFolder"
		[System.Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem') | Out-Null
		[System.IO.Compression.ZipFile]::ExtractToDirectory($sourceFile, $targetFolder)
	}
	catch {
		Write-SOELog -Message $_.Exception.Message
		Exit 3;
	}
}

#WC Registry Branding
Function Set-WCBranding {    
    param(
        $SOERegPath = "HKLM:\SOFTWARE\CSC\WinCompliance", # default SOE registry location
        $BrandingName, # "GlobalVersion.
        $BrandingValue # 1.1
    )

    # if SOE registry location doesn't exist then create it
    if(!(Test-Path $SOERegPath)){New-Item $SOERegPath -Force | Out-Null}

    #Append Script InstallMode with Branding
    Set-ItemProperty -Path $SOERegPath -Name $BrandingName -Value $BrandingValue

}

#Test existance of Mandaory Files and WC Source
Function Test-WCSource($SourcePath,$wcPackagePath) {
    try {
	
		#check for any version of wc installed
		$wcExistingSource = (Get-ItemProperty HKLM:\SOFTWARE\CSC\WinCompliance -Name InstallFolder -ErrorAction SilentlyContinue).InstallFolder
		if($wcExistingSource) {
			if(Test-Path $wcExistingSource) {
				Write-SOELog "An existing WinCompliance Source detected at $wcExistingSource .You may wish to uninstall using -revert parameter and try installation again"
				exit 17;
			}
		}
        
		#check for wc package
		if(!(Test-Path $wcPackagePath))  {        
            Write-SOELog "WinCompliance package is missing.Exiting with return code = 4"
            Exit 4;
        }
		elseif((Test-Path "$SourcePath\wcremediation.ps1") -and (Test-Path "$SourcePath\modules\wcUtils.psm1"))  {        
            Write-SOELog "WinCompliance source already exists at $SourcePath.You will need to use the reinstall parameter to remove existing package and install a new package"
            Exit 4;
        }
        elseif(Test-Path $SourcePath) { # WinCompliance 2.2 or older version
           Write-SOELog -Message "$SourcePath detected in the Build."
           Write-SOELog -Message "Renaming the existing WinCompliance Source to $($SourcePath)_OLD";
           $FolderName = ($SourcePath.Split("\"))[-1]
           Rename-Item -Path $SourcePath -NewName "$($FolderName)_OLD"
        }
    }
    catch {
        Write-SOELog -Message $_.Exception.Message
        Exit 5;
    }
}
#Test existance of Mandaory Files and WC Source
Function Remove-WinCompliance{
param(
	$SourcePath,
	$RegPath = "HKLM:SOFTWARE\CSC\WinCompliance",
    [Switch]$SkipRegClean
	) 
    try {
		Write-SOELog -Message "WinCompliance Path : $SourcePath"
		if($SourcePath){
			if(Test-Path "$SourcePath\WinCompliance") {
				Write-SOELog -Message "Deleting WinCompliance Source Folder : $SourcePath"

				#Check whether its a valid WC Source
				if((Test-Path "$SourcePath\WinCompliance\wcremediation.ps1") -and (Test-Path "$SourcePath\WinCompliance\modules\wcUtils.psm1")) {
					#remove WC Source Folder
					Remove-Item -Path "$SourcePath\WinCompliance" -Recurse -Force
				}
			}
			else {
				Write-SOELog -Message "WinCompliance Source Folder : $SourcePath doesn't exists"
			}
		}
		
		if(!($SkipRegClean.IsPresent)) {
			Write-SOELog -Message "Cleaning WinCompliance Registry : $RegPath"
			#cleanup Registry
			if(Test-Path $RegPath) {
				Remove-Item $RegPath -Recurse -Force;
			}
		}
	}
	catch {
		Write-SOELog -Message $_.Exception.Message
        Exit 6; #Remove process failed.
	}
}
Function Set-wcTempPath($wcSourcePath,$wcTempPath) {
    try {

        Write-SOELog -Message "Creating Team Path $wcTempPath"

        if(Test-Path $wcTempPath) { Remove-Item "$wcTempPath" -Force -Recurse }
        New-Item -ItemType Directory -Path "$wcTempPath" -Force  | Out-Null

        #Unzip WC ZIP File       
        Write-SOELog -Message "Unzip WinCompliance Source to $wcTempPath"
        Expand-ZIPFile -sourceFile $wcSourcePath -targetFolder "$wcTempPath"

        #Update the autoConfig XML asking not to replace the ticonfig.xml
        $autoConfigPath = "$wcTempPath\WinCompliance\Config\wcmautoupdateclientconfig.xml"

        [xml]$autoConfigXML = Get-Content $autoConfigPath
        $tiConfig = $autoConfigXML.CreateElement("File")
        $tiConfig.InnerText = "tiConfig.xml"
        $autoConfigXML.WCMAutoUpdateConfig.Settings.ExcludeList.AppendChild($tiConfig) | Out-Null;

        #Update Repository Path
        $autoConfigXML.WCMAutoUpdateConfig.RepositoryLocation.Config.SetAttribute("Location",$wcTempPath)
        $autoConfigXML.Save($autoConfigPath);

        #return AutoConfig xml
        return $autoConfigPath;

    }
    catch {
        Write-SOELog -Message $_.Exception.Message
        return "Error"
    }
}
#endregion

#region 
#Validate Admin Approval Mode
if(!(Test-AdminApprovalMode)) { Exit 11;}

#change verbose message background
((Get-Host).PrivateData).VerboseBackgroundColor =($host.UI.RawUI).BackGroundColor;
#endregion

#Set LogPath
Set-SOELog -LogFilePath $LogFilePath

#Identify build provisioning method - SOEBuild or SOEModularized 
$InstallMode = Get-InstallMode

#Assign BrandHeader for this script

Write-SOELog -Message "Platform Windows Server SOE - WinCompliance Deployment Module" #Update Install Action  - Mandatory Field
Write-SOELog -Message "Powershell Version: $($psversiontable.PSVersion.ToString())"
Write-SOELog -Message "Installation method detected as $InstallMode"

#change verbose message background
((Get-Host).PrivateData).VerboseBackgroundColor =($host.UI.RawUI).BackGroundColor;
#endregion


if($wcRepositoryPath) { #Actions Specific to WCRepo
	$wcTargetFolder = $wcRepositoryPath #Set Target Folder to WinCompliance Repository
    Write-SOELog "Repository : $wcRepositoryPath"
    
    $Result = Test-WMCRepoExists -RepositoryLocation $wcRepositoryPath -WriteAccess ; #Test Repository for write Access
    Write-SOELog "Testing write Access to Repository : $Result"

	if($Result -eq "Success") {

	    if(!($Revert.IsPresent)) { #Setup WinCompliance Repository
						        
			#check if existing repository
			if(Test-Path "$RepositoryLocation\WinCompliance") { 
				Write-SOELog "Repository already exists at $RepositoryLocation\WinCompliance"
				exit 192;
			} 
		
            #Create Repository
			$Result = New-WMCRepository -RepositoryLocation $wcRepositoryPath -RepoLocationStructure  @("Inventory","Reports","Logs")
            Write-SOELog "Creating and setting up Repository : $Result"

			#Return Error if there were issues accesing repository
            if($Result -ne "Success") { 
				exit 16;
			}
            else {
                Expand-ZIPFile -sourceFile $wcSourcePath -targetFolder $wcTargetFolder #extract wc
                Write-SOELog "Succesfully Extracted WinCompliance in Repository"
                Exit 0;
            }
		}
        elseif($Revert.IsPresent) { #clean up repo
            Write-SOELog "Cleaning up Repository : $Result"
            Remove-WinCompliance -SourcePath $wcTargetFolder -SkipRegClean;
            exit 0;
        }
		else { #Unknown Parameter
			Exit 128;
		}
	}
    else {
        exit 15;
    }
}
elseif($Update.IsPresent) { #This feature is to  local source
 
    $wcTempPath = "$env:Temp\WcRepo"
    $wcInstallPath = (Get-ItemProperty HKLM:\SOFTWARE\CSC\WinCompliance -Name InstallFolder -ErrorAction SilentlyContinue).InstallFolder

    if($wcInstallPath) {

        $AutoConfigXML = Set-wcTempPath -wcSourcePath $wcSourcePath -wcTempPath $wcTempPath

        if($AutoConfigXML -ne "Error") {
        
            Write-SOELog "wcInstallPath : $wcInstallPath"

            #Launch Auto Update Command with autoConfigXML
            Write-SOELog "Launching Auto Updater Script"
            $wcUpdaterReturn =  Invoke-Expression "$wcInstallPath\wcAutoUpdate.ps1 -autoConfigXML $AutoConfigXML";

            #Remove temp Path
            Remove-Item $wcTempPath -Recurse -Force;

            Write-SOELog "ExitCode : $($wcUpdaterReturn.ExitCode)"
            Write-SOELog "Message : $($wcUpdaterReturn.Message)";
            Write-SOELog "Status : $($wcUpdaterReturn.Status)";
            exit $($wcUpdaterReturn.ExitCode);

        }
        else {
            exit 12; #Auto Updater Script Error
        }
    }
    else {
        Write-SOELog "Existing WinCompliance source is not detected.Skipping Update Process"
        exit 14;
    }
      
}
elseif($Revert.IsPresent -or $ReInstall.IsPresent) { #Local revert and reinstall 
    
    #Identoify Current WC Location for Reinstall
    $wcTargetFolder = (Get-ItemProperty HKLM:\SOFTWARE\CSC\WinCompliance -Name InstallFolder -ErrorAction SilentlyContinue).InstallFolder
	
	if(!($wcTargetFolder)) { 
		if($ReInstall.IsPresent) {
			Write-SOELog "WinCompliance is not Installed, you may wish to use -install parameter to perform a fresh install";
			Exit 18;
		}
	}
	elseif(!(Test-Path $wcTargetFolder)) {Write-SOELog "WinCompliance package doesnt exists at $wcTargetFolder" }
	else{ 
		$wcIndex = ($wcTargetFolder.Split("\")[-1]).Length
		$wcTargetFolder = $wcTargetFolder.SubString(0,$wcTargetFolder.Length - ($wcIndex + 1));
	}
	
	#Cleanup WinCompliance and Exit
	Remove-WinCompliance -SourcePath $wcTargetFolder

	Write-SOELog "WinCompliance successfully un-installed.Exiting with return code = 0"
	
	#If its ReInstall proceed with Install procedures ,if its revert/uninstall then skip
	if($Revert.IsPresent)  { Exit 0; } #Exiting the script here
    
    
}

#Section Fresh Install - Applicable for Reinstall or Fresh Install

#region Setup wcSource
#Check for existance of C:\Support\WinCompliance and reaname if needed.
Test-WCSource -SourcePath "$wcTargetFolder\WinCompliance" -wcPackagePath $wcSourcePath
#Setup WinCompliance Source
Set-WCSource -SourcePath $wcTargetFolder
#Unzip WC ZIP File
Expand-ZIPFile -sourceFile $wcSourcePath -targetFolder $wcTargetFolder
#endregion

#region Branding
if(!($wcRepositoryPath)) { #Dont Update Registry Key if you are creating a repository
    [xml]$xml = get-content "$wcTargetFolder\WinCompliance\Config\wcConfig.xml"
    Write-SOELog "Updating WinCompliance Registry Branding"
    Set-WCBranding -BrandingName "GlobalVersion" -BrandingValue $xml.WinCompliance.version
    Set-WCBranding -BrandingName "InstallDate" -BrandingValue $(Get-Date).ToString('MM-dd-yy hh:mm:ss')
	Set-WCBranding -BrandingName "InstallFolder" -BrandingValue "$wcTargetFolder\WinCompliance"
}
#endregion

Write-SOELog "WinCompliance Setup Module successfully completed execution.Exiting with return code = 0"
Exit 0

#endregion Main

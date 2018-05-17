function Run-Script {
  param([string]$scriptArgs)

  Write-Host "Running script $scriptArgs"
  $command = Start-Process -FilePath powershell.exe -ArgumentList $scriptArgs -Wait -PassThru
  $code = $command.ExitCode
  Write-Host "Exit code is : $code"
  If ($code -eq 0) {
    Write-Host "Installation of $scriptArgs succeeded."
  } else {
    Write-Error "Installation of $scriptArgs failed."
  }
}
#
$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$output = "$PSScriptRoot\wincompliance.zip"
#
Add-Type -assembly "system.io.compression.filesystem"
[io.compression.zipfile]::ExtractToDirectory($output, $PSScriptRoot)
while ($(Test-Path $PSScriptRoot\wincompliance) -eq $false)
        { Start-Sleep -Milliseconds 100 }
Run-Script -scriptArgs ".\setup.ps1"
cd "$PSScriptRoot\wincompliance"
Set-Location wincompliance
if ($((gwmi win32_operatingsystem).caption).Contains("Windows Server 2012 R2")) {
    Run-Script -scriptArgs @( ".\WCRemediation.ps1",  "-ReportXMLFile",".\baseline\soedefault\SOE612.xml","-remediateAll","-UpdateBranding","-Ignorerescan","-Confirm:`$false")
} elseif ($((gwmi win32_operatingsystem).caption).Contains("Microsoft Windows Server 2016")){
    Run-Script -scriptArgs @( ".\WCRemediation.ps1",  "-ReportXMLFile",".\baseline\soedefault\SOE612.xml","-remediateAll","-UpdateBranding","-Ignorerescan","-Confirm:`$false")
} elseif ($((gwmi win32_operatingsystem).caption).Contains("Windows Server 2012")){
    Run-Script -scriptArgs @( ".\WCRemediation.ps1",  "-ReportXMLFile",".\baseline\soedefault\SOE612.xml","-remediateAll","-UpdateBranding","-Ignorerescan","-Confirm:`$false")
}
Remove-Item $PSScriptRoot\wincompliance.zip -Force
Remove-Item $PSScriptRoot\wincompliance -Recurse -Force
$user = Get-WMIObject Win32_UserAccount -Filter "Name='soe-load'"
if ( $user -ne $null ) { $user.Rename('Administrator') }

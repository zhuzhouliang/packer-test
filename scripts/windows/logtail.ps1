  $client = new-object System.Net.WebClient
  $client.DownloadFile('http://logtail-release.oss-$1.aliyuncs.com/win/logtail_installer.zip', 'c:\logtail_installer.zip')

  $Source = 'c:\logtail_installer.zip'
  $Destination = 'C:\'
  $ShowDestinationFolder = $true
   
  if ((Test-Path $Destination) -eq $false)
  {
    $null = mkdir $Destination
  }

  $shell = New-Object -ComObject Shell.Application
  $sourceFolder = $shell.NameSpace($Source)
  $destinationFolder = $shell.NameSpace($Destination)
  $DestinationFolder.CopyHere($sourceFolder.Items())
   
  if ($ShowDestinationFolder)
  {
    explorer.exe $Destination
  }

  cd c:\logtail_installer
  .\logtail_installer.exe install $1_vpc

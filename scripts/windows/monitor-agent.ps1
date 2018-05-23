  $client = new-object System.Net.WebClient
  $client.DownloadFile('http://cms-download.aliyun.com/release/1.2.24/windows64/agent-windows64-1.2.24-package.zip?spm=a2c4g.11186623.2.3.AZh44G&file=agent-windows64-1.2.24-package.zip', 'c:\agent-windows64-1.2.24-package.zip')

  $Source = 'c:\agent-windows64-1.2.24-package.zip'
  $Destination = 'C:\Program Files (x86)\Alibaba\cloudmonitor'
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

  cd C:\Program Files (x86)\Alibaba\cloudmonitor\wrapper\bin
  .\AppCommand.bat install
  .\AppCommand.bat start

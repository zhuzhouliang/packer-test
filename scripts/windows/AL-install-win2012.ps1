New-Item -ItemType directory -Path \"C:\\Temp\\soe_harden" -Force
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$src = 'https://www.python.org/ftp/python/3.7.0/python-3.7.0b4-amd64-webinstall.exe'
$des = 'c:\\Temp\\soe_harden\\python-3.7.0b4-amd64-webinstall.exe'
Invoke-WebRequest -Uri $src -OutFile $des

$work='c:\Temp\soe_harden\python-3.7.0b4-amd64-webinstall.exe /quiet /passive InstallAllUsers=1 PrependPath=1' 
iex $work 
Start-Sleep -s 160 
$PATH=[Environment]::GetEnvironmentVariable(\"PATH\") 
Write-Host $PATH

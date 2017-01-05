#Set-Item WSMan:\localhost\Client\TrustedHosts -Value 192.168.12.211 -Force -Concatenate
#Get-Item WSMan:\localhost\Client\TrustedHosts

Param(
  $userName = "llaaxag",
  $localInstallFolder = "D:\Install",
  $remoteServer = "23.97.136.79",
  $remoteInstallDrive = "C$",
  $remoteInstallPath = "E:\Install\",
  $localInstallScript = "localInstall.ps1",
  $applicationName = "IIIFServer",
  $zipFileName = "iiif.zip",
  $passwordFilePath = ".\cred.txt"
)

#skapa path som används när PSDrive skapas
$splt = $remoteInstallPath.Split("{\}");
$rmtPath = "\\${remoteServer}"
foreach ($part in $splt) {
    $part = $part.Replace(":", "$");
	$rmtPath = $rmtPath + "\" + $part
}
Write-Host $rmtPath
 
#Stoppa exekvering vid fel. Funkar dock inte alltid vid anrop av externa paket/program.
$ErrorActionPreference = "Stop"

Write-Host "Current user name is $userName"
Write-Host "Local install path is $localInstallFolder"
Write-Host "Remote server is $remoteServer"

# Läs lösenord från fil och skapa credentials
$password = get-content $passwordFilePath | convertto-securestring
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $userName,$password

Write-Host "Compress Install folder"
$source = "$localInstallFolder\$applicationName"
$destination = "$localInstallFolder\$zipFileName"
If(Test-path $destination) {Remove-item $destination}
Add-Type -assembly "system.io.compression.filesystem"
[io.compression.zipfile]::CreateFromDirectory($source, $destination)

Write-Host "Deleting old PSDrive if it already exists"
$psDriveName = "IIIFserver"
if (Test-Path("${psDriveName}:")) { Remove-PSDrive $psDriveName }
if (@(Get-PSDrive -PSProvider FileSystem | where Name -eq $psDriveName).Length -gt 0) { Remove-PSDrive $psDriveName }
Write-Host "Create Drive to remote server"
New-PSDrive -Name $psDriveName -PSProvider FileSystem -Root $rmtPath -Credential $cred -Scope global

Write-Host "Copy compressed file to remote server using the new PSDrive"
cp $destination ${psDriveName}:\

Invoke-Command -ComputerName $remoteServer -Credential $cred -ScriptBlock {
  param ($installPath)
  $remoteZipFile = "$installPath\iiif.zip"
  $remoteOutPath = "$installPath\IIIFserver"
  If(Test-path $remoteOutPath) {Remove-item $remoteOutPath -Recurse}
  Add-Type -assembly "system.io.compression.filesystem"
  [System.IO.Compression.ZipFile]::ExtractToDirectory($remoteZipFile, $remoteOutPath)
} -ArgumentList $remoteInstallPath

Invoke-Command -ComputerName $remoteServer -Credential $cred -ScriptBlock {
  param ($installScript)
  E:\Install\IIIFserver\Latest\"Install IIIFServer.bat"
} -ArgumentList $localInstallScript
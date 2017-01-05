#Set-Item WSMan:\localhost\Client\TrustedHosts -Value 192.168.12.211 -Force -Concatenate
#Get-Item WSMan:\localhost\Client\TrustedHosts

Param(
  $userName = "llaaxag",
  $localInstallFolder = "D:\Install",
  $remoteServer = "23.97.136.79",
  $remoteInstallPath = "E:\Install\",
  $localInstallScript = "localInstall.ps1",
  $passwordFilePath = ".\cred.txt"
)


Write-Host "Current user name is $userName"
$password = get-content $passwordFilePath | convertto-securestring
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $userName,$password

$source = "$localInstallDrive\IIIFserver"
$destination = "$localInstallDrive\ZipPaket\iiif.zip"
If(Test-path $destination) {Remove-item $destination}
Add-Type -assembly "system.io.compression.filesystem"
[io.compression.zipfile]::CreateFromDirectory($source, $destination)

$psDriveName = "IIIFserver"
if (Test-Path("${psDriveName}:")) { Remove-PSDrive $psDriveName }

New-PSDrive -Name $psDriveName -PSProvider FileSystem -Root "\\${remoteServer}\E$\Install" -Credential $cred -Scope global
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
#Set-Item WSMan:\localhost\Client\TrustedHosts -Value 192.168.12.211 -Force -Concatenate
#Get-Item WSMan:\localhost\Client\TrustedHosts

$remoteServer = "192.168.12.211"
$cred = Get-Credential

#Kopiera dontcopy-fil
Copy-Item -Path 'D:\Install\dontcopy\dont_copy_IIIF.txt' -Destination D:\Install\IIIFserver\dont_copy.txt -Force

$source = "D:\Install\IIIFserver"
$destination = "D:\Install\ZipPaket\iiif.zip"
If(Test-path $destination) {Remove-item $destination}
Add-Type -assembly "system.io.compression.filesystem"
[io.compression.zipfile]::CreateFromDirectory($source, $destination)

$psDriveName = "IIIFserver"
if (Test-Path("${psDriveName}:")) { Remove-PSDrive $psDriveName }

New-PSDrive -Name $psDriveName -PSProvider FileSystem -Root "\\${remoteServer}\E$\Install" -Credential $cred -Scope global
cp $destination ${psDriveName}:\

Invoke-Command -ComputerName $remoteServer -Credential $cred -ScriptBlock {
  $remoteZipFile = "E:\Install\iiif.zip"
  $remoteOutPath = "E:\Install\IIIFserver"
  If(Test-path $remoteOutPath) {Remove-item $remoteOutPath -Recurse}
  Add-Type -assembly "system.io.compression.filesystem"
  [System.IO.Compression.ZipFile]::ExtractToDirectory($remoteZipFile, $remoteOutPath)
}

Invoke-Command -ComputerName $remoteServer -Credential $cred -ScriptBlock {
  E:\Install\IIIFserver\Latest\"Install IIIFServer.bat"
}
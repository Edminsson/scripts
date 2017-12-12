#Use:
# localInstall.ps1 [-copyConfig]
# The copyConfig argument is optional. Use it to overwrite the current web.config
Param(
  [switch] $copyConfig,
  $installFolder = "C:\Inetpub",
  $backupFolder = "C:\Backup"
)

#Stoppa exekvering vid fel. Funkar dock inte alltid vid anrop av externa paket/program.
$ErrorActionPreference = "Stop"

#Variabeldeklarationer
$ApplicationName = "IIIFServer"
$InstallDir = "$installFolder\$ApplicationName"
$BackupDir = "$backupFolder\$ApplicationName"

if(-not (Test-Path $BackupDir)) { Write-Host "$BackupDir saknas" -BackgroundColor Red; return}

# Alias for 7-zip
if (-not (test-path "$env:ProgramFiles\7-Zip\7z.exe")) {throw "$env:ProgramFiles\7-Zip\7z.exe needed"}
set-alias sz "$env:ProgramFiles\7-Zip\7z.exe"

Write-Host "Starting update script for $ApplicationName"

Write-Host "Compress $ApplicationName"
sz a "test$(get-date -f yyyyMMddHHmmss)" $ApplicationName >7zlog.txt

if ($LASTEXITCODE -gt 0) { Write-Host "Det uppstod ett fel vid komprimeringen"; return}

Write-Host "Move $ApplicationName backup"
Move-Item 7zlog.txt $BackupDir -Force
Move-Item *.7z $BackupDir

if (Test-Path $InstallDir){
  if ($copyConfig) {
    Write-Host "Delete application $ApplicationName including web.config"
    Get-ChildItem -Path $InstallDir -Recurse | Remove-Item -Force -Recurse
  }
  else {
    Write-Host "Delete application $ApplicationName but exclude web.config"
    Get-ChildItem -Path $InstallDir -Recurse -Exclude "web.config" | Remove-Item -Force -Recurse
  }

  if ($copyConfig) {
    Write-Host "Copy new application $ApplicationName including web.config"
    Get-ChildItem -Path $ApplicationName |
    Copy-Item -Destination $InstallDir -Recurse -Container
  }
  else {
    Write-Host "Copy new application $ApplicationName, but exclude web.config"
    Get-ChildItem -Path $ApplicationName -Exclude "web.config" |
    Copy-Item -Destination $InstallDir -Recurse -Container

    if (Test-Path "$ApplicationName\Views") {
      Copy-Item "$ApplicationName\Views\Web.config" "$InstallDir\Views"
    }
    else {
      Write-Host "$InstallDir\Views saknas" -BackgroundColor Red
    }
  }

  Write-Host Comparing IIIF folders
  $iiifSource = Get-ChildItem -Recurse -path $ApplicationName | foreach {Get-FileHash -Path $_.FullName}
  $iiifDest = Get-ChildItem -Recurse -path $InstallDir | foreach {Get-FileHash -Path $_.FullName}
  $folderDiff = @((Compare-Object -ReferenceObject $iiifSource -DifferenceObject $iiifDest -Property hash -PassThru))
  if ($folderDiff.Length -eq 0) {
    Write-Host "Source and dest folders are identical" -BackgroundColor Yellow -ForegroundColor Black
  }
  else {
    Write-Host "There are differences between source and dest folders" -BackgroundColor Yellow -ForegroundColor Black
    Write-Host $folderDiff.Path -BackgroundColor Yellow -ForegroundColor Black
  }

}
else { 
  Write-Host "$InstallDir saknas" -BackgroundColor Red 
}
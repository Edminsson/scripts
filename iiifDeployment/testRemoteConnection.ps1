Param(
  $remoteServer = "192.168.12.73",
  $userName = "Administratör",
  $passwordFilePath = ".\cred.txt"
)
#Get-Item WSMan:\localhost\Client\TrustedHosts

Write-Host "Remote server is $remoteServer"
Write-Host "Current user name is $userName"
Write-Host "Password file path is $passwordFilePath"

Write-Host Creating Credentials
$password = get-content $passwordFilePath | convertto-securestring
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $userName,$password
$cred

Write-Host Connecting to remote server
Invoke-Command -ComputerName $remoteServer -Credential $cred -ScriptBlock { Get-Process }
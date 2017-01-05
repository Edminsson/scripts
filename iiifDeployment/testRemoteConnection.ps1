Param(
  $passwordFilePath = ".\cred.txt",
  $remoteServer = "23.97.136.79",
  $userName = "llaaxag"
)

#Get-Item WSMan:\localhost\Client\TrustedHosts

Write-Host "Current user name is $userName"

$password = get-content $passwordFilePath | convertto-securestring
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $userName,$password

Invoke-Command -ComputerName $remoteServer -Credential $cred -ScriptBlock { Get-Process }
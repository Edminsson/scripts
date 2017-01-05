Param(
  $passwordFilePath = ".\cred.txt",
  $userName = "llaaxag"
)

Write-Host "Current user name is $userName"

$password = get-content $passwordFilePath | convertto-securestring
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $userName,$password

$cred
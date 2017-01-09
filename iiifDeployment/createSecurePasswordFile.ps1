Param(
  $passwordFilePath = ".\cred.txt"
)

read-host -assecurestring | convertfrom-securestring | out-file $passwordFilePath
# $password = get-content C:\cred.txt | convertto-securestring
# $credentials = new-object -typename System.Management.Automation.PSCredential -argumentlist $userName,$password

Write-Host "$passwordFilePath was created"

There are two powershell scripts
- localInstall.sh 
    - makes a backup of the current web app
    - deletes the old web app
    - copies the new web app
- remoteInstall.sh
    - compress the new web app folder
    - copies the compressed file to the server
    - extracts the compressed file
    - runs the localInstall script.

remoteInstall needs
- a folder with the new web app ($source)
- the destination server must have a folder called Install in drive E:


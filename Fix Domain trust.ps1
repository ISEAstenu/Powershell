#Start remote powershell session
Enter-PSSession -ComputerName IITALTPA
#Reset the password
Reset-ComputerMachinePassword -Credential "iita\panderson" -Server IITASBS.iita.local
#Test trust relationship
Test-ComputerSecureChannel
Exit-PSSessionssue. 
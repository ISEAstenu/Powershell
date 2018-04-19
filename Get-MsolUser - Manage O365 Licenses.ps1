#Get a list of Licensed and unlicensed users

#Different Methods to search for a user
Get-MsolUser -UserPrincipalName EmailAddress | FL
Get-MsolUser -SearchString 'EmailAddress or name' | FL

#List all Licensed users
Get-MSOLUser -All | Where IsLicensed -eq True | Select DisplayName, IsLicensed

#List all unlicensed users
#Note: Includes Shared Mailboxes and Calendars
Get-MSOLUser -All | Where IsLicensed -Ne True | Select DisplayName, IsLicensed
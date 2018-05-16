param([string]$firstname,[string]$lastname,[string]$email)

$fullname = "$firstname $lastname"

Import-Module MSOnline
$Cred = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell -Credential $O365Cred -Authentication Basic -AllowRedirection
Import-PSSession $Session
Connect-MsolService –Credential $Cred

new-msoluser -userprincipalname $email -displayname $fullname -firstname $firstname -lastname $lastname -usagelocation "au"

$CheckIfUserAccountExists = Get-MsolUser -UserPrincipalName $email -ErrorAction SilentlyContinue

do {
       $CheckIfUserAccountExists = Get-MsolUser -UserPrincipalName $email -ErrorAction SilentlyContinue
       Write-Host "Checking if account has been created yet"
       Sleep 10
}
While ($CheckIfUserAccountExists -eq $Null)

$OfficeLicense = Get-MsolAccountSku 

set-msoluserlicense -addlicenses $OfficeLicense -userprincipalname $email

$checkifmailboxexists = get-mailbox $email -erroraction silentlycontinue

do {
       $checkifmailboxexists = get-mailbox $email -erroraction silentlycontinue
       Write-Host "Checking if the mailbox has been created yet"
       Sleep 10
}
While ($checkifmailboxexists -eq $Null)
set-MailboxRegionalConfiguration -identity $email -TimeZone "E. Australia Standard Time"
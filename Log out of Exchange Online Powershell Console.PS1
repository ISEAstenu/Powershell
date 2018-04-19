Function Logout {
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/
Remove-PSSession $Session
}
Logout 
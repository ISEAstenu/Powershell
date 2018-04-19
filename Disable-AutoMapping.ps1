
Set-ExecutionPolicy bypass

$UserCredential = Get-Credential
#Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication  Basic -AllowRedirection
Import-PSSession $Session

$EndUserEmailAddress = Read-Host -Prompt "Please enter the end users email address"
$SharedMailboxEmailAddress = Read-Host -Prompt "Please enter the Shared mailbox's email address." 

##########
# Confirm
##########
Write-Host
#Write-Host "Do you want to disable automapping on $SharedMailboxEmailAddress for the user $EndUserEmailAddress" -ForegroundColor Black -BackgroundColor White
#$key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Write-Host "Removing $EndUserEmailAddress permissions to $SharedMailboxEmailAddress's mailbox"  -ForegroundColor Black -BackgroundColor White
Remove-MailboxPermission $SharedMailboxEmailAddress -AccessRights FullAccess -User $EndUserEmailAddress

start-sleep 1
Write-Host "Assigning $EndUserEmailAddress Full Access permissions to $SharedMailboxEmailAddress and Disabling Automapping."  -ForegroundColor Black -BackgroundColor White
Add-MailboxPermission $SharedMailboxEmailAddress -AccessRights FullAccess -User $EndUserEmailAddress -Automapping:$false 

Write-Host "Automapping has been disabled on the $SharedMailboxEmailAddress for the user $EndUserEmailAddress" -ForegroundColor Black -BackgroundColor White
Pause

#Give Permission to shared mailbox folder
Add-MailboxFolderPermission SharedMailbox:\Inbox -User Username -AccessRights Reviewer

#View Shared Mailbox folder permissions
Get-MailboxFolderPermission SharedMailbox:\Inbox

#View Shared Mailbox permissions - Top Level
#Users who are granted access to a specific folder won't show here
Get-MailboxPermission SharedMailbox


#https://technet.microsoft.com/en-us/library/hh529943(v=exchg.141).aspx

Connect to Exchange online Powershell session
Connect-ExoPsSession

#This example grants the specified user full access permission to the shared mailbox and disables the auto-mapping feature 
#Give full access to a Shared mailbox & Disable Automapping
Remove-MailboxPermission SharedMailboxEmailAddress -AccessRights FullAccess -User EndUserEmailAddress
Add-MailboxPermission SharedMailboxEmailAddress -AccessRights FullAccess -User EndUserEmailAddress -Automapping:$false


This example removes auto-mapping on an existing shared mailbox and removes the auto-mapping behavior for users who have already been granted Full Access permissions. 

$FixAutoMapping = Get-MailboxPermission SharedMailboxEmailAddress |where {$_.AccessRights -eq "FullAccess" -and $_.IsInherited -eq $false}
$FixAutoMapping | Remove-MailboxPermission
$FixAutoMapping | ForEach {Add-MailboxPermission -Identity $_.Identity -User $_.User -AccessRights:FullAccess -AutoMapping $false}


<#What is AutoMapping
If a user is granted Full Access Permissions to another user's mailbox or to a shared mailbox, Outlook automatically loads all mailboxes to which hte user has full access.
#Note: If user already has acecss to the shared mailbox you must remove access and re-add permissions with the automapping disabled argument set.
#>

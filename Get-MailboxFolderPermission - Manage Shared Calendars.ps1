#View Shared Calendar Permissions
Get-MailboxFolderPermission SharedMailbox:\Calendar

#Give Editor permission to a Shared Calendar
Add-MailboxFolderPermission SharedMailbox:\Calendar -User 'UPN or Email'-AccessRights Editor

#Give Reviewer permission to a Shared Calendar
Add-MailboxFolderPermission SharedMailbox:\Calendar -User 'UPN or Email' -AccessRights Reviewer


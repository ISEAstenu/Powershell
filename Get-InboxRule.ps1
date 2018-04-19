#Check if a Mailbox has a rule

Get-InboxRule -Mailbox username | Select Enabled, Description | Format-List
#note: No result means there are no rules use 
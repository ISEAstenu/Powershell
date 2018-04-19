$mailSubject = "[$([Environment]::MachineName)] Last backup"
$result = (Get-WBSummary).LastBackupResultHR
$mailSubject += @("failed","succeeded")[$result -eq 0]
$recentEvents = Get-WinEvent "Microsoft-Windows-Backup" |? {$_.timecreated -gt ([DateTime]::Now).addDays(-1)} | Out-String
Send-MailMessage -to EmailAddress -From EmailAddress -Subject $mailSubject -SmtpServer SMTP.Server.com -body $recentEvents


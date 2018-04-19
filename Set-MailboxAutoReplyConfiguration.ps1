
#Out Of Office Message

$ExternalOutOfOfficeMessage = Get-Content "C:\Downloads\OOFMSG.TXT"
<#Example External TXT file Content
(#Use HTML Code to format email message, if left as default TXT file all content will be displayed on a single line)
<p>Hi</p> 
I'm on leave and won't have access to phone or emails until 31 Janurary 2018.
Please contact the main office on 1300796933 or support@integrate-it.com.au
#> 
$InternalOutOfOfficeMessage = Get-Content "C:\Downloads\OOFMSG.TXT"
<#Example Internal TXT file Content
I'm on leave and won't have access to phone or emails until 31 Janurary 2018.
#>

Set-mailboxAutoReplyConfiguration panderson@iita.co -AutoReplyState Enabled -ExternalAudience All - InternalMessage "$InternalMessage" -ExternalMessage "$ExternalMessage"
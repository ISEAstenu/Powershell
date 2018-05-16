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
Write-Output "Use [Ctrl]+click to highlight the Licenses you wish to assign and press [OK]." 
$Return = $OfficeLicense | Select AccountSkuId, ActiveUnits, ConsumedUnits | Sort AccountSkuId | Out-GridView -Title "Office 365 Licenses on $TennantName"

If ($Return)
        {  
            Clear-Host
 
            Write-Output "Licenses selected: `n"
            Write-Output $Return | select AccountSkuID
 
            #prompt to let user abort if file sources aren't correct
            #-------------------------------------------------------------
            $title      = "Assign the $OfficeLicense to $Email?"
            $message    = "You've selected the above Licenses to be assigned to $Email, do you wish to continue?"
            $yes        = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Assignes License(s) to $Email."
            $no         = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Returns to License listing."
            $options    = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
            $result     = $host.ui.PromptForChoice($title, $message, $options, 0)

            write-output  "`n"
            switch ($result)
                {
                    0 {
                        write-output "Assigning License(s)."
                    }
                    1 {
                        write-output "Refreshing License listing."
                    }
                }

        If ($result -eq 0)
        {
            ForEach ($OfficeLicense in $Return)
                {  
                    Write-Output "Assigning $OfficeLicense to $Email"
                           set-msoluserlicense -addlicenses $OfficeLicense -userprincipalname $email
                    if ($Return.ReturnValue -eq 0)
                    {   Write-Output "`n License was successfully assigned"
                    }
                    Else
                    {   Write-Output "`n Unable to assign $OfficeLicense!  Error code: $($Return.ReturnValue)"
                    }
                }
            }
        }
    } Until ($Return -eq $null)
}



$checkifmailboxexists = get-mailbox $email -erroraction silentlycontinue

do {
       $checkifmailboxexists = get-mailbox $email -erroraction silentlycontinue
       Write-Host "Checking if the mailbox has been created yet"
       Sleep 10
}
While ($checkifmailboxexists -eq $Null)
set-MailboxRegionalConfiguration -identity $email -TimeZone "E. Australia Standard Time"

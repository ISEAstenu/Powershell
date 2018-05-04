

#------------------------------------------------------------------------------
# THIS CODE AND ANY ASSOCIATED INFORMATION ARE PROVIDED “AS IS” WITHOUT
# WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT
# LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS
# FOR A PARTICULAR PURPOSE. THE ENTIRE RISK OF USE, INABILITY TO USE, OR 
# RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.
#
# AUTHOR(s):
#       Eyal Doron (o365info.com)
#------------------------------------------------------------------------------
# Hope that you enjoy it ! 
# And May the force of PowerShell will be with you   :-)
# 02-05-2014    
# Version WP- 001 
#------------------------------------------------------------------------------


Function Disconnect-ExchangeOnline {Get-PSSession | Where-Object {$_.ConfigurationName -eq "Microsoft.Exchange"} | Remove-PSSession}
function Validate-UserSelection
{
    Param(
        $AllowedAnswers,
        $ErrorMessage,
        $Selection
    )
    foreach($str in $AllowedAnswers.ToString().Split(","))
    {
        if($str -eq $Selection)
        {
            return $true
        }
    }
    Write-Host $ErrorMessage -ForegroundColor Red -BackgroundColor Black
    return $False

}

function Format-BytesInKiloBytes 
{
    param(
        $bytes
    )
    "{0:N0}" -f ($bytes/1000)
}

Function Set-AlternatingRows {
       <#
       
       #>
    [CmdletBinding()]
       Param(
             [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        [string]$Line,
       
           [Parameter(Mandatory=$True)]
             [string]$CSSEvenClass,
       
        [Parameter(Mandatory=$True)]
           [string]$CSSOddClass
       )
       Begin {
             $ClassName = $CSSEvenClass
       }
       Process {
             If ($Line.Contains("<tr>"))
             {      $Line = $Line.Replace("<tr>","<tr class=""$ClassName"">")
                    If ($ClassName -eq $CSSEvenClass)
                    {      $ClassName = $CSSOddClass
                    }
                    Else
                    {      $ClassName = $CSSEvenClass
                    }
             }
             Return $Line
       }
}


$FormatEnumerationLimit = -1


#------------------------------------------------------------------------------
# PowerShell console window Style
#------------------------------------------------------------------------------

$pshost = get-host
$pswindow = $pshost.ui.rawui

	$newsize = $pswindow.buffersize
	
	if($newsize.height){
		$newsize.height = 3000
		$newsize.width = 150
		$pswindow.buffersize = $newsize
	}

	$newsize = $pswindow.windowsize
	if($newsize.height){
		$newsize.height = 50
		$newsize.width = 150
		$pswindow.windowsize = $newsize
	}

#------------------------------------------------------------------------------
# HTML Style start 
#------------------------------------------------------------------------------
$Header = @"
<style>
Body{font-family:segoe ui,arial;color:black; }
H1{ color: white; background-color:#1F4E79; font-weight:bold;width: 70%;margin-top:35px;margin-bottom:25px;font-size: 22px;padding:5px 15px 5px 10px; }
TABLE {border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}
TH {border-width: 1px;padding: 5px;border-style: solid;border-color: #d1d3d4;background-color:#0072c6 ;color:white;}
TD {border-width: 1px;padding: 3px;border-style: solid;border-color: black;}
.odd  { background-color:#ffffff; }
.even { background-color:#dddddd; }
</style>

"@

#------------------------------------------------------------------------------
# HTML Style END
#------------------------------------------------------------------------------



$Loop = $true
While ($Loop)
{
    write-host 
    write-host ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    write-host   "Office 365 users Password management  | PowerShell Script menu"  
    write-host ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    write-host
    write-host -ForegroundColor green  'Connect PowerShell session to AD Azure and Exchange Online' 
    write-host -ForegroundColor green  '--------------------------------------------------------------' 
    write-host -ForegroundColor Yellow ' 0)   Login in using your Office 365 Administrator credentials' 
    write-host
    write-host -ForegroundColor green  '---------------------------' 
    write-host -ForegroundColor white  -BackgroundColor Blue 'Section A: Set Password never expired ' 
    write-host -ForegroundColor green  '---------------------------' 
    write-host
    write-host                                              ' 1)   Set Password never expired for a specific user'
	write-host                                              ' 2)   Disable Password never expired option for a specific user'
	write-host                                              ' 3)   Set Password never expired for all Office 365 users (BULK Mode)'
	write-host 
	write-host -ForegroundColor green  '---------------------------' 
    write-host -ForegroundColor white  -BackgroundColor Blue 'Section B: Set Password  ' 
    write-host -ForegroundColor green  '---------------------------' 
    write-host
    write-host                                              ' 4)   Set a Predefined password for Office 365 User'
	write-host                                              ' 5)   Set Temporary password for a Office 365 User'
	write-host                                              ' 6)   Set Temporary password for all Office 365 Users (BULK Mode)'
	write-host -ForegroundColor green  '---------------------------' 
    write-host -ForegroundColor white  -BackgroundColor Blue 'Section C: Office 365 password Policy  ' 
    write-host -ForegroundColor green  '---------------------------' 
    write-host
    write-host                                              ' 7)   Set Office 365 Password Policy'
	write-host -ForegroundColor green  '---------------------------' 
    write-host -ForegroundColor white  -BackgroundColor Blue ' Section D: Display Password settings  ' 
    write-host -ForegroundColor green  '---------------------------' 
    write-host
    write-host
    write-host                                              ' 8)   Display Password settings for all Office 365 users'
	write-host                                              ' 9)   Display information about Office 365 password Policy'
	write-host  
	write-host -ForegroundColor green  '---------------------------' 
    write-host -ForegroundColor white  -BackgroundColor Blue ' Section E: Troubleshooting  ' 
    write-host -ForegroundColor green  '---------------------------' 
    write-host
    write-host
    write-host                                              ' 10)   Troubleshooting - Toggle user password status (BULK Mode)'
	write-host                                              ' 11)   Export information about Office 365 user password settings'
	
	write-host -ForegroundColor green  '---------------------------' 
    write-host -ForegroundColor Blue  -BackgroundColor Yello ' Exit\Disconnect ' 
    write-host -ForegroundColor green  '---------------------------' 
    write-host
    write-host  -ForegroundColor Yellow                       ' 12)  Disconnect PowerShell session'
	write-host 
	write-host  -ForegroundColor Yellow                       ' 13)  Exit'
	write-host 
	write-host                                          

	

    $opt = Read-Host "Select an option [0-13]"
    write-host $opt
    switch ($opt) 


{


		#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
		# Step -00 |  Create a Remote PowerShell session to AD Azure and Exchange Online
		#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


		
		#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
		# Step -00 |  Create a Remote PowerShell session to AD Azure and Exchange Online
		#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


		0
        {

            # Specify your administrative user credentials on the line below 

            $user = “Admin@.....”

            # This will pop-up a dialogue and request your password
            

            #——– Import the Local Microsoft Online PowerShell Module Cmdlets and  Establish an Remote PowerShell Session to AD Azure  
            
            Import-Module MSOnline

            

            #———— Establish an Remote PowerShell Session to Exchange Online ———————

            $msoExchangeURL = “https://outlook.office365.com/powershell-liveid/”
			$connected = $false
			$i = 0
			while ( -not ($connected)) {
				$i++
				if($i -eq 4){
					
										
					Write-host
					Write-host -ForegroundColor White	ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
					Write-host
					Write-host -ForegroundColor Red    "Too many incorrect login attempts. Good bye."	
					Write-host
					Write-host -ForegroundColor White	ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
					Write-host
					
					
					exit
				}
				$cred = Get-Credential -Credential $user
				try 
				{
					$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $msoExchangeURL -Credential $cred -Authentication Basic -AllowRedirection  -ErrorAction stop
					Connect-MsolService -Credential $cred -ErrorAction stop
					Import-PSSession $session 
					$connected = $true 
				}
				catch 
				{
					Write-host
					Write-host -ForegroundColor Yellow	ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
					Write-host
					Write-host -ForegroundColor Red     "There is something wrong with the global administrator credentials"	
					Write-host
					Write-host -ForegroundColor Yellow	ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
					Write-host
				}

			}
            
			$host.ui.RawUI.WindowTitle = ("Windows Azure Active Directory |Connected to Office 365 using: " + $Cred.UserName.ToString()  ) 

            


        }




		
		

				
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# Section A: Set Password never expired
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


1{


#####################################################################
#   Set password never expired for a specific user 
#####################################################################

# Section 1: information 

clear-host

write-host
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                         
write-host  -ForegroundColor white		Information                                                                                          
write-host  -ForegroundColor white		----------------------------------------------------------------------------                                                             
write-host  -ForegroundColor white  	'This option will: '
write-host  -ForegroundColor white  	'Set user password never expired option for a specific user '
write-host  -ForegroundColor white  	'(By default Office 365 user password will expire every 90 days.)  '
write-host  -ForegroundColor white		----------------------------------------------------------------------------  
write-host  -ForegroundColor white  	'The PowerShell command that we use is: '
write-host  -ForegroundColor Yellow  	'Set-msoluser –UserPrincipalName <user UPN> -PasswordNeverExpires $True  '
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                          
write-host
write-host

					# Section 2: user input	
					
					write-host -ForegroundColor white	'User input '
					write-host -ForegroundColor white	---------------------------------------------------------------------------- 
					write-host -ForegroundColor Yellow	"You will need to provide 1 parameter:"  
					write-host
					write-host -ForegroundColor Yellow	"1. The Office 365 user UPN  "  
					write-host -ForegroundColor Yellow	"For example:  John@o365info.com"
					write-host
					$userUPN  = Read-Host "Type the the Office 365 user UPN "
					write-host
					write-host



# Section 3: PowerShell Command

Set-msoluser –UserPrincipalName $userUPN -PasswordNeverExpires $True 


# Section 4:  Indication 

write-host
write-host

if ($lastexitcode -eq 1)
{
	write-host "The command Failed :-(" -ForegroundColor red
}
else
{
write-host -------------------------------------------------------------
write-host -ForegroundColor Yellow	"The command complete successfully !" 
write-host
write-host -ForegroundColor Yellow	"The password of user: " -nonewline; write-host "$userUPN".ToUpper() -ForegroundColor White 
write-host -ForegroundColor Yellow	"was set to never expired " 
write-host -------------------------------------------------------------
}

#———— End of Indication ———————

# Section 4: Display Information

write-host
write-host ---------------------------------------------------------------------------
write-host -ForegroundColor white	Display Password information for the user:   "$userUPN".ToUpper() 
write-host ---------------------------------------------------------------------------

Get-MsolUser -UserPrincipalName $userUPN  |FL  DisplayName , PasswordNeverExpires | Out-String


#Section 5: End the Command
write-host
write-host
Read-Host "Press Enter to continue..."
write-host
write-host

}


2{


#####################################################################
#  Disable password never expired option for a specific user
#####################################################################

# Section 1: information 




clear-host

write-host
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                         
write-host  -ForegroundColor white		Information                                                                                          
write-host  -ForegroundColor white		----------------------------------------------------------------------------                                                             
write-host  -ForegroundColor white  	'This option will: '
write-host  -ForegroundColor white  	'Disable the option of - Password never expired option for a specific user '
write-host  -ForegroundColor white		----------------------------------------------------------------------------  
write-host  -ForegroundColor white  	'The PowerShell command that we use is: '
write-host  -ForegroundColor Yellow  	'Set-msoluser –UserPrincipalName <user UPN> -PasswordNeverExpires $False  '
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                          
write-host
write-host

					# Section 2: user input	
					
					write-host -ForegroundColor white	'User input '
					write-host -ForegroundColor white	---------------------------------------------------------------------------- 
					write-host -ForegroundColor Yellow	"You will need to provide 1 parameter:"  
					write-host
					write-host -ForegroundColor Yellow	"1. The Office 365 user UPN  "  
					write-host -ForegroundColor Yellow	"For example:  John@o365info.com"
					write-host
					$userUPN  = Read-Host "Type the the Office 365 user UPN "
					write-host
					write-host



# Section 3: PowerShell Command

Set-msoluser –UserPrincipalName $userUPN -PasswordNeverExpires $False 



# Section 4:  Indication 

write-host
write-host

if ($lastexitcode -eq 1)
{
	write-host "The command Failed :-(" -ForegroundColor red
}
else
{
write-host -------------------------------------------------------------
write-host -ForegroundColor Yellow	"The command complete successfully !" 
write-host
write-host -ForegroundColor Yellow	"The password of user: " -nonewline; write-host "$userUPN".ToUpper() -ForegroundColor White 
write-host -ForegroundColor Yellow	"was set to expired " 
write-host -ForegroundColor Yellow	"(By default Office 365 user password will expire every 90 days.)  " 
write-host -------------------------------------------------------------
}

#———— End of Indication ———————

# Section 4: Display Information

write-host
write-host ---------------------------------------------------------------------------
write-host -ForegroundColor white	Display Password information for the user:  "$userUPN".ToUpper() 
write-host ---------------------------------------------------------------------------

Get-MsolUser -UserPrincipalName $userUPN  |FL  DisplayName , PasswordNeverExpires | Out-String


#Section 5: End the Command
write-host
write-host
Read-Host "Press Enter to continue..."
write-host
write-host

}









3{


#####################################################################
#  Set Password never expired for all Office 365 users (BULK Mode)
#####################################################################

# Section 1: information 

clear-host

write-host
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                         
write-host  -ForegroundColor white		Information                                                                                          
write-host  -ForegroundColor white		----------------------------------------------------------------------------                                                             
write-host  -ForegroundColor white  	'This option will: '
write-host  -ForegroundColor white  	'Set user password NEVER expired option for ALL Office 365 users '
write-host  -ForegroundColor white  	'(By default Office 365 user password will expire every 90 days.)  '
write-host  -ForegroundColor white  	'Be Patience, it will take some time :-) '
write-host  -ForegroundColor white  	'(Depend on the number of Office 365 users) '
write-host  -ForegroundColor white		----------------------------------------------------------------------------  
write-host  -ForegroundColor white  	'The PowerShell command that we use is: '
write-host  -ForegroundColor Yellow  	'Get-MsolUser | Set-MsolUser –PasswordNeverExpires $True  '
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                          
write-host
write-host


# Section 2: user input


# Section 3: PowerShell Command

Get-MsolUser | Set-MsolUser –PasswordNeverExpires $True



# Section 4:  Indication 

write-host
write-host

if ($lastexitcode -eq 1)
{
	write-host "The command Failed :-(" -ForegroundColor red
}
else
{
write-host -------------------------------------------------------------
write-host -ForegroundColor Yellow	"The command complete successfully !" 
write-host
write-host -ForegroundColor Yellow	"The password for all Office 365 users was set to NEVER expired " 
write-host -------------------------------------------------------------
}

#———— End of Indication ———————

# Section 4: Display Information
write-host
write-host
write-host ------------------------------------------------------
write-host List of all users and their Password settings -ForegroundColor white
write-host -------------------------------------------------------

Get-MsolUser | Select UserPrincipalName, PasswordNeverExpires | Out-String
write-host
write-host
write-host -------------------------------------------------------


#Section 5: End the Command
write-host
write-host
Read-Host "Press Enter to continue..."
write-host
write-host

}



#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# Section B: Set Password
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


4{


#####################################################################
#  Set a predefined password for Office 365 user
#####################################################################

# Section 1: information 

clear-host

write-host
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                         
write-host  -ForegroundColor white		Information                                                                                          
write-host  -ForegroundColor white		----------------------------------------------------------------------------                                                             
write-host  -ForegroundColor white  	'This option will: '
write-host  -ForegroundColor white  	'Set a predefined password for Office 365 user '
write-host  -ForegroundColor white  	'(The user will not need to change password when login to the Office 365 portal) '
write-host  -ForegroundColor white		----------------------------------------------------------------------------  
write-host  -ForegroundColor white  	'The PowerShell command that we use is: '
write-host  -ForegroundColor Yellow  	'Set-MsolUserPassword -UserPrincipalName <User UPN> -NewPassword <Password> -ForceChangePassword $False    '
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                          
write-host
write-host


# Section 2: user input

					
					write-host -ForegroundColor white	'User input '
					write-host -ForegroundColor white	---------------------------------------------------------------------------- 
					write-host -ForegroundColor Yellow	"You will need to provide 2 parameters:"  
					write-host
					write-host -ForegroundColor Yellow	"1. The Office 365 user UPN  "  
					write-host -ForegroundColor Yellow	"For example:  John@o365info.com"
					write-host
					$userUPN  = Read-Host "Type the the Office 365 user UPN "
					write-host
					write-host
					write-host -ForegroundColor Yellow	"2) User Password" 
					write-host -ForegroundColor Yellow	"   For example: Aass#434"   
					write-host
					$userpass =  Read-Host "Type the User Password"



# Section 3: PowerShell Command

Set-MsolUserPassword -UserPrincipalName $userUPN -NewPassword $userpass -ForceChangePassword $False


# Section 4:  Indication 

write-host
write-host

if ($lastexitcode -eq 1)
{
	write-host "The command Failed :-(" -ForegroundColor red
}
else
{
write-host -------------------------------------------------------------
write-host -ForegroundColor Yellow	"The command complete successfully !" 
write-host
write-host -ForegroundColor Yellow	"A predefined password: " -nonewline; write-host "$userpass".ToUpper() -ForegroundColor White 
write-host -ForegroundColor Yellow	"For the user: " -nonewline; write-host "$userUPN".ToUpper() -ForegroundColor White 
write-host -ForegroundColor Yellow	"was created " 
write-host -------------------------------------------------------------
}

#———— End of Indication ———————

# Section 4: Display Information
write-host
write-host
write-host
write-host ---------------------------------------------------------------------------
write-host -ForegroundColor white	Display Password information for the user:  "$userUPN".ToUpper() 
write-host ---------------------------------------------------------------------------

Get-MsolUser -UserPrincipalName $userUPN  | FL  DisplayName,PasswordNeverExpires | Out-String


#Section 5: End the Command
write-host
write-host
Read-Host "Press Enter to continue..."
write-host
write-host

}







5{


#####################################################################
#  set a Temporary password for a specific user
#####################################################################

# Section 1: information 

clear-host

write-host
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                         
write-host  -ForegroundColor white		Information                                                                                          
write-host  -ForegroundColor white		----------------------------------------------------------------------------                                                             
write-host  -ForegroundColor white  	'This option will: '
write-host  -ForegroundColor white  	'Set a Temporary password for Office 365 user '
write-host  -ForegroundColor white  	'(The user will need to change password when login to the Office 365 portal) '
write-host  -ForegroundColor white		----------------------------------------------------------------------------  
write-host  -ForegroundColor white  	'The PowerShell command that we use is: '
write-host  -ForegroundColor Yellow  	'Set-MsolUserPassword -UserPrincipalName <User UPN> -NewPassword <Password> -ForceChangePassword $true    '
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                          
write-host
write-host


# Section 2: user input

					write-host -ForegroundColor white	'User input '
					write-host -ForegroundColor white	---------------------------------------------------------------------------- 
					write-host -ForegroundColor Yellow	"You will need to provide 2 parameters:"  
					write-host
					write-host -ForegroundColor Yellow	"1. The Office 365 user UPN  "  
					write-host -ForegroundColor Yellow	"For example:  John@o365info.com"
					write-host
					$userUPN  = Read-Host "Type the the Office 365 user UPN "
					write-host
					write-host
					write-host -ForegroundColor Yellow	"2) User Password" 
					write-host -ForegroundColor Yellow	"   For example: Aass#434"   
					write-host
					$userpass =  Read-Host "Type the User Password"



# Section 3: PowerShell Command

Set-MsolUserPassword -UserPrincipalName $userUPN -NewPassword $userpass -ForceChangePassword $true

# Set-MsolUserPassword -UserPrincipalName <User UPN> -NewPassword <Password> -ForceChangePassword $true 

# Section 4:  Indication 

write-host
write-host

if ($lastexitcode -eq 1)
{
	write-host "The command Failed :-(" -ForegroundColor red
}
else
{
write-host -------------------------------------------------------------
write-host -ForegroundColor Yellow	"The command complete successfully !" 
write-host
write-host -ForegroundColor Yellow	"A Temporary Password: " -nonewline; write-host "$userpass".ToUpper() -ForegroundColor White 
write-host -ForegroundColor Yellow	"For the user: " -nonewline; write-host "$userUPN".ToUpper() -ForegroundColor White 
write-host -ForegroundColor Yellow	"was created " 
write-host -------------------------------------------------------------
}

#———— End of Indication ———————

# Section 4: Display Information
write-host
write-host
write-host
write-host ---------------------------------------------------------------------------
write-host -ForegroundColor white	Display Password information for the user:  "$userUPN".ToUpper() 
write-host ---------------------------------------------------------------------------

Get-MsolUser -UserPrincipalName $userUPN  |FL  DisplayName , PasswordNeverExpires | Out-String


#Section 5: End the Command
write-host
write-host
Read-Host "Press Enter to continue..."
write-host
write-host

}









6{


#####################################################################
#  Set a Temporary Password for ALL Office 365 users (Bulk Mode)
#####################################################################

# Section 1: information 

clear-host

write-host
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                         
write-host  -ForegroundColor white		Information                                                                                          
write-host  -ForegroundColor white		----------------------------------------------------------------------------                                                             
write-host  -ForegroundColor white  	'This option will: '
write-host  -ForegroundColor white  	'Set a Temporary password for ALL Office 365 users '
write-host  -ForegroundColor white  	'(ALL users will need to change password when login to the Office 365 portal) '
write-host  -ForegroundColor white		----------------------------------------------------------------------------  
write-host  -ForegroundColor white  	'The PowerShell command that we use is: '
write-host  -ForegroundColor Yellow  	'Get-MsolUser | Set-MsolUserPassword  -NewPassword <Password> -ForceChangePassword $False    '
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                          
write-host
write-host


# Section 2: user input


					write-host -ForegroundColor white	'User input '
					write-host -ForegroundColor white	---------------------------------------------------------------------------- 
					write-host -ForegroundColor Yellow	"You will need to provide 1 parameter:"  
					write-host
					
					write-host -ForegroundColor Yellow	"1) User Password" 
					write-host -ForegroundColor Yellow	"   For example: Aass#434"   
					write-host
					$userpass =  Read-Host "Type the User Password"





# Section 3: PowerShell Command

Get-MsolUser | Set-MsolUserPassword  -NewPassword $userpass -ForceChangePassword $False



# Section 4:  Indication 

write-host
write-host

if ($lastexitcode -eq 1)
{
	write-host "The command Failed :-(" -ForegroundColor red
}
else
{
write-host -------------------------------------------------------------
write-host -ForegroundColor Yellow	"The command complete successfully !" 
write-host
write-host -ForegroundColor Yellow	"A Temporary Password: " -nonewline; write-host "$userpass".ToUpper() -ForegroundColor White 
write-host -ForegroundColor Yellow	"for ALL Office 365 users was created " 
write-host -------------------------------------------------------------
}

#———— End of Indication ———————

# Section 4: Display Information

write-host
write-host
write-host ------------------------------------------------------
write-host List of all Office 365 users and their Password settings -ForegroundColor white
write-host -------------------------------------------------------

Get-MsolUser | Select UserPrincipalName,PasswordNeverExpires | Out-String
write-host
write-host
write-host -------------------------------------------------------


#Section 5: End the Command
write-host
write-host
Read-Host "Press Enter to continue..."
write-host
write-host

}





#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# Section C: Office 365 password Policy
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<




7{


#####################################################################
# Set Office 365 password Policy
#####################################################################

# Section 1: information 




clear-host

write-host
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                         
write-host  -ForegroundColor white		Information                                                                                          
write-host  -ForegroundColor white		----------------------------------------------------------------------------                                                             
write-host  -ForegroundColor white  	'This option will: '
write-host  -ForegroundColor white  	'Set Office 365 password Policy '
write-host  -ForegroundColor white  	'(The default password Policy value of ValidityPeriod  is 90 days   '
write-host  -ForegroundColor white  	'(and the default NotificationDays value is: 15 days.)  '
write-host  -ForegroundColor white		----------------------------------------------------------------------------  
write-host  -ForegroundColor white  	'The PowerShell command that we use is: '
write-host  -ForegroundColor Yellow  	'Set-MsolPasswordPolicy -DomainName <Domain Name> -NotificationDays <Number> –ValidityPeriod <Number>  '
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                          
write-host
write-host


# Section 2: user input


write-host -ForegroundColor Yellow	"You will need to Provide 3 parameters:"  
write-host
write-host -ForegroundColor Yellow	"1) Domain name"  
write-host -ForegroundColor Yellow	"   For example: o365info.com"
write-host
$DomName = Read-Host "Type the Domain name "
write-host
write-host -ForegroundColor Yellow	"2) Validity Period Value"  
write-host -ForegroundColor Yellow	"   For example: 180"
write-host
$VPeriod = Read-Host "Type the Validity Period value "
write-host
write-host -ForegroundColor Yellow	"3) Notification Days Value" 
write-host -ForegroundColor Yellow	"   For example: 15"   
write-host
$NDays =  Read-Host "Type the Notification Days value"



# Section 3: PowerShell Command

Set-MsolPasswordPolicy -DomainName $DomName -NotificationDays $NDays –ValidityPeriod $VPeriod 



# Section 4:  Indication 

write-host
write-host

if ($lastexitcode -eq 1)
{
	write-host "The command Failed :-(" -ForegroundColor red
}
else
{
write-host -------------------------------------------------------------
write-host -ForegroundColor Yellow	"The command complete successfully !" 
write-host
write-host -ForegroundColor Yellow	"The password policy values are:  " 
write-host -ForegroundColor Yellow	"Validity Period Value is:  " -nonewline; write-host "$VPeriod".ToUpper() -ForegroundColor White 
write-host -ForegroundColor Yellow	"Notification Days value is:  " -nonewline; write-host "$NDays ".ToUpper() -ForegroundColor White 
write-host -------------------------------------------------------------
}

#———— End of Indication ———————

# Section 4: Display Information

write-host
write-host
write-host ------------------------------------------------------
write-host Display information about Office 365 password Policy for the $DomName Domain  -ForegroundColor white
write-host -------------------------------------------------------

Get-MsolPasswordPolicy -DomainName $DomName  | Out-String
write-host
write-host
write-host -------------------------------------------------------


#Section 5: End the Command
write-host
write-host
Read-Host "Press Enter to continue..."
write-host
write-host

}






#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# Section D: Display Password settings
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<




8{


#####################################################################
# Display Password settings for all Office 365 users
#####################################################################

# Section 1: information 



clear-host

write-host
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                         
write-host  -ForegroundColor white		Information                                                                                          
write-host  -ForegroundColor white		----------------------------------------------------------------------------                                                             
write-host  -ForegroundColor white  	'This option will: '
write-host  -ForegroundColor white  	'This option will display all Office 365 users and their Password settings '
write-host  -ForegroundColor white		----------------------------------------------------------------------------  
write-host  -ForegroundColor white  	'The PowerShell command that we use is: '
write-host  -ForegroundColor Yellow  	'Get-MsolUser | Select UserPrincipalName, PasswordNeverExpires  '
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                          
write-host
write-host


# Section 2: user input




# Section 3: PowerShell Command





# Section 4: Display Information



write-host
write-host
write-host ------------------------------------------------------
write-host List of all Office 365 users and their Password settings -ForegroundColor white
write-host -------------------------------------------------------

Get-MsolUser | Select UserPrincipalName, PasswordNeverExpires | Out-String
write-host
write-host
write-host -------------------------------------------------------


#Section 5: End the Command
write-host
write-host
Read-Host "Press Enter to continue..."
write-host
write-host

}




9{


#####################################################################
# Display information about Office 365 password Policy
#####################################################################

# Section 1: information 



clear-host

write-host
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                         
write-host  -ForegroundColor white		Information                                                                                          
write-host  -ForegroundColor white		----------------------------------------------------------------------------                                                             
write-host  -ForegroundColor white  	'This option will: '
write-host  -ForegroundColor white  	'Display information about Office 365 password Policy '
write-host  -ForegroundColor white		----------------------------------------------------------------------------  
write-host  -ForegroundColor white  	'The PowerShell command that we use is: '
write-host  -ForegroundColor Yellow  	'Get-MsolPasswordPolicy <Domain name>  '
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                          
write-host
write-host


# Section 2: user input

write-host -ForegroundColor Yellow	"You will need to Provide 1 parameter:"  
write-host
write-host -ForegroundColor Yellow	"1) Domain name"  
write-host -ForegroundColor Yellow	"   For example: o365info.com"
write-host
$DomName = Read-Host "Type the Domain name "
write-host


# Section 3: PowerShell Command





# Section 4: Display Information




write-host
write-host
write-host ------------------------------------------------------
write-host Display information about Office 365 password Policy for the $DomName Domain  -ForegroundColor white
write-host -------------------------------------------------------

Get-MsolPasswordPolicy -DomainName $DomName  | Out-String
write-host
write-host
write-host -------------------------------------------------------


#Section 5: End the Command
write-host
write-host
Read-Host "Press Enter to continue..."
write-host
write-host

}





#------------------------------#



#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# Section E: Troubleshooting
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<




10{


#####################################################################
#  Troubleshooting - Toggle user password status (BULK Mode)
#####################################################################

# Section 1: information 

clear-host

write-host
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                         
write-host  -ForegroundColor white		Information                                                                                          
write-host  -ForegroundColor white		----------------------------------------------------------------------------                                                             
write-host  -ForegroundColor white  	'This option will: '
write-host  -ForegroundColor white  	'1. Set user password NEVER expired option for ALL Office 365 users '
write-host  -ForegroundColor white  	'Be Patience, it will take some time :-) '
write-host  -ForegroundColor white  	'2. Set user password to expired option for ALL Office 365 users '
write-host  -ForegroundColor white  	'Be Patience, it will take some time :-) '
write-host  -ForegroundColor white		----------------------------------------------------------------------------  
write-host  -ForegroundColor white  	'The PowerShell command that we use is: '
write-host  -ForegroundColor Yellow  	'Get-MsolUser | Set-MsolUser –PasswordNeverExpires $True  '
write-host  -ForegroundColor Yellow  	'Get-MsolUser | Set-MsolUser –PasswordNeverExpires $False  '
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                          
write-host
write-host


# Section 2: user input


# Section 3: PowerShell Command

Get-MsolUser | Set-MsolUser –PasswordNeverExpires $True

# Get-MsolUser | Set-MsolUser –PasswordNeverExpires $True 

# Section 4:  Indication 

write-host
write-host

if ($lastexitcode -eq 1)
{
	write-host "The command Failed :-(" -ForegroundColor red
}
else
{
write-host -------------------------------------------------------------
write-host -ForegroundColor Yellow	"The command complete successfully !" 
write-host
write-host -ForegroundColor Yellow	"The password for all Office 365 users was set to NEVER expired " 
write-host -------------------------------------------------------------
}





# Section 3: PowerShell Command

Get-MsolUser | Set-MsolUser –PasswordNeverExpires $False



#———— End of Indication ———————

# Section 4: Display Information
write-host
write-host
write-host ------------------------------------------------------
write-host List of all users and their Password settings -ForegroundColor white
write-host -------------------------------------------------------

Get-MsolUser | Select UserPrincipalName, PasswordNeverExpires | Out-String
write-host
write-host
write-host -------------------------------------------------------





#Section 5: End the Command
write-host
write-host
Read-Host "Press Enter to continue..."
write-host
write-host

}





11{

####################################################################################################
# Export information: MEGA EXPORT: Exchange online + Office 365 objects
######################################################################################################



# Section 1: information 

clear-host

write-host
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                         
write-host  -ForegroundColor white		Information                                                                                          
write-host  -ForegroundColor white		----------------------------------------------------------------------------                                                             
write-host  -ForegroundColor white  	'This option will: '
write-host  -ForegroundColor white  	'Export information: MEGA EXPORT: Exchange online + Office 365 objects  '
write-host  -ForegroundColor white		---------------------------------------------------------------------------- 
write-host  -ForegroundColor white  	'The export command will create a folder named: INFO in c:\ drive '
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                          
write-host





#----------------------------------------------------------
# AD Azure Online objects
#----------------------------------------------------------

#----------------------------------------------------------
# Office_365_objects


$B =    "C:\INFO\1.Office 365 info"
$B1A =  "C:\INFO\1.Office 365 info\Reports"




if (!(Test-Path -path $B1A ))
{
New-Item $B1A -type directory
}


#----------------------------------------------------------

#___________________________________________________
# 2.Office 365 info\2.1 All object
#___________________________________________________

#----------------------------------------------------------
#@@@@@@@@@@ Get-MsolUser @@@@@@@@@

###TXT####
Get-MsolUser -all | Select UserPrincipalName, PasswordNeverExpires  >$B1\"Msoluser Password settings.txt"
##########

###CSV####
Get-MsolUser -all | Select UserPrincipalName, PasswordNeverExpires  |  Export-CSV $B1A\"Msoluser Password settings.CSV"
##########


###HTML####
Get-MsolUser -all | Select UserPrincipalName, PasswordNeverExpires  | ConvertTo-Html -head $htstyle -Body "<H1>Office 365 users - Password settings</H1>"   | Out-File $B1A\"Msoluser Password settings.html"
##########

#----------------------------------------------------------






}




		
						
				 
				#+++++++++++++++++++
				# Step -05 Finish  
				##++++++++++++++++++
				 
				 
				12{

				##########################################
				# Disconnect PowerShell session  
				##########################################


				write-host -ForegroundColor Yellow Choosing this option will Disconnect the current PowerShell session 

				Function Disconnect-ExchangeOnline {Get-PSSession | Where-Object {$_.ConfigurationName -eq "Microsoft.Exchange"} | Remove-PSSession}
				Disconnect-ExchangeOnline -confirm

				write-host
				write-host

				#———— Indication ———————

				if ($lastexitcode -eq 0)
				{
					write-host -------------------------------------------------------------
					write-host "The command complete successfully !" -ForegroundColor Yellow
					write-host "The PowerShell session is disconnected" -ForegroundColor Yellow
					write-host -------------------------------------------------------------
				}
				else

				{
					write-host "The command Failed :-(" -ForegroundColor red
					
				}

				#———— End of Indication ———————


				}




				13{

				##########################################
				# Exit  
				##########################################


				$Loop = $true
				Exit
				}

				}


				}

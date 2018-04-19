$Users = Import-Csv -Path "C:\Userlist-sn.csv"            
foreach ($User in $Users)            
{            
    $Displayname = $User.Firstname + " " + $User.Lastname            
    $UserFirstname = $User.Firstname            
    $UserLastname = $User.Lastname            
    $OU = "$User.OU"            
    $SAM = $User.SAM            
    $UPN = $User.Firstname + "." + $User.Lastname + "@" + $User.Maildomain            
    $EmailAddress = $User.EmailAddress           
    $Password = $User.Password            
    New-ADUser -Name "$Displayname" -DisplayName "$Displayname" -SamAccountName $SAM -UserPrincipalName $UPN -GivenName "$UserFirstname" -Surname "$UserLastname" -EmailAddress "$Emailaddress" -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) -Enabled $true -Path "$OU" -ChangePasswordAtLogon $false            
} 
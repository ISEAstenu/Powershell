#Retrieve list of all members of the specified Distribution Group
Get-DistributionGroupMember DistroGroupName | Select DisplayName | Export-CSV C:\Support\DistGroup.CSV
Get-DistributionGroupMember DistroGroupName | Select DisplayName >C:\Support\DistGroup.TXT

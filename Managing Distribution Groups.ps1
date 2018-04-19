#Create a list of the Members of a Distribution Group

#Retrieve list of all Distribution Groups
Get-DistributionGroup

#Retrieve list of all Groups (Distrobution, Office365, Mail-Enabled Security, Dynamic Distribution Group)
Get-UnifiedGroup

#Retrieve list of all members of the specified Distribution Group
Get-DistributionGroupMember EngineeringNewsGroup | Select DisplayName | Export-CSV C:\Support\DistGroup.CSV
Get-DistributionGroupMember EngineeringNewsGroup | Select DisplayName >C:\Support\DistGroup.TXT


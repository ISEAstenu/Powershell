#Create a list of the Members of a Dynamic Distribution Group

#list all attributes for specified DDG
Get-DynamicDistributionGroup "DistGroupName" | Format-List

$DDG = Get-DynamicDistributionGroup "DistGroupName" 
Get-Recipient -RecipientPreviewFilter $DDG.RecipientFilter| Select DisplayName >C:\Support\DDG_Members.txt
Get-Recipient -RecipientPreviewFilter $DDG.RecipientFilter| Select DisplayName | Export-CSV C:\Support\DDG_Members.CSV
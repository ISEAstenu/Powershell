function Get-GroupMemberReport {
	param ([string]$groupDN, [int]$depth=0)

	$groupName = (dsget group $groupDN -samid)[1].trim().replace("`"","")

	$tabs=""
	for ($i=0; $i -lt $depth; $i++) {$tabs+="`t"}

	$groupOutput=@()
	$userOutput=@()
	$finalOutput=@()
	$finalOutput += "$tabs[$groupName]"

	$tabs+="`t"

	$groupMembers = dsget group $groupDN -members
	if ($groupMembers.length -eq 0) { $finalOutput+= $tabs + "<This group is empty>" }


	foreach ($member in $groupMembers) {
		if ($member.toLower().contains("ou=groups")) {
			$depth++
			$groupOutput += Get-GroupMemberReport $member $depth
			$depth--
		} elseif ($member.toLower().contains("cn=")) {
			$userOutput += $tabs + (dsget user $member -display)[1].trim()
		}
	}
	
	$finalOutput += $userOutput
	$finalOutput += $groupOutput
	$finalOutput += ""
	return $finalOutput
}



write-host "Enter group name to report on: "
$groupName = read-host
$fileName = $groupName.replace(" ","") + ".txt"

write-host "Writing report to $fileName..."

$report = Get-GroupMemberReport $(dsquery group -name $groupName)
set-content $fileName $report
ii $fileName

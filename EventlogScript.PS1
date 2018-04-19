#Collect and Sort event Data
$ThirtyDays = (Get-Date).AddDays(-3)
$Events  = Get-WinEvent -FilterHashTable @{LogName='SYSTEM', 'Application';Level=1,2,3,4;StartTime=$ThirtyDays} -ErrorAction SilentlyContinue 
$GroupedInfo = $Events | Group-Object Level, ID, ProviderName |Sort-Object -Property Count, Level -Descending
$EventCount = $groupedinfo | Select @{N="Level";E={$_.name.split(',')[0]}}, @{N="Event ID";E={$_.name.split(',')[1]}}, @{N="ProviderName";E={$_.name.split(',')[2]}}, Count
$DetailedLog = $Events | Sort-Object LogName | Format-List TimeCreated,LogName,ProviderName,Id,LevelDisplayName,Message -GroupBy ProviderName | Get-Unique 


#Output and combine Eventdata to C:\Temp\Filename.TXT
$date= get-date -f dd-MM-yy
$NewFileName = "$date-EventLogSummary.log"
New-Item -ItemType file $NewFileName -Force
MD C:\Events -ErrorAction SilentlyContinue
cd c:\Events
Out-File EventIDCount.txt -inputobject $EventCount
Out-File Detailedlog.txt -inputobject $DetailedLog
$file1 = Get-Content "EventIDCount.txt"
$file2 = Get-Content "Detailedlog.txt"
Add-Content $NewFileName $file1
Add-Content $NewFileName $file2
remove-item EventIDCount.txt, Detailedlog.txt



Exit

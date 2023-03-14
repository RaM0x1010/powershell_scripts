<#

 .SYNOPSIS
  Checks all type of backups in infrastructure by given incoming data.
 
 .SYNTAX
 
 
 .DESCRIPTION
  Do the checking backups job. Making some report about status of all backups and sends to email to the sysas.

 .Example
   # Show a default display of this month.
   Show-Calendar

 .Example
   # Display a date range.
   Show-Calendar -Start "March, 2010" -End "May, 2010"

 .Example
   # Highlight a range of days.
   Show-Calendar -HighlightDay (1..10 + 22) -HighlightDate "December 25, 2008"
#>


Import-Module -Name .\modules\PSGetInfoVeeamBackupJobs\PSGetInfoVeeamBackupJobs.psm1
Import-Module -Name .\modules\PSGetInfoSQLTasksAndFiles\PSGetInfoSQLTasksAndFiles.psm1

$folder_creds = "C:\Users\r.mirzaliev\Desktop\shared_folders_credentials.json"
$json_gip_data = "C:\Users\r.mirzaliev\Desktop\domovoy_gips_match_location_notation.json"

$creds_array = Get-JSONCredentialsData($folder_creds)
$gips_data = Get-JSONGipData($json_gip_data)

# ########## checklist in txt
# $servers = @("spb-buh-bkp-3","r-bkp")
# $result = @()

# foreach($server in $servers){
#   $result += Get-BackupsLastStatuses($server)
# }


# $result | Out-File -FilePath "C:\temp\statuses_$(Get-Date -Format "dd-MM-yyyy").txt"
# $result | ConvertTo-Html | Out-File -FilePath "C:\temp\statuses_$(Get-Date -Format "dd-MM-yyyy").txt"





# Check Veeam backup statuses

$veeam_servers = @("spb-buh-bkp-3","r-bkp")
$result_veeam_backups = @()

foreach($server in $veeam_servers){
  $result_veeam_backups += Get-BackupsLastStatuses -Server $server
}


# Check files on shared folders
$file_status_backup = Get-FileBackupStatus -JSONGipData $gips_data -FolderCreds $creds_array

#Check hyper-v replication

Out-HTMLCheckList -BackupStatuses @($result_veeam_backups, $file_status_backup)

# $test_one = $result_veeam_backups + $file_status_backup

#$test_one | Where-Object {$_.TaskName -eq "backup"}

$file_status_backup_test = $test_one | Select-Object @{N='Сервер'; E={$_.ServerName}},@{N='Имя задания'; E={$_.TaskName}},@{N='Тип резервной копии'; E={$_.BackupMethod}},@{N='Место хранения'; E={$_.PathToBackup}},@{N='Время создания'; E={$_.TimeStamp}},@{N='Статус'; E={$_.Status}}
$file_status_backup_test | ConvertTo-Html | Out-File C:\temp\7.html

# test

$html = ConvertTo-Html -Body "$result_veeam_backups $file_status_backup"
$html | Out-File C:\temp\2.html

# test
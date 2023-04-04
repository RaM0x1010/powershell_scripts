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
Import-Module -Name .\modules\PSOutputToFile\PSOutputToFile.psm1

$result_veeam_backups = @()
$folder_creds = "C:\Users\r.mirzaliev\Desktop\shared_folders_credentials.json"
$json_gip_data = "C:\Users\r.mirzaliev\Desktop\domovoy_gips_match_location_notation.json"

$creds_array = Get-JSONCredentialsData($folder_creds)
$gips_data = Get-JSONGipData($json_gip_data)

# $creds_array.GetType()
# [PSCustomObject[]]$test1 = $creds_array
# $test1
# Check Veeam backup statuses

$veeam_servers = @("spb-buh-bkp-3","r-bkp-3")

foreach($server in $veeam_servers){
  $result_veeam_backups += Get-BackupsLastStatuses -Server $server
}

# Check files on shared folders

$file_status_backup = Get-FileBackupStatus -JSONGipData $gips_data -FolderCreds $creds_array

#Check hyper-v replication

Out-HTMLCheckList -BackupStatuses @($result_veeam_backups, $file_status_backup)
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


### test creating report

# $Header = @"
# <style>
# TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
# TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
# </style>
# "@

# $result[0] | ConvertTo-Html -Property JobName, VMName, BackupEndTimeLocal, LastStatus -Head $Header | Out-File -FilePath C:\temp\1.html

# Check Veeam backup statuses

$veeam_servers = @("spb-buh-bkp-3","r-bkp")
$result_veeam_backups = @()

foreach($server in $servers){
  $result_veeam_backups += Get-BackupsLastStatuses($veeam_servers)
}

# Check files on shared folders 

$file_status_backup = Get-FileBackupStatus -JSONGipData $gips_data -FolderCreds $creds_array

#Check hyper-v replication

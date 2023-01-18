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
Import-Module -Name ./modules/PSGetInfoVeeamBackupJobs/PSGetInfoVeeamBackupJobs.psm1
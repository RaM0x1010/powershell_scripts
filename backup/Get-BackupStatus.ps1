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
##Import-Module -Name .\modules\PSGetInfoMSSQLTasks\PSGetInfoMSSQLTasks.psm1
#Import-Module -Name .\modules\PSGetInfoPostgreSQLTasks\PSGetInfoPostgreSQLTasks.psm1
# $Servers = @("spb-buh-bkp-3","r-bkp")
# foreach($server in $Servers){
#   Get-BackupsLastStatuses -Server $server >> c:\temp\statuses.txt
# }

function Get-BackupsLastStatuses {
  [CmdletBinding()]

  Param(
      [string[]]$Server = "localhost"
  )
  

  $result = @()
  
  try {
      $script_path = ".\backup\Get-BackupsLastStatuses.ps1"
      $result = Invoke-Command -ComputerName $Server -FilePath $script_path
      return $result
  }
  catch {
      return $("Error")
  }  
}


$servers = @("spb-buh-bkp-3","r-bkp")
                
    $result += [PSCustomObject]@{
                    shop = $op.name;
                  server = "-";
                    name = "-";
                    path = "-";
                  status = "-";
                message = "-";
            }

    # foreach($srv in $servers){
    #     $statuses = checkVeeamBackups -Server $srv
    #     $statuses.Length
    # }

    foreach($srv in $servers){
        $statuses = checkVeeamBackups -Server $srv                    
        if($statuses.Length){                        
        for ($i = 0; $i -lt $statuses[1].Count; $i++) {
            
            $result += [PSCustomObject]@{
                        shop = $srv;
                      server = $statuses[1][$i].OrigJobName;
                        name = $statuses[1][$i].JobType;                                   
                        path = $("DR Site");#"$($statuses[1][$i].GetJob().TargetDir.ToString())";
                      status = $statuses[1][$i].Result;
                    message = $statuses[1][$i].EndTimeUTC;
                }
        }
        for ($i = 0; $i -lt $statuses[0].Count; $i++){
            if($statuses[0][$i].Name -eq "r-fs-1"){
                $result += [PSCustomObject]@{
                        shop = $srv;
                      server = $statuses[0][$i].Name;
                        name = $statuses[0][$i].JobType;
                        path = [string]$statuses[0][$i].TargetDir;
                      status = $("ok");#$statuses[0][$i].GetLastResult();
                    message = $("none");#$statuses[0][$i].GetLastBackup().LastPointCreationTime.ToString(); #"test";
              }
            }
        }
    }else{$("Current length is " + $statuses.Length)}
}
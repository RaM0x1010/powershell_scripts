##
##
##


function Get-BackupsLastStatuses {
    [CmdletBinding()]

    Param(
        [string]$Server = "localhost"
    )

    try{
        Invoke-Command -ComputerName $Server -ScriptBlock{

            Add-PSSnapin -Name VeeamPSSnapin

            if(!(Get-VBRServerSession)){
                Connect-VBRServer #$Server
            }

            $all_jobs = Get-VBRJob | Where-Object {($_.IsScheduleEnabled -eq $true) -and ($_.ScheduleOptions.NextRun -ne "")}
            $all_sessions = Get-VBRBackupSession
            $last_status_backup_copy_job = @()
            $last_status_vms_in_backup_jobs = @()


            #Get all statuses of backup jobs and backup copy jobs

            foreach($backup_job in $all_jobs){
                Switch ($backup_job.JobType){
                    "Backup"{
                        #$last_status_vms_in_backup_jobs += Get-AllObjectInTaskSession -Session $($all_sessions | Where-Object {$backup_job.Id -eq $_.JobId} | Sort-Object -Property EndTimeUTC -Descending | Select-Object -First 1).OriginalSessionId
                        $task_session_info = Get-VBRTaskSession -Session $($all_sessions | Where-Object {$backup_job.Id -eq $_.JobId} | Sort-Object -Property EndTimeUTC -Descending | Select-Object -First 1).OriginalSessionId
                        #$last_status_vms_in_backup_jobs += 
                        foreach($task_session in $task_session_info){
                            $last_status_vms_in_backup_jobs += [PSCustomObject]@{
                                JobName = $task_session.JobName;
                                VMName = $task_session.Name;
                                BackupEndTimeLocal = $task_session.Info.Progress.StopTimeLocal;
                                LastStatus = $task_session.Status;
                            }
                        }

                    }
                    "BackupSync"{
                        if($backup_job.GetLastResult() -ne "None"){
                            $last_status_backup_copy_job = $last_status_backup_copy_job + ($all_sessions | Where-Object {$backup_job.Id -eq $_.JobId} | Sort-Object -Property EndTimeUTC -Descending)[0]
                        }else{
                            $last_status_backup_copy_job = $last_status_backup_copy_job + ($all_sessions | Where-Object {$backup_job.Id -eq $_.JobId} | Sort-Object -Property EndTimeUTC -Descending)[1]
                        }
                    }
                }    
            }

            return @($last_status_vms_in_backup_jobs, $last_status_backup_copy_job)
        }
    }
    catch{
        return $("Error")
    } 

}


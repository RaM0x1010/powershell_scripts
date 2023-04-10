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
                Connect-VBRServer
            }

            $all_jobs = Get-VBRJob | Where-Object {($_.IsScheduleEnabled -eq $true) -and ($_.ScheduleOptions.NextRun -ne "")}
            $all_sessions = Get-VBRBackupSession
            $last_status_backup = @()
            foreach($backup_job in $all_jobs){
                Switch ($backup_job.JobType){
                    "Backup"{
                        $task_session_info = Get-VBRTaskSession -Session $($all_sessions | Where-Object {$backup_job.Id -eq $_.JobId} | Sort-Object -Property EndTimeUTC -Descending | Select-Object -First 1).Id
                        foreach($task_session in $task_session_info){
                            
                            ## change to backup_job.JobName
                            $job = Get-VBRJob -Name $task_session.JobName
                            ## change to backup_job.JobName

                            $repo_name = Get-VBRBackupRepository | Where-Object {$_.Id -eq $job.Info.TargetRepositoryId} | Select-Object Name
                            $last_status_backup += [PSCustomObject]@{
                                ServerName   = $task_session.Name;
                                TaskName     = $task_session.JobName;
                                BackupMethod = "Veeam BackupJob";
                                PathToBackup = $repo_name.Name;
                                TimeStamp    = $task_session.Info.Progress.StopTimeLocal;
                                Status       = [String]$task_session.Status;
                            }
                        }

                    }
                    "BackupSync"{
                        if($backup_job.GetLastResult() -ne "None"){
                            $last_status_backup_copy_job = ($all_sessions | Where-Object {$backup_job.Id -eq $_.JobId} | Sort-Object -Property EndTimeUTC -Descending)[0]
                            $repo_backup_copy_job = Get-VBRBackupRepository | Where-Object {$_.Id -eq $backup_job.Info.TargetRepositoryId} | Select-Object Name
                            $last_status_backup += [PSCustomObject]@{
                                ServerName   = $last_status_backup_copy_job.JobName;
                                TaskName     = $last_status_backup_copy_job.JobName;
                                BackupMethod = "Veeam Backup Copy Job";
                                PathToBackup = $repo_backup_copy_job.Name;
                                TimeStamp    = $last_status_backup_copy_job.Info.Progress.StopTimeLocal;
                                Status       = [String]$last_status_backup_copy_job.Result;
                            }
                        }else{
                            $last_status_backup_copy_job = ($all_sessions | Where-Object {$backup_job.Id -eq $_.JobId} | Sort-Object -Property EndTimeUTC -Descending)[1]
                            $repo_backup_copy_job = Get-VBRBackupRepository | Where-Object {$_.Id -eq $backup_job.Info.TargetRepositoryId} | Select-Object Name
                            $last_status_backup += [PSCustomObject]@{
                                ServerName   = $last_status_backup_copy_job.JobName;
                                TaskName     = $last_status_backup_copy_job.JobName;
                                BackupMethod = "Veeam Backup Copy Job";
                                PathToBackup = $repo_backup_copy_job.Name;
                                TimeStamp    = $last_status_backup_copy_job.Info.Progress.StopTimeLocal;
                                Status       = [String]$last_status_backup_copy_job.Result;
                            }
                        }
                    }
                }    
            }
            #$result = $last_status_backup + $last_status_backup
            #return @($last_status_backup, $last_status_backup_copy_job)
            #return $result
            return $last_status_backup
        } | Select-Object ServerName, TaskName, BackupMethod, PathToBackup, TimeStamp, Status
    }
    catch{
        return $("Error")
    } 

}


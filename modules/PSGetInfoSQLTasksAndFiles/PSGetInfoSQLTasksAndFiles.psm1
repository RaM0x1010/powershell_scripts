#
#
#

<#
.SYNOPSIS
Mapping shared folders and check mssql tasks

.DESCRIPTION
Long description

.EXAMPLE
An example

.NOTES
General notes
#>

function Get-ObjectPropertyName {
    [CmdletBinding()]

    Param(
        [Object]$object_property
    )
    
    return ($object_property | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name)
}

function Get-JSONCredentialsData {
    [CmdletBinding()]

    param (
        [string]$PathToFile
    )

    $credential_json_data = Get-Content $PathToFile -Raw | ConvertFrom-Json
    $result = @()
        
    foreach($credentail in $credential_json_data.credentials){
        
        $username_string = $credentail.username
        $secure_string = ConvertTo-SecureString -String $credentail.password -AsPlainText -Force

        $result += [PSCustomObject]@{
            Index = $credentail.index
            Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username_string, $secure_string
        }
    }

    return $result
    
}


function Get-JSONGipData {
    [CmdletBinding()]

    param (
        [string]$PathToFile
    )
    
    
    $json_data = Get-Content $PathToFile -Raw | ConvertFrom-Json
    $gips_object = Get-ObjectPropertyName($json_data)
    $result = @()    

    foreach($object_name in $gips_object){
        foreach($gip in $json_data.$object_name){
            foreach($op_obj in $gip.(Get-ObjectPropertyName($gip))){
                foreach($item in $op_obj){
                    $result += [PSCustomObject]@{
                        LocationPrefix = $op_obj.prefix
                        GIPName        = $op_obj.name
                        ServerName     = $item.backup_info.server
                        ServiceName    = $item.backup_info.name
                        Method         = $item.backup_info.method
                        PathToBackup   = $item.backup_info.path
                        CredsIndex     = $item.backup_info.credentials                        
                    }                
                }
            }
        }
    }

    return $result

}

function Get-FileBackupStatus {
    [CmdletBinding()]

    param (        
        [System.Object[]]$JSONGipData,
        [PSCredential[]]$FolderCreds
    )
    
    $result = @()
    $regex = "(shop|wms)"

    try {
        foreach($gip in $JSONGipData){
            if(-not (Test-Path -Path $($gip.LocationPrefix + ":"))){          
              $shared_folder = New-PSDrive -Name $gip.LocationPrefix -PSProvider FileSystem -Root $gip.PathToBackup -Credential $creds_array[$gip.CredsIndex].Credential
              $newest_file_in_folder = Get-ChildItem -File -LiteralPath $($shared_folder.Name + ":") | Where-Object {$_.Name -match $regex} | Sort-Object -Property CreationTime -Descending | Select-Object Name, CreationTime -First 1              
              $result_object = [PSCustomObject]@{
                ServerName   = $gip.ServerName;
                TaskName     = "backup";
                BackupMethod = $gip.Method;
                PathToBackup = $gip.PathToBackup;
                #TimeStamp    = '{0:dd.MM.yyyy}' -f $newest_file_in_folder.CreationTime;
                TimeStamp    = $newest_file_in_folder.CreationTime;
                Status       = "";
              }
              if($newest_file_in_folder.CreationTime -ge (Get-Date).AddHours(-24)){            
                $result_object.Status = "Success"
              }else{
                $result_object.Status = "Error"
              }
              $result += $result_object
            }else{
                $newest_file_in_folder = Get-ChildItem -File -LiteralPath $($gip.LocationPrefix + ":") | Where-Object {$_.Name -match $regex} | Sort-Object -Property CreationTime -Descending | Select-Object Name, CreationTime -First 1              
                $result_object = [PSCustomObject]@{
                    ServerName   = $gip.ServerName;
                    TaskName     = "backup";
                    BackupMethod = $gip.Method;
                    PathToBackup = $gip.PathToBackup;
                    #TimeStamp    = '{0:dd.MM.yyyy}' -f $newest_file_in_folder.CreationTime;
                    TimeStamp    = $newest_file_in_folder.CreationTime;
                    Status       = "";
                }
                if($newest_file_in_folder.CreationTime -ge (Get-Date).AddSeconds(-86399)){            
                    $result_object.Status = "Success"
                }else{
                    $result_object.Status = "Error"
                }
                $result += $result_object
            }
        }
        return $result
    }
    catch {
        $result += [PSCustomObject]@{
            Error = "Error"
            Message = $_
        }
        return $result
    }
}



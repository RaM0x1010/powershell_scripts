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

# Map disk to the system and unmap disk from the system by flag


# Get object property name 

function Get-ObjectPropertyName {
    [CmdletBinding()]

    Param(
        [Object]$object_property
    )
    
    return ($object_property | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name)
}


# some explanetion

function Get-JSONCredentialsData {
    [CmdletBinding()]

    param (
        [string]$PathToFile
    )

    #$PathToFile = "C:\Users\r.mirzaliev\Desktop\shared_folders_credentials.json"
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
                        ServerName     = $item.server
                        ServiceName    = $item.backup_info.name
                        Method         = $item.method
                        PathToBackup   = $item.backup_info.path
                        CredsIndex     = $item.credentials                        
                    }                
                }
            }
        }
    }

    return $result

}

# Get rec

function Connect-SharedFolder {
    [CmdletBinding()]

    param (
        [char]$DriveLetter = 'L',
        [string]$PathToSharedFolder,
        [securestring]$Credentials
    )


    New-PSDrive -Name $DriveLetter -PSProvider "FileSystem" -Root $PathToSharedFolder -Credential $Credentials -Persist

}



function Disconnect-SharedFolder {
    [CmdletBinding()]

    param (
        [string]$PathToSharedFolder
    )

    ## split $PathToSharedFolder and get server name then replace with match in expression
    $ex_shared_folder = $PathToSharedFolder.Split("\")[2]

    Get-PSDrive | Where-Object {$_.DisplayRoot -match $ex_shared_folder} | Remove-PSDrive
    Get-SmbMapping | Where-Object {$_.RemotePath -match $ex_shared_folder} | Remove-SmbMapping -Force

}

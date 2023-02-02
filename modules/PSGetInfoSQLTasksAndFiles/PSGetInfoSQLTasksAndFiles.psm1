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

function FunctionName_1 {
    param (
        [string]$ConnectStateFlag = $true
    )
    
    $credentials
    $path_to_shared_folder

    if ($ConnectStateFlag){
        New-PSDrive -Name S -PSProvider FileSystem -Root $path_to_shared_folder -Credential $credentials -Persist
    }elseif (-not $ConnectStateFlag) {
        Get-PSDrive S | Remove-PSDrive
        
    }

}
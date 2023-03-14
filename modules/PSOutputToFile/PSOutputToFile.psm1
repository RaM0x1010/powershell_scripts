


function Out-HTMLCheckList {
    [CmdletBinding()]

    param (
        [System.Object[]]$BackupStatuses
    )
    
    $css_report_page = ""

    ### test creating report

    # $Header = @"
    # <style>
    # TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
    # TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
    # </style>
    # "@

    # $result[0] | ConvertTo-Html -Property JobName, VMName, BackupEndTimeLocal, LastStatus -Head $Header | Out-File -FilePath C:\temp\1.html
    $result_output = @()
    foreach($status in $BackupStatuses){
        
        
        foreach($item in $status){

        }
    }




}


function Out-ExcelCheckList {
    [CmdletBinding()]

    param (
        [string]$excel
    )
    
}

# $manifest = @{
#     Path              = '.\PSOutputToFile\PSOutputToFile.psd1'
#     RootModule        = 'PSOutputToFile.psm1'
#     Author            = 'Mirzaliev Ruslan'
# }

# new-ModuleManifest @manifest



function Out-HTMLCheckList {
    [CmdletBinding()]

    param (
        [System.Array]$BackupStatuses,
        [string]$ReportLocation,
        [bool]$SendEMail = $false
    )

    #### Mail sending configurations ####

    $From = "spb-buh-asr-1@startonline.ru"
    $To = "r.mirzaliev@startonline.ru"
    $Subject = "Ежедневный чек-лист по статусам резервных копий"
    $SMTPServer = "172.16.0.40"
    $SMTPPort = "25"
    $encoding = [System.Text.Encoding]::UTF8

    $Header = @"
    <style>
        html,body {
            width:210mm;
        }
        table, th, td {
        border: 1px solid black;
        border-collapse: collapse;
        text-align: center;
        }
        td{
            padding: 0.5em;
            font-size: 0.6em;
        }

        .date_time {
            float:left;            
        }

        .person {
            float:right;
        }

        .person p {
            display:inline-block;
        }

        p.data_time {
            float:left;
        }

        div.sig_block {
            float:right;
        }

        p.signature_field {
            display:inline-block;
        }

        select.fio {
            border:0px;
        }
    </style>
"@

$date_and_sign = @"
    <p class="date_time">Дата: $(Get-Date -Format d)</p><div class="sig_block">
    <p class="signature_field">_______________ </p>
    <select name="fio" class="fio">
    <option value="bardin">Бардин И.А.</option>
    <option value="mirzaliev">Мирзалиев Р.А.</option>
    </select>
    </div>
"@

    $backups_report = @()

    foreach($bkp in $BackupStatuses){
        $backups_report += $bkp
    }

    ####
####
####
    ####

    ## Grouping function


    $backups_report = $backups_report | Select-Object @{N='Сервер';E={$_.ServerName}},@{N='Имя задания';E={$_.TaskName}},@{N='Тип резервной копии';E={$_.BackupMethod}},@{N='Место хранения';E={$_.PathToBackup}},@{N='Время создания';E={$_.TimeStamp}},@{N='Статус';E={$_.Status}}
    # $backups_report | ConvertTo-Html -Head $Header -PostContent $date_and_sign | Out-File "C:\temp\backups_report_$($(Get-Date -UFormat "%d-%m-%Y %R").Replace(':','_')).html"
    
    $f_path = $($ReportLocation + "\backups_report_.html")
    $backups_report | ConvertTo-Html -Head $Header -PostContent $date_and_sign | Out-File $f_path

    if ($SendEMail) {
        Send-MailMessage -From $From -to $To -Subject $Subject -SmtpServer $SMTPServer -port $SMTPPort -Encoding $encoding -BodyAsHtml -Attachments $f_path
    }

}

function Out-ExcelCheckList {
    [CmdletBinding()]

    param (
        [string]$excel
    )
    
}

$manifest = @{
    Path              = '.\modules\PSOutputToFile\PSOutputToFile.psd1'
    RootModule        = 'PSOutputToFile.psm1' 
    Author            = 'Mirzaliev Ruslan'
}

New-ModuleManifest @manifest
# Readline options
## Tab completion
Set-PSReadLineKeyHandler -Key Tab -Function Complete
Set-PSReadLineOption -ShowToolTips

# AdvancedHistory
# Enable-AdvancedHistory -Unique
Set-PSReadLineOption -PredictionSource History

# When F7 is pressed, show the local command line history in OCGV
$parameters = @{
    Key              = 'F7'
    BriefDescription = 'Show Matching History'
    LongDescription  = 'Show Matching History using Out-ConsoleGridView'
    ScriptBlock      = {
        ocgv_history -Global $false
    }
}
Set-PSReadLineKeyHandler @parameters

# When Shift-F7 is pressed, show the local command line history in OCGV
$parameters = @{
    Key              = 'Shift-F7'
    BriefDescription = 'Show Matching Global History'
    LongDescription  = 'Show Matching History for all PowerShell instances using Out-ConsoleGridView'
    ScriptBlock      = {
        ocgv_history -Global $true
    }
}
Set-PSReadLineKeyHandler @parameters
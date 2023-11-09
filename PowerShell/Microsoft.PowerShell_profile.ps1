# Parts originally borrowed from:
# https://github.com/HeyItsGilbert/dotfiles/blob/main/.config/Microsoft.Powershell_profile.ps1
# https://gist.github.com/shanselman/25f5550ad186189e0e68916c6d7f44c3?WT.mc_id=-blog-scottha

$global:profile_initialized = $false
$script:PS_ROOT = "~/.config/powershell/"

if ($env:TERM_PROGRAM -eq "VSCODE") {
    # Don't load anything else in VSCode. It slows and breaks stuff.
    Write-Host "Not loading profile in VScode!"
    return
}

# Initialize oh-my-posh as soon as possible, as we'll want to override some things
oh-my-posh init pwsh --config '~/.theme.omp.json' | Invoke-Expression

# Import helper modules
Import-Module AdvancedHistory
Import-Module Posh-Git
Import-Module PSReadLine
Import-Module Terminal-Icons
Import-Module Microsoft.PowerShell.UnixTabCompletion
Import-Module Microsoft.PowerShell.ConsoleGuiTools
Import-Module Microsoft.PowerShell.TextUtility

# Import helper scripts
. ($script:PS_ROOT + "Aliases.ps1")
. ($script:PS_ROOT + "AutoCompleters.ps1")
. ($script:PS_ROOT + "Environment.ps1")
. ($script:PS_ROOT + "PSReadLineHandlers.ps1")
. ($script:PS_ROOT + "Utilities.ps1")
. ($script:PS_ROOT + "WezTerm.ps1")

# $PSDefaultParameterValues['Out-Default:OutVariable'] = '__'

$global:profile_initialized = $true

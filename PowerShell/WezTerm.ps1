# Oh-My-Posh doesn't seem to hook up with WezTerm super well, so this file provides
# way better shell integration.

# # We're ultimately overriding the $prompt function
# $script:OriginalPrompt = Get-Item function:\prompt | ForEach-Object { $_.ScriptBlock }


# # Cache as much as we can:
$u = [System.Environment]::UserName
$m = [System.Environment]::MachineName
$um = "$u@$m"

# ANSI escape sequences
$ANSI_ESC = "`e"
$OSC = "$ANSI_ESC]{0};" # -f $OSCNum
$OSC2 = $OSC -f 2
$OSC133 = $OSC -f 133
# $OSC1337 = $OSC -f 1337

$OSC2_SetWindowTitle = "${OSC2}{0}${ANSI_ESC}\" # -f $windowTitle
$OSC133A_PromptStart = "${OSC133}A`a"
$OSC133B_CommandStart = "${OSC133}B`a"
$OSC133C_CommandExecuted = "${OSC133}C`a"
$OSC133D_CommandFinished = "${OSC133}D;${0}`a" # -f $exitCode


if ($global:shellHooks) {
    $function:prompt = $script:shellHooks.originalPrompt
    $function:PSConsoleHostReadLine = $script:shellHooks.originalPSConsoleHostReadLine
    Remove-Variable -Name "shellHooks" -Scope Global
}

$global:shellHooks = @{
    terminalProgram               = $env:TERM_PROGRAM
    originalPSConsoleHostReadLine = Get-Item function:\PSConsoleHostReadLine | ForEach-Object { $_.ScriptBlock }
    originalPrompt                = Get-Item function:\prompt | ForEach-Object { $_.ScriptBlock }
    lastCommand                   = $null

    getExitCode                   = {
        param ($lastCommandStatus)
        if ($lastCommandStatus -eq $true) {
            return 0
        }

        if ($Error[0]) {
            $lastHistory = Get-History -Count 1
            $isPowerShellError = $Error[0].InvocationInfo.HistoryId -eq $lastHistory.Id
        }

        if ($isPowerShellError) {
            return 1
        }
        else {
            return $LastExitCode
        }
    }
}

function PSConsoleHostReadLine {

    $command = $script:shellHooks.originalPSConsoleHostReadLine.Invoke()
    $script:shellHooks.lastCommand = $command

    $OSC133C_CommandExecuted | Write-Host -NoNewline
    $command
}

function prompt {

    $exitCode = ""
    if ($script:shellHooks.lastCommand) {
        $exitCode = $script:shellHooks.getExitCode.Invoke($?)
    }

    $commandFinished = $OSC133D_CommandFinished -f $exitCode
    $currentLocation = $ExecutionContext.SessionState.Path.CurrentLocation
    $provider_path = $currentLocation.ProviderPath -replace "\\", "/"

    $setWorkingDirectory = "$([char]27)]7;file://${m}/${provider_path}$([char]27)\"

    if ($currentLocation.Path.StartsWith($env:HOME)) {
        $titleLocation = "~" + $currentLocation.Path.Substring($env:HOME.Length)
    }

    $windowTitle = $OSC2_SetWindowTitle -f "${um}: $titleLocation"

    $prompt = $script:shellHooks.originalPrompt.Invoke()

    $commandFinished + $OSC133A_PromptStart + $setWorkingDirectory + $prompt + $windowTitle + $OSC133B_CommandStart
}
# Aliases
# Use function because it's faster to load
function ll { Get-ChildItem -Force $args }
function Get-GitCheckout {
  [alias("gco")]
  param()
  git checkout $args
}
function which { param($bin) Get-Command $bin }

function Source {
  param(
    [string] $extraPath
  )

  $path = "~/Source"

  if (-not [string]::IsNullOrWhiteSpace($extraPath)) {
    $path = Join-Path $path $extraPath
  }

  Set-Location $path
}

function Watch-Command {
  [alias('watch')]
  [CmdletBinding()]
  param (
    [Parameter()]
    [ScriptBLock]
    $Command,
    [Parameter()]
    [int]
    $Delay = 2
  )
  while ($true) {
    Clear-Host
    Write-Host ("Every {1}s: {0} `n" -F $Command.toString(), $Delay)
    $Command.Invoke()
    Start-Sleep -Seconds $Delay
  }
}
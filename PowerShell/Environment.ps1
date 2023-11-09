# Configure .NET
$env:DOTNET_ROOT = "/usr/share/dotnet"
$env:PATH += "${env:PATH}:${env:DOTNET_ROOT}"

# Configure 1Password
$env:SSH_AUTH_SOCK = "~/.1password/agent.sock"

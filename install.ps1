param(
    [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
    [string[]]$Targets
)

# Tino Connector - one-command installer for Windows.
#
#   irm https://aim.tino.vn/install.ps1 | iex
#
# This script installs the connector through each client's official command or
# adds https://aim.tino.vn/mcp to that client's configuration. It does not
# install tino CLI or request a TINO password/token. OAuth happens in the
# browser when the client connects.
$ErrorActionPreference = "Stop"

$McpUrl = "https://aim.tino.vn/mcp"
$MarketplaceRepo = "tinovn/tino-connector"
$PluginSpec = "tino-connect@tino"
$VsixId = "tinovn.aim-connector-vscode"
$McpJson = '{"mcpServers":{"tino-connect":{"type":"http","url":"' + $McpUrl + '"}}}'
$script:HadFailure = $false

function Test-Have($Name) {
    return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Write-Ok($Message) {
    Write-Host "  OK  $Message"
}

function Write-Note($Message) {
    $script:HadFailure = $true
    Write-Host "  !   $Message"
}

function Complete-Install {
    if ($script:HadFailure) {
        throw "One or more requested Tino Connector installs did not complete."
    }
}

function Backup-File($Path) {
    if (Test-Path $Path) {
        Copy-Item $Path ("$Path.bak." + (Get-Date -Format "yyyyMMddHHmmss"))
    }
}

function Install-ClaudeCode {
    Write-Host "== Claude Code"
    if (-not (Test-Have "claude")) {
        Write-Note "Claude Code not found - install it first: https://claude.com/claude-code"
        return
    }

    & claude plugin marketplace add $MarketplaceRepo 2>$null | Out-Null
    & claude plugin install $PluginSpec 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Ok "plugin $PluginSpec installed"
    } else {
        & claude plugin update $PluginSpec 2>$null | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Note "automatic install failed; run: claude plugin install $PluginSpec"
            return
        }
        Write-Ok "plugin already installed and updated"
    }
    Write-Ok "open Claude Code, run /mcp, choose tino-connect and sign in"
}

function Install-VSCode {
    Write-Host "== VS Code"
    if (-not (Test-Have "code")) {
        Write-Note "code command not found - install from the Marketplace:"
        Write-Host "  https://marketplace.visualstudio.com/items?itemName=$VsixId"
        return
    }

    & code --install-extension $VsixId 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Ok "extension $VsixId installed - sign in from the status bar"
    } else {
        Write-Note "code command failed - install $VsixId from the Marketplace"
    }
}

function Install-Cursor {
    Write-Host "== Cursor"
    $path = Join-Path $env:USERPROFILE ".cursor\mcp.json"
    $config = if (Test-Path $path) {
        Get-Content $path -Raw | ConvertFrom-Json
    } else {
        [pscustomobject]@{}
    }

    if (-not $config.PSObject.Properties["mcpServers"]) {
        $config | Add-Member -NotePropertyName "mcpServers" -NotePropertyValue ([pscustomobject]@{})
    }
    $existingServer = $config.mcpServers.PSObject.Properties["tino-connect"]
    if ($existingServer) {
        $currentUrl = [string]$existingServer.Value.url
        if ($currentUrl -ne $McpUrl) {
            Write-Note "MCP server tino-connect already points to $currentUrl - not overwriting it"
            return
        }
        Write-Ok "tino-connect already points to $McpUrl - existing fields preserved"
        return
    }

    $server = [pscustomobject]@{ type = "http"; url = $McpUrl }
    $config.mcpServers | Add-Member -NotePropertyName "tino-connect" -NotePropertyValue $server

    Backup-File $path
    New-Item -ItemType Directory -Force -Path (Split-Path $path) | Out-Null
    $config | ConvertTo-Json -Depth 8 | Set-Content $path -Encoding UTF8
    Write-Ok "tino-connect added to $path - open Cursor and sign in when asked"
}

function Install-Codex {
    Write-Host "== Codex CLI"
    if (-not (Test-Have "codex")) {
        Write-Note "codex command not found - install Codex first"
        return
    }

    & codex plugin marketplace add $MarketplaceRepo 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) {
        & codex plugin marketplace upgrade tino 2>$null | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Note "could not add or update the TINO marketplace"
            return
        }
    }

    & codex plugin add $PluginSpec 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) {
        $installed = (& codex plugin list --json 2>$null | Out-String)
        if ($LASTEXITCODE -ne 0 -or $installed -notmatch '"pluginId"\s*:\s*"tino-connect@tino"') {
            Write-Note "automatic install failed; run: codex plugin add $PluginSpec"
            return
        }
        Write-Ok "plugin already installed and marketplace updated"
    } else {
        Write-Ok "plugin $PluginSpec installed"
    }
    Write-Ok "start a new Codex task and sign in when the browser opens"
}

function Show-Zed {
    Write-Host "== Zed"
    Write-Host "  This repository includes zed/server.json for tino-connect at $McpUrl."
    Write-Host "  Add it to Zed MCP/context server settings and copy zed/.agents/skills/"
    Write-Host "  into the project if the client reads project-local skills."
}

function Ensure-HermesMcpConfig {
    $currentUrl = (& hermes config get mcp_servers.tino-connect.url 2>$null | Out-String).Trim()
    $getExitCode = $LASTEXITCODE
    if ($getExitCode -eq 0) {
        if ($currentUrl -ne $McpUrl) {
            Write-Note "MCP server tino-connect already points to $currentUrl - not overwriting it"
            return $false
        }
    } else {
        & hermes config set mcp_servers.tino-connect.url $McpUrl 2>$null | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Note "could not declare MCP server tino-connect"
            return $false
        }
    }

    & hermes config set mcp_servers.tino-connect.auth oauth 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) { return $false }
    & hermes config set mcp_servers.tino-connect.strict_redirect_headers true 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) { return $false }
    return $true
}

function Install-Hermes {
    Write-Host "== Hermes Agent"
    if (-not (Test-Have "hermes")) {
        Write-Note "hermes command not found - install Hermes Agent first"
        return
    }

    $freshInstall = $false
    & hermes plugins install $MarketplaceRepo --enable 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) {
        $freshInstall = $true
        Write-Ok "plugin tino-connect installed and enabled"
    } else {
        & hermes plugins update tino-connect 2>$null | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Note "automatic install failed; run: hermes plugins install $MarketplaceRepo --enable"
            return
        }
        Write-Ok "plugin and all skills updated"
    }

    if (-not (Ensure-HermesMcpConfig)) {
        Write-Note "plugin installed, but Remote MCP was not configured; OAuth was not started"
        return
    }
    if ($freshInstall) {
        & hermes mcp login tino-connect
        if ($LASTEXITCODE -eq 0) {
            Write-Ok "OAuth complete - restart Hermes Agent to use TINO tools"
        } else {
            Write-Note "plugin installed; finish OAuth with: hermes mcp login tino-connect"
        }
    } else {
        Write-Ok "if sign-in is needed again, run: hermes mcp login tino-connect"
    }
}

function Show-Manual {
    Write-Host "== Manual Remote MCP configuration"
    Write-Host "  JSON block (Claude Code, Cursor, VS Code, Antigravity, and compatible clients):"
    Write-Host "    $McpJson"
    Write-Host "  Codex:"
    Write-Host "    codex plugin marketplace add $MarketplaceRepo"
    Write-Host "    codex plugin add $PluginSpec"
    Write-Host "  Hermes Agent:"
    Write-Host "    hermes plugins install $MarketplaceRepo --enable"
    Write-Host "    hermes mcp login tino-connect"
    Write-Host "  Public source: https://github.com/$MarketplaceRepo"
}

function Invoke-Target($Target) {
    switch ($Target.ToLowerInvariant()) {
        { $_ -in "1", "claude" } { Install-ClaudeCode; break }
        { $_ -in "2", "vscode", "code" } { Install-VSCode; break }
        { $_ -in "3", "cursor" } { Install-Cursor; break }
        { $_ -in "4", "codex" } { Install-Codex; break }
        { $_ -in "5", "zed" } { Show-Zed; break }
        { $_ -in "6", "hermes" } { Install-Hermes; break }
        { $_ -in "7", "m", "manual" } { Show-Manual; break }
        "q" { return }
        default { Write-Note "unknown choice: $Target" }
    }
}

function Get-Mark($Name) {
    if (Test-Have $Name) { return "x" }
    return " "
}

if ($Targets -and $Targets.Count -gt 0) {
    foreach ($target in $Targets) { Invoke-Target $target }
    Complete-Install
    return
}

Write-Host "Tino Connector - connect your AI agent or IDE to TINO over Remote MCP."
Write-Host ""
Write-Host ("  1) Claude Code        [{0}]" -f (Get-Mark "claude"))
Write-Host ("  2) VS Code            [{0}]" -f (Get-Mark "code"))
Write-Host ("  3) Cursor             [{0}]" -f (Get-Mark "cursor"))
Write-Host ("  4) Codex CLI          [{0}]" -f (Get-Mark "codex"))
Write-Host "  5) Zed                [ ]"
Write-Host ("  6) Hermes Agent       [{0}]" -f (Get-Mark "hermes"))
Write-Host "  7) Print Remote MCP config"
Write-Host ""
$choice = Read-Host 'Pick one or more (for example "1 3", a = all detected, q = quit)'
if ($choice -eq "a") {
    $selected = @()
    if (Test-Have "claude") { $selected += "claude" }
    if (Test-Have "code") { $selected += "vscode" }
    if (Test-Have "cursor") { $selected += "cursor" }
    if (Test-Have "codex") { $selected += "codex" }
    if (Test-Have "hermes") { $selected += "hermes" }
    if ($selected.Count -eq 0) {
        Write-Note "no supported client found on PATH"
        Complete-Install
    }
} else {
    $selected = $choice -split "\s+" | Where-Object { $_ }
}
foreach ($target in $selected) { Invoke-Target $target }
Complete-Install

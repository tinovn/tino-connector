$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$OriginalProfile = $env:USERPROFILE
$TestProfile = Join-Path ([IO.Path]::GetTempPath()) ("tino-connector-" + [guid]::NewGuid())
$CursorDir = Join-Path $TestProfile ".cursor"
$ConfigPath = Join-Path $CursorDir "mcp.json"

try {
    New-Item -ItemType Directory -Force -Path $CursorDir | Out-Null
    $env:USERPROFILE = $TestProfile

    $existing = @{
        mcpServers = @{
            "tino-connect" = @{
                type = "http"
                url = "https://aim.tino.vn/mcp"
                headers = @{ "X-Test" = "keep-me" }
            }
            existing = @{ url = "https://example.test/mcp" }
        }
        editor = @{ theme = "dark" }
    }
    $existing | ConvertTo-Json -Depth 8 | Set-Content $ConfigPath -Encoding UTF8

    & (Join-Path $RepoRoot "install.ps1") cursor

    $preserved = Get-Content $ConfigPath -Raw | ConvertFrom-Json
    if ($preserved.mcpServers."tino-connect".headers."X-Test" -ne "keep-me") {
        throw "Cursor tino-connect fields were overwritten"
    }
    if ($preserved.mcpServers.existing.url -ne "https://example.test/mcp") {
        throw "Unrelated Cursor MCP server was overwritten"
    }
    if ($preserved.editor.theme -ne "dark") {
        throw "Unrelated Cursor settings were overwritten"
    }

    $conflict = @{
        mcpServers = @{
            "tino-connect" = @{
                url = "https://staging.example/mcp"
                headers = @{ Authorization = "Bearer fake-test-value" }
            }
        }
    }
    $conflict | ConvertTo-Json -Depth 8 | Set-Content $ConfigPath -Encoding UTF8

    $conflictReported = $false
    try {
        & (Join-Path $RepoRoot "install.ps1") cursor
    }
    catch {
        $conflictReported = $true
    }
    if (-not $conflictReported) {
        throw "A conflicting Cursor URL returned success"
    }

    $refused = Get-Content $ConfigPath -Raw | ConvertFrom-Json
    if ($refused.mcpServers."tino-connect".url -ne "https://staging.example/mcp") {
        throw "Conflicting Cursor URL was overwritten"
    }
    if ($refused.mcpServers."tino-connect".headers.Authorization -ne "Bearer fake-test-value") {
        throw "Conflicting Cursor headers were overwritten"
    }

    function global:code {
        $global:LASTEXITCODE = 1
    }
    $reportedFailure = $false
    try {
        & (Join-Path $RepoRoot "install.ps1") vscode
    }
    catch {
        $reportedFailure = $true
    }
    finally {
        Remove-Item Function:\code
    }
    if (-not $reportedFailure) {
        throw "A failed requested client install returned success"
    }

    Write-Host "install_ps1_test_ok"
}
finally {
    $env:USERPROFILE = $OriginalProfile
    if (Test-Path $TestProfile) {
        Remove-Item -Recurse -Force $TestProfile
    }
}

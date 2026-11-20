$ErrorActionPreference = "Stop"
$project = Join-Path $PSScriptRoot "NexusControlCenter\NexusControlCenter.csproj"

if (-not (Test-Path $project)) {
    Write-Error "Project file not found: $project"
    exit 1
}

if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) {
    Write-Error ".NET SDK not found. Install the .NET 8 SDK, reopen PowerShell, and run this script again."
    exit 1
}

Write-Host "Building NEXUS Control Center..." -ForegroundColor Cyan
dotnet clean $project
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

dotnet build $project -c Release
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Build completed. Output is in NexusControlCenter\bin\Release\net8.0-windows\" -ForegroundColor Green

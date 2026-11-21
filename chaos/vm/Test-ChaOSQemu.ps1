# ChaOS QEMU dependency check for Windows.
# Detection is read-only. Installation is opt-in and delegated to WinGet,
# which verifies the package installer hash against its community manifest.
[CmdletBinding()]
param(
    [switch]$Install,
    [switch]$AllowPreview
)

$ErrorActionPreference = "Stop"
$PackageId = "SoftwareFreedomConservancy.QEMU"

function Find-ChaOSQemu {
    $system = Get-Command "qemu-system-x86_64.exe" -ErrorAction SilentlyContinue
    $image = Get-Command "qemu-img.exe" -ErrorAction SilentlyContinue

    $roots = @(
        "$env:ProgramFiles\qemu",
        "$env:ProgramFiles\QEMU",
        "${env:ProgramFiles(x86)}\qemu",
        "$env:LOCALAPPDATA\Programs\qemu"
    ) | Where-Object { $_ -and (Test-Path -LiteralPath $_) }

    foreach ($root in $roots) {
        if (-not $system) {
            $candidate = Join-Path $root "qemu-system-x86_64.exe"
            if (Test-Path -LiteralPath $candidate) { $system = Get-Item -LiteralPath $candidate }
        }
        if (-not $image) {
            $candidate = Join-Path $root "qemu-img.exe"
            if (Test-Path -LiteralPath $candidate) { $image = Get-Item -LiteralPath $candidate }
        }
    }

    [pscustomobject]@{
        System = if ($system) { $system.Source ?? $system.FullName } else { $null }
        Image  = if ($image) { $image.Source ?? $image.FullName } else { $null }
    }
}

function Get-ChaOSQemuVersion([string]$Path) {
    if (-not $Path) { return $null }
    $output = & $Path --version 2>&1
    if ($LASTEXITCODE -ne 0) { throw "QEMU executable was found but its version check failed: $Path" }
    return (($output | Select-Object -First 1).ToString())
}

$found = Find-ChaOSQemu
if (-not $found.System -or -not $found.Image) {
    if (-not $Install) {
        Write-Host "QEMU is incomplete or not found."
        Write-Host "Re-run with -Install to review and install the exact WinGet package: $PackageId"
        exit 2
    }

    $winget = Get-Command "winget.exe" -ErrorAction SilentlyContinue
    if (-not $winget) {
        throw "WinGet is unavailable. Install or update Microsoft's App Installer, then rerun this script."
    }

    Write-Host "ChaOS will request the QEMU package from the configured WinGet source."
    Write-Host "Package: $PackageId"
    Write-Host "No administrator elevation is requested by this script."
    Write-Host "WinGet will display package details and ask for any required confirmations."
    if (-not $AllowPreview) {
        Write-Host "Preview builds are not requested. Use stable package versions only."
    }

    & $winget.Source install --exact --id $PackageId --source winget
    if ($LASTEXITCODE -ne 0) {
        throw "WinGet installation failed or was cancelled (exit code $LASTEXITCODE)."
    }

    # Refresh PATH in this process for standard machine/user install locations.
    $env:PATH = [Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" +
                [Environment]::GetEnvironmentVariable("PATH", "User")
    $found = Find-ChaOSQemu
}

if (-not $found.System -or -not $found.Image) {
    throw "QEMU installation completed, but both qemu-system-x86_64.exe and qemu-img.exe were not located. No VM files were created."
}

[pscustomobject]@{
    Status = "Ready"
    PackageId = $PackageId
    QemuSystemPath = $found.System
    QemuImagePath = $found.Image
    QemuVersion = Get-ChaOSQemuVersion $found.System
    QemuImageVersion = Get-ChaOSQemuVersion $found.Image
    NextStep = "Dependency detected. VM creation remains a separate explicit operation."
} | Format-List

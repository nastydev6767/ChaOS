$ErrorActionPreference = "Stop"
$vmRoot = Split-Path -Parent $PSScriptRoot
$scripts = Get-ChildItem -LiteralPath $vmRoot -Filter "*.ps1" -File
if (-not $scripts) { throw "No ChaOS VM PowerShell scripts were found." }

foreach ($script in $scripts) {
    $tokens = $null
    $parseErrors = $null
    [void][System.Management.Automation.Language.Parser]::ParseFile(
        $script.FullName, [ref]$tokens, [ref]$parseErrors
    )
    if ($parseErrors.Count -gt 0) {
        $details = ($parseErrors | ForEach-Object { $_.Message }) -join "; "
        throw "PowerShell parse failure in $($script.Name): $details"
    }
    Write-Host "PASS syntax: $($script.Name)"
}

$launch = Get-Content -LiteralPath (Join-Path $vmRoot "Start-ChaOSVm.ps1") -Raw
foreach ($forbidden in @("PhysicalDrive", "Get-Disk", "Clear-Disk", "Initialize-Disk", "Format-Volume", "Set-Disk", "bcdedit", "Restart-Computer")) {
    if ($launch -match [regex]::Escape($forbidden)) {
        throw "Unsafe host-storage/boot operation found in Start-ChaOSVm.ps1: $forbidden"
    }
}
if ($launch -notmatch 'Type BOOT') { throw "VM start must require explicit typed confirmation." }
if ($launch -notmatch 'if=virtio,format=qcow2') { throw "VM must attach the ChaOS QCOW2 virtual disk." }
if ($launch -notmatch 'media=cdrom,readonly=on') { throw "Installer ISO must be attached read-only." }
Write-Host "PASS launch safety invariants"

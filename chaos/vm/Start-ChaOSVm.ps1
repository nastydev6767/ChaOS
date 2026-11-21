# Preview or explicitly start the ChaOS Bazzite installation VM.
# This only uses ChaOS-owned QCOW2 storage; it never attaches host disks.
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$IsoPath,
    [string]$DiskPath = (Join-Path $env:LOCALAPPDATA "ChaOS\VMs\Bazzite\chaos-bazzite.qcow2"),
    [string]$FirmwareCodePath,
    [string]$FirmwareVarsTemplatePath,
    [ValidateRange(4,512)][int]$MemoryGiB = 8,
    [ValidateRange(1,128)][int]$CpuThreads = 4,
    [switch]$Start
)
$ErrorActionPreference = "Stop"
function Find-QemuExecutable {
    $command = Get-Command "qemu-system-x86_64.exe" -ErrorAction SilentlyContinue
    if ($command) { return $command.Source }
    foreach ($root in @("$env:ProgramFiles\qemu", "$env:ProgramFiles\QEMU", "${env:ProgramFiles(x86)}\qemu", "$env:LOCALAPPDATA\Programs\qemu")) {
        $candidate = Join-Path $root "qemu-system-x86_64.exe"
        if (Test-Path -LiteralPath $candidate) { return $candidate }
    }
    return $null
}
if (-not (Test-Path -LiteralPath $IsoPath -PathType Leaf)) { throw "Bazzite ISO not found: $IsoPath" }
if (-not (Test-Path -LiteralPath $DiskPath -PathType Leaf)) { throw "ChaOS VM disk not found: $DiskPath. Create it first with New-ChaOSVmDisk.ps1 -Create." }
$iso = (Resolve-Path -LiteralPath $IsoPath).Path
$disk = (Resolve-Path -LiteralPath $DiskPath).Path
$qemu = Find-QemuExecutable
if (-not $qemu) { throw "qemu-system-x86_64.exe was not found. Run Test-ChaOSQemu.ps1 first." }
$firmwareRoots = @("$env:ProgramFiles\qemu", "$env:ProgramFiles\QEMU", "${env:ProgramFiles(x86)}\qemu", "$env:LOCALAPPDATA\Programs\qemu") | Where-Object { $_ -and (Test-Path -LiteralPath $_) }
if (-not $FirmwareCodePath) {
    foreach ($root in $firmwareRoots) {
        $candidate = Get-ChildItem -LiteralPath $root -File -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Name -match '^(OVMF_CODE.*|edk2-x86_64-code|QEMU_EFI).*\.fd$' } | Select-Object -First 1
        if ($candidate) { $FirmwareCodePath = $candidate.FullName; break }
    }
}
if (-not $FirmwareVarsTemplatePath) {
    foreach ($root in $firmwareRoots) {
        $candidate = Get-ChildItem -LiteralPath $root -File -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Name -match '^(OVMF_VARS.*|edk2-i386-vars|edk2-x86_64-vars|QEMU_VARS).*\.fd$' } | Select-Object -First 1
        if ($candidate) { $FirmwareVarsTemplatePath = $candidate.FullName; break }
    }
}
if (-not $FirmwareCodePath -or -not (Test-Path -LiteralPath $FirmwareCodePath -PathType Leaf)) { throw "UEFI code firmware was not detected. Supply -FirmwareCodePath with your QEMU OVMF CODE .fd file." }
if (-not $FirmwareVarsTemplatePath -or -not (Test-Path -LiteralPath $FirmwareVarsTemplatePath -PathType Leaf)) { throw "UEFI variable template was not detected. Supply -FirmwareVarsTemplatePath with the matching OVMF VARS .fd file." }
$code = (Resolve-Path -LiteralPath $FirmwareCodePath).Path
$varsTemplate = (Resolve-Path -LiteralPath $FirmwareVarsTemplatePath).Path
$vmRoot = Split-Path -Parent $disk
$varsPath = Join-Path $vmRoot "OVMF_VARS.fd"
$logPath = Join-Path $vmRoot "qemu-session.log"
$os = Get-CimInstance Win32_OperatingSystem
$totalGiB = [math]::Floor(([double]$os.TotalVisibleMemorySize * 1KB) / 1GB)
$freeGiB = [math]::Floor(([double]$os.FreePhysicalMemory * 1KB) / 1GB)
$reserveGiB = [math]::Max(4, [math]::Ceiling($totalGiB * 0.25))
$maxGuestGiB = [math]::Min(($totalGiB - $reserveGiB), ($freeGiB - 2))
if ($MemoryGiB -gt $maxGuestGiB) { throw "Requested $MemoryGiB GiB exceeds the current safe guest budget of $maxGuestGiB GiB (Windows reserve + 2 GiB free headroom). Re-run with a lower -MemoryGiB value." }
$logical = [int]((Get-CimInstance Win32_Processor | Measure-Object -Property NumberOfLogicalProcessors -Sum).Sum)
if ($CpuThreads -gt [math]::Max(1, $logical - 2)) { throw "Requested $CpuThreads vCPUs would leave fewer than two logical processors for Windows. Host has $logical." }
Write-Host "ChaOS Bazzite VM launch plan"
[pscustomobject]@{
    Qemu = $qemu; ISO = $iso; VirtualDisk = $disk; VirtualDiskOnly = $true
    UefiCode = $code; UefiVarsTemplate = $varsTemplate
    GuestMemoryGiB = $MemoryGiB; HostMemoryGiB = $totalGiB; HostFreeMemoryGiB = $freeGiB
    GuestCpuThreads = $CpuThreads; HostLogicalProcessors = $logical
    Network = "User-mode NAT (no host bridge configuration)"
    Display = "QEMU standard VGA; virtual graphics only"; SessionLog = $logPath
    StartRequested = [bool]$Start
} | Format-List
if (-not $Start) { Write-Host "Preview only. Re-run with -Start after checking the ISO, disk and firmware paths."; exit 0 }
$approval = Read-Host "Start the ChaOS Bazzite VM now? Type BOOT"
if ($approval -cne "BOOT") { Write-Host "Cancelled. No VM was started."; exit 1 }
if (Test-Path -LiteralPath $varsPath) {
    Write-Host "Using existing ChaOS-owned UEFI variables file: $varsPath"
} else {
    New-Item -ItemType Directory -Path $vmRoot -Force | Out-Null
    Copy-Item -LiteralPath $varsTemplate -Destination $varsPath
}
$qemuArgs = @(
    "-name", "ChaOS-Bazzite", "-machine", "q35,accel=whpx:tcg", "-cpu", "max",
    "-smp", "$CpuThreads", "-m", "${MemoryGiB}G",
    "-drive", "if=pflash,format=raw,readonly=on,file=$code",
    "-drive", "if=pflash,format=raw,file=$varsPath",
    "-drive", "file=$disk,if=virtio,format=qcow2",
    "-drive", "file=$iso,media=cdrom,readonly=on",
    "-boot", "menu=on,order=d",
    "-device", "virtio-net-pci,netdev=net0", "-netdev", "user,id=net0",
    "-vga", "std", "-display", "sdl", "-D", $logPath
)
Write-Host "Starting QEMU. Close the VM window to stop it. QEMU log: $logPath"
& $qemu @qemuArgs
$exitCode = $LASTEXITCODE
if ($exitCode -ne 0) { throw "QEMU exited with code $exitCode. Review $logPath and verify WHPX/UEFI support." }

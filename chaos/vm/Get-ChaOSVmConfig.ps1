# Read-only ChaOS VM configuration preview for Windows.
# Does not create disks, enable Windows features, or start QEMU.
[CmdletBinding()]
param(
    [ValidateRange(1, 512)][int]$MinimumHostReserveGiB = 4,
    [ValidateRange(1, 128)][int]$HostReserveThreads = 2,
    [ValidateRange(1, 4096)][int]$VirtualDiskGiB = 80
)

$ErrorActionPreference = "Stop"

$os = Get-CimInstance Win32_OperatingSystem
$processors = Get-CimInstance Win32_Processor
$logical = [int](($processors | Measure-Object -Property NumberOfLogicalProcessors -Sum).Sum)
$totalGiB = [math]::Floor(([double]$os.TotalVisibleMemorySize * 1KB) / 1GB)
$freeGiB = [math]::Floor(([double]$os.FreePhysicalMemory * 1KB) / 1GB)

$percentageReserve = [math]::Ceiling($totalGiB * 0.25)
$ramReserve = [math]::Max($MinimumHostReserveGiB, $percentageReserve)
$totalBudget = [math]::Max(0, $totalGiB - $ramReserve)

# Keep an additional 2 GiB of currently-free RAM untouched to avoid
# assigning memory Windows is actively using or may need immediately.
$freeBudget = [math]::Max(0, $freeGiB - 2)
$guestRam = [math]::Min($totalBudget, $freeBudget)

# Round down to whole GiB for predictable QEMU arguments.
$guestRam = [math]::Floor($guestRam)
$hostThreads = [math]::Min($HostReserveThreads, [math]::Max(0, $logical - 1))
$guestThreads = [math]::Max(0, $logical - $hostThreads)

$qemu = Get-Command "qemu-system-x86_64.exe" -ErrorAction SilentlyContinue
$qemuImg = Get-Command "qemu-img.exe" -ErrorAction SilentlyContinue

$firmwareCandidates = @()
foreach ($root in @(
    "$env:ProgramFiles\qemu",
    "$env:ProgramFiles\QEMU",
    "${env:ProgramFiles(x86)}\qemu",
    "$env:LOCALAPPDATA\Programs\qemu"
)) {
    if ($root -and (Test-Path -LiteralPath $root)) {
        $firmwareCandidates += Get-ChildItem -LiteralPath $root -Filter "*x64*.fd" -File -Recurse -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -match "CODE|VARS|OVMF" } |
            Select-Object -ExpandProperty FullName
    }
}
$firmwareCandidates = @($firmwareCandidates | Sort-Object -Unique)

[pscustomobject]@{
    HostOS = $os.Caption
    HostRAM_GiB = $totalGiB
    CurrentlyFreeRAM_GiB = $freeGiB
    WindowsSafetyReserve_GiB = $ramReserve
    AdditionalFreeRAMHeadroom_GiB = 2
    RecommendedGuestRAM_GiB = $guestRam
    HostLogicalProcessors = $logical
    ReservedForWindowsThreads = $hostThreads
    RecommendedGuestCPUThreads = $guestThreads
    VirtualDiskMaximumGiB = $VirtualDiskGiB
    DiskFormat = "QCOW2 (sparse; physical usage grows as guest writes data)"
    QEMUFound = [bool]$qemu
    QEMUImageToolFound = [bool]$qemuImg
    UefiFirmwareCandidates = ($firmwareCandidates -join "; ")
    ReadyForNextStage = ([bool]$qemu -and [bool]$qemuImg -and $guestRam -ge 4 -and $guestThreads -ge 1 -and $firmwareCandidates.Count -gt 0)
    Notes = "Preview only. A later explicit create action must re-check free RAM and disk space immediately before creating ChaOS-owned VM files."
} | Format-List

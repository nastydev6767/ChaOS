# ChaOS VM resource planner for Windows
# Read-only: reports a recommended allocation. Does not create disks or change host settings.
[CmdletBinding()]
param(
    [ValidateRange(1, 512)][int]$HostReserveGiB = 4,
    [ValidateRange(1, 128)][int]$HostReserveThreads = 2
)

$ErrorActionPreference = "Stop"

$os = Get-CimInstance Win32_OperatingSystem
$cpu = Get-CimInstance Win32_Processor
$logical = [int](($cpu | Measure-Object -Property NumberOfLogicalProcessors -Sum).Sum)
$totalBytes = [double]$os.TotalVisibleMemorySize * 1KB
$totalGiB = [math]::Floor($totalBytes / 1GB)
$percentReserve = [math]::Ceiling($totalGiB * 0.25)
$ramReserve = [math]::Max($HostReserveGiB, $percentReserve)
$guestRam = [math]::Max(0, $totalGiB - $ramReserve)
$guestCpu = [math]::Max(1, $logical - $HostReserveThreads)

$qemu = Get-Command "qemu-system-x86_64.exe" -ErrorAction SilentlyContinue
$qemuImg = Get-Command "qemu-img.exe" -ErrorAction SilentlyContinue
$whpx = Get-WindowsOptionalFeature -Online -FeatureName HypervisorPlatform -ErrorAction SilentlyContinue

[pscustomobject]@{
    HostOS = $os.Caption
    HostRAM_GiB = $totalGiB
    HostLogicalProcessors = $logical
    ReservedForWindows_GiB = $ramReserve
    RecommendedGuestRAM_GiB = $guestRam
    ReservedForWindows_Threads = [math]::Min($HostReserveThreads, [math]::Max(0, $logical - 1))
    RecommendedGuestCPU_Threads = $guestCpu
    QEMUFound = [bool]$qemu
    QEMUImageToolFound = [bool]$qemuImg
    WHPXFeatureState = if ($whpx) { $whpx.State.ToString() } else { "Unknown (run from elevated PowerShell to inspect optional feature)" }
    Recommendation = if ($guestRam -lt 4) {
        "Host has too little RAM for a comfortable Bazzite VM under the safety policy. Do not force an allocation that starves Windows."
    } elseif (-not $qemu) {
        "Install/locate QEMU before VM creation. No host changes were made."
    } else {
        "Resource plan calculated. VM creation is not implemented by this read-only planner."
    }
} | Format-List

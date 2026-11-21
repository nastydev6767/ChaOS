# Create a disposable sparse QCOW2 disk owned by the ChaOS VM prototype.
# This never attaches a physical disk or modifies partitions.
[CmdletBinding()]
param(
    [ValidateRange(20, 2048)][int]$SizeGiB = 80,
    [switch]$Create
)

$ErrorActionPreference = "Stop"
$vmRoot = Join-Path $env:LOCALAPPDATA "ChaOS\VMs\Bazzite"
$diskPath = Join-Path $vmRoot "chaos-bazzite.qcow2"

$qemuImg = Get-Command "qemu-img.exe" -ErrorAction SilentlyContinue
if (-not $qemuImg) {
    throw "qemu-img.exe was not found. Run Test-ChaOSQemu.ps1 first."
}

if (Test-Path -LiteralPath $diskPath) {
    throw "Refusing to overwrite an existing file: $diskPath"
}

$driveRoot = [System.IO.Path]::GetPathRoot($env:LOCALAPPDATA)
$driveName = $driveRoot.TrimEnd("\").TrimEnd(":")
$drive = Get-PSDrive -Name $driveName -ErrorAction Stop
$minimumFreeBytes = 5GB
if ($drive.Free -lt $minimumFreeBytes) {
    throw "The host drive has less than 5 GiB free. Free space before creating a VM disk."
}

Write-Host "ChaOS VM disk preview"
[pscustomobject]@{
    DiskPath = $diskPath
    VirtualCapacityGiB = $SizeGiB
    Format = "QCOW2 sparse"
    HostDriveFreeGiB = [math]::Round($drive.Free / 1GB, 1)
    ExistingFileWillBeOverwritten = $false
    CreateRequested = [bool]$Create
} | Format-List

if (-not $Create) {
    Write-Host "Preview only. Re-run with -Create to create this ChaOS-owned virtual disk."
    exit 0
}

$approval = Read-Host "Create the new virtual disk at this path? Type CREATE to continue"
if ($approval -cne "CREATE") {
    Write-Host "Cancelled. No files were created."
    exit 1
}

New-Item -ItemType Directory -Path $vmRoot -Force | Out-Null
& $qemuImg.Source create -f qcow2 $diskPath "$($SizeGiB)G"
if ($LASTEXITCODE -ne 0) {
    throw "qemu-img failed to create the virtual disk (exit code $LASTEXITCODE)."
}

if (-not (Test-Path -LiteralPath $diskPath)) {
    throw "qemu-img reported success but the disk file was not found."
}

Write-Host "Created ChaOS-owned sparse virtual disk:"
Get-Item -LiteralPath $diskPath | Select-Object FullName, Length, LastWriteTime | Format-List
Write-Host "The disk is empty. No operating system has been installed and no VM has been started."

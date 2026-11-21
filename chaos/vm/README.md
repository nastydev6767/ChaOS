# ChaOS VM Manager (Windows host)

ChaOS will build its own VM manager on top of **QEMU**, rather than writing a hypervisor. QEMU is the open-source machine emulator/virtualizer; on Windows, the manager will prefer the Windows Hypervisor Platform (WHPX) accelerator when available.

## Why this stack

- **QEMU**: mature, open source, scriptable, supports QCOW2 virtual disks and UEFI firmware.
- **WHPX**: lets QEMU use Windows' hardware-virtualization interface. This avoids pretending that Windows can provide Linux KVM.
- **ChaOS VM Manager**: our own PowerShell-based setup, resource planner, VM profiles, lifecycle controls, and later UI.
- **OVMF/UEFI + virtio**: target virtual firmware and efficient virtual devices, subject to testing with the selected Bazzite image.

We are building the management layer, not a new hypervisor. That gives us a realistic path to a maintainable tool without reimplementing CPU virtualization.

## Resource policy: Aggressive, but not reckless

The manager must inspect the host before assigning resources. It must not blindly give the guest every byte/thread:

- RAM is fixed at VM start in the initial QEMU workflow. Reserve at least 4 GiB for Windows, or 25% of host RAM when that is larger. Never allocate more than the remaining host memory.
- CPU allocation should normally leave at least two logical processors for Windows, while never assigning fewer than one to the guest.
- Use a sparse QCOW2 disk so the virtual disk's maximum capacity does not immediately consume that much physical storage.
- Show the detected hardware, proposed allocation, and disk location before creating anything.
- Allow an explicit override later, but warn when it leaves Windows below the safety reserve.
- Do not claim dedicated GPU performance. QEMU's Windows graphics acceleration is not equivalent to native GPU access; PCI GPU passthrough is a separate, hardware/firmware-dependent project.

Example: on a 16 GiB RAM / 8-thread host, the default policy reserves 4 GiB RAM and 2 threads, so the VM plan is up to 12 GiB RAM and 6 threads. The actual allocation is constrained by free disk space and QEMU/WHPX availability.

## Safety boundaries

- VM files live in a dedicated ChaOS folder and use a disposable virtual disk.
- No host partitioning, EFI/BCD edits, boot-entry changes, driver replacement, or real-disk passthrough.
- The manager must not run elevated unless a future, reviewed feature genuinely requires it.
- VM creation and VM start are separate explicit actions.
- Never attach a host physical disk to the guest in the prototype.

## Current implementation status

The architecture is selected. The Windows VM manager is planned; QEMU/WHPX availability, Bazzite boot, graphics, networking, and performance still need real testing on supported Windows hardware.


## QEMU dependency check

Run the read-only check from a normal PowerShell window:

```powershell
.\chaos\vm\Test-ChaOSQemu.ps1
```

If QEMU is missing or incomplete, the script exits without changing the host. To start the explicit setup flow:

```powershell
.\chaos\vm\Test-ChaOSQemu.ps1 -Install
```

The setup flow:
1. Uses the exact WinGet package ID `SoftwareFreedomConservancy.QEMU` from the configured `winget` source.
2. Displays package metadata before requesting a typed `YES` confirmation.
3. Delegates download/hash validation and installation to WinGet; it does not download or execute a hand-built URL.
4. Checks that both `qemu-system-x86_64.exe` and `qemu-img.exe` are present and can report their versions.

The script does not request elevation, enable Windows features, create VM files, change PATH persistently, or alter boot/disk configuration. Installation may still require permissions depending on the package's installer scope. If WinGet is unavailable, stop and install/update Microsoft's App Installer through the normal Windows settings/store route; do not use an unofficial installer mirror.

**Validation status:** script committed; execution on a Windows host is still pending. WinGet package availability, installation scope, QEMU paths, and WHPX operation must be verified on the target machine before marking the dependency milestone fully complete.


## VM configuration preview

The read-only configuration planner is:

```powershell
.\chaos\vm\Get-ChaOSVmConfig.ps1
```

It uses both total and currently free physical memory. Guest RAM is capped by the larger of the configured minimum Windows reserve (4 GiB by default) or 25% of installed RAM, and it also leaves 2 GiB of currently-free memory untouched. CPU allocation leaves the configured host thread reserve (2 by default) whenever the host has enough logical processors. It also reports candidate OVMF/UEFI firmware files and a proposed sparse QCOW2 capacity (80 GiB maximum by default).

This is a preview only: no disk is created, no Windows feature is enabled, and QEMU is not started. Firmware discovery is best-effort and still needs validation against the installed QEMU package on a real Windows machine.


## Explicit disposable VM disk creation

Preview the proposed virtual disk without writing files:

```powershell
.\chaos\vm\New-ChaOSVmDisk.ps1
```

Create it only after reviewing the preview:

```powershell
.\chaos\vm\New-ChaOSVmDisk.ps1 -Create
```

The script uses a dedicated folder under `%LOCALAPPDATA%\ChaOS\VMs\Bazzite`, defaults to an 80 GiB maximum-capacity sparse QCOW2 disk, refuses to overwrite an existing file, checks for at least 5 GiB of free host-drive space, and requires typing `CREATE`. The QCOW2 file grows as the guest writes data; its virtual capacity is not preallocated. It never attaches a physical disk or changes partitions.

**Current limitation:** this creates only an empty virtual disk. Use the launch workflow below to boot an installer ISO; actual boot/install has not yet been validated on Windows.


## Bazzite ISO boot and VM launch

The first launch path is now implemented as an explicit PowerShell script. It does not download an ISO automatically; obtain a Bazzite desktop ISO from the [official Bazzite download page](https://bazzite.gg/) and follow the [official checksum guidance](https://docs.bazzite.gg/General/Installation_Guide/install-guide/) before use.

1. Check QEMU:
   `.chaos\vm\Test-ChaOSQemu.ps1`
2. Preview host resources and firmware:
   `.chaos\vm\Get-ChaOSVmConfig.ps1`
3. Create the empty disposable virtual disk (after reviewing the path):
   `.chaos\vm\New-ChaOSVmDisk.ps1 -Create`
4. Preview the launch plan (replace the ISO path):
   `.chaos\vm\Start-ChaOSVm.ps1 -IsoPath "C:\\ISO\\bazzite.iso"`
5. Start the VM only after reviewing the plan:
   `.chaos\vm\Start-ChaOSVm.ps1 -IsoPath "C:\\ISO\\bazzite.iso" -Start`

The launch script requires a Bazzite ISO, the ChaOS-owned QCOW2 disk, QEMU, and both UEFI CODE and VARS firmware files. It attempts common OVMF filename discovery; if that does not match the installed QEMU package, pass `-FirmwareCodePath` and `-FirmwareVarsTemplatePath` explicitly. It copies the VARS template into the ChaOS VM directory on first start and never writes to the shared template.

The VM uses WHPX with TCG fallback, UEFI, a virtio virtual disk, user-mode NAT networking, and standard virtual VGA. It never passes through a physical disk or GPU. QEMU runs in the foreground; close its VM window to stop the guest. Session logs are written under the ChaOS VM directory.

**Important:** this is an initial bring-up path, not a validated installer. QEMU option compatibility, UEFI firmware pairing, ISO boot, Bazzite installation, display/input, networking, and shutdown still require execution on a Windows test machine. The VM disk is disposable; install only to the virtual disk shown in the VM, never to a host disk. Do not proceed if the installer shows any host storage.

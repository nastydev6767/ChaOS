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

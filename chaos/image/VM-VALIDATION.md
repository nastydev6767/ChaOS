# ChaOS VM Validation Checklist

Status: **Not yet executed**. This checklist is for a disposable virtual machine only.

## Before testing
- [ ] Use a VM with a disposable virtual disk; do not attach the host's physical SSD.
- [ ] Take a VM snapshot before first boot.
- [ ] Record hypervisor, VM firmware mode, CPU/RAM, virtual GPU, and network adapter.
- [ ] Obtain the image from a trusted ChaOS GHCR package or build it locally from this repository.

## First boot
- [ ] Image boots to a usable desktop.
- [ ] User can log in and reach a terminal.
- [ ] Network works.
- [ ] Display resolution and input work.
- [ ] No unexpected installer or disk changes occur.

## Gaming baseline
- [ ] Confirm Steam availability and launch behavior.
- [ ] Confirm controller/input devices are detected where virtual hardware supports them.
- [ ] Record graphics acceleration limitations of the VM.

## Updates and recovery
- [ ] Confirm the image's documented update mechanism.
- [ ] Test rollback/recovery only using the VM snapshot and supported Bazzite mechanisms.
- [ ] Record failures and logs with secrets and personal identifiers removed.

## Result
Record date, image digest, VM configuration, pass/fail for each section, and issues. Do not mark the roadmap milestone complete until the results are reviewed.

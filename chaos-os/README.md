# ChaOS OS — foundation

This directory is the start of the actual Linux operating system, separate from the legacy NEXUS Windows WPF prototype.

## Base

The image currently derives from the official Bazzite stable image:

`ghcr.io/ublue-os/bazzite:stable`

Bazzite is selected because the project needs a gaming-ready Fedora Atomic base and a KDE Plasma desktop. We should customize it incrementally rather than fork and maintain all of Bazzite.

## What exists now

- `Containerfile`: minimal Bazzite-derived image definition.
- `build_files/`: files owned by ChaOS and copied into the image.
- `.github/workflows/chaos-image.yml`: CI image build check.

## What does not exist yet

- ChaOS-branded desktop shell, theme, wallpaper, or welcome experience.
- Custom settings/control center running on Linux.
- ChaOS gaming and work profiles.
- Shared-storage integration with Windows.
- Installer, partitioning design, or dual-boot integration.
- Signed published image or bootable ISO.

Do not describe these as implemented until they are built and tested.

## Development sequence

1. **Image foundation:** build the minimal image in CI and keep it reproducible.
2. **Desktop identity:** add ChaOS visual assets and safe KDE configuration.
3. **First-boot experience:** create an onboarding flow and hardware/status overview.
4. **Gaming and work modes:** add user-facing profiles that change only documented, reversible settings.
5. **Storage interoperability:** design a dedicated shared data area and read-only-safe handling; never treat the Windows system partition as a shared application store.
6. **VM validation:** test boot, updates, rollback, networking, audio, graphics, input and suspend/resume in virtual machines.
7. **Installer research:** only after the image is stable, design a carefully tested installer and recovery path.

## Build check

The GitHub Actions workflow builds the Containerfile on pushes and pull requests. It is a CI check only: it does not publish a registry image, create an ISO, or install anything on a computer.

For the long-term custom-image workflow, follow the maintained [Universal Blue image-template](https://github.com/ublue-os/image-template) guidance. Image signing and protected publishing must be configured before distributing installable builds.

## Safety boundary

All early testing is VM-only. No script in this directory should edit EFI entries, Windows BCD, partitions, or boot order. Physical dual-boot work requires verified backups, a recovery plan, and careful supervised testing.

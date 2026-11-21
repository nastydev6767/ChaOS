# ChaOS Linux Image Foundation

This directory contains the first minimal image definition for ChaOS.

## Base choice

The initial target is the standard Bazzite desktop image:

`ghcr.io/ublue-os/bazzite:stable`

This is a deliberate starting point for a PC gaming desktop, rather than the Steam Gaming Mode-oriented Deck image. The choice should be validated against the project's target hardware and UX before adding packages or changing defaults.

## Build

The image is built with Buildah using the repository's Containerfile. The GitHub Actions workflow is manual-only initially; it does not publish on every push.

The workflow publishes to GitHub Container Registry (GHCR) under the repository owner namespace. Run it only when ready, and review the workflow permissions and package visibility first.

## Current scope

- Inherits Bazzite without replacing its kernel, drivers, desktop, or gaming stack.
- Adds ChaOS image metadata only.
- Does not install custom drivers.
- Does not configure partitions, boot entries, EFI, or Windows.
- Does not create a bootable installer yet.

## Validation plan

1. Build the image in CI.
2. Pull and boot it in a disposable VM.
3. Verify desktop login, networking, graphics, Steam availability, updates, and rollback behavior.
4. Record VM configuration and test results before marking the image milestone complete.

## Next work

- Decide image signing and update strategy.
- Add only reviewed ChaOS packages and defaults.
- Add a ChaOS desktop shell after choosing its UI toolkit.
- Keep any dual-boot integration in a separate component with independent review and recovery testing.

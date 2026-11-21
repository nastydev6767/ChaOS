# ChaOS

**ChaOS is an operating system project, not a Windows application.**

The target is a polished, gaming-first and productivity-capable desktop OS based on Bazzite (Fedora Atomic / bootc), designed to coexist with an existing Windows installation.

## Repository layout

- `chaos-os/` — the actual Linux image definition and OS-specific files.
- `NEXUS_Starter_Fresh/NEXUS_Starter/` — the earlier NEXUS Windows companion prototype. It is legacy groundwork, not the operating system.

## Current status

The first OS foundation is being developed on the `chaos-os-foundation` branch:

- Bazzite KDE is the upstream base.
- A minimal custom image definition adds ChaOS metadata and a reserved location for OS-owned files.
- GitHub Actions builds the image as a CI check.
- The current workflow does **not** publish an installable image or ISO.

Nothing in this repository currently installs Linux, partitions a disk, edits Windows boot configuration, or changes a computer's boot order.

## Development principles

1. Build on Bazzite instead of maintaining a Linux distribution from scratch.
2. Keep the base system reliable and updateable; prefer supported image customizations.
3. Develop and test in virtual machines before considering physical hardware.
4. Never make destructive disk or boot changes automatically.
5. Clearly distinguish working features from plans and prototypes.

## Project documentation

- [Roadmap](ROADMAP.md) — milestones, status, deliverables, and acceptance criteria.
- [Development workflow](WORKFLOW.md) — branching, pull requests, testing, definition of done, and safety rules.
- [OS foundation notes](chaos-os/README.md) — current image implementation and technical boundaries.

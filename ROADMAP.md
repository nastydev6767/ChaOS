# ChaOS Roadmap

> Source of truth for project direction and progress. Update this file whenever scope, milestones, or implementation status changes.

## Project Summary

ChaOS is a Linux gaming environment based on **Bazzite**, designed to coexist with a user's existing Windows installation. The user can request a transition between Windows and ChaOS; the transition is a reboot into the other operating system, not virtualization or simultaneous operation.

## Core principles

- Preserve the existing Windows installation and user data.
- Use Bazzite/upstream Linux components wherever reliable; avoid unnecessary forks.
- Build ChaOS-specific features as modular components.
- Make OS transitions explicit, predictable, and recoverable.
- Keep shared storage clearly separated from OS system partitions.
- Prefer upstream/native Linux drivers. Develop ChaOS driver work only to close verified compatibility gaps.
- Test in virtual machines and non-destructive environments before real hardware.
- Mark features Planned, In Progress, Implemented, or Blocked only when evidence supports it.

## Target architecture

1. **Windows environment** — user's existing Windows OS and ChaOS transition companion.
2. **ChaOS environment** — Bazzite-based Linux gaming OS with its own interface and services.
3. **OS transition layer** — coordinated request and boot-choice integration; transitions always involve a restart.
4. **Shared storage** — dedicated data area accessible from both OSes; game-library sharing is conditional on launcher/filesystem compatibility.
5. **ChaOS Hardware Intelligence / Driver Lab** — inventory, compatibility records, diagnostics, and native Linux support extensions.
6. **ChaOS UI** — gaming-oriented shell/dashboard, launcher, settings, and status experience.

## Roadmap

### Phase 0 — Project governance and design
- [x] Define ChaOS as a Bazzite-based Linux OS, not a Windows app.
- [x] Establish Windows + ChaOS dual-OS concept and reboot-based switching.
- [x] Define shared storage as a dedicated cross-OS data area.
- [x] Add this roadmap and project vision.
- [x] Add WORKFLOW.md with development, testing, and safety practices.
- [ ] Record architecture decisions (ADRs) when choices have lasting consequences.


### Phase 1 — Bazzite foundation and VM prototype
- [ ] Select a Bazzite variant and document the choice.
- [ ] Establish a reproducible build/configuration approach following Bazzite/Universal Blue conventions.
- [ ] Create a VM test plan and baseline boot/install validation.
- [ ] Identify supported virtual hardware and document limitations.
- [ ] Establish versioning and update/recovery expectations.

### Phase 2 — ChaOS interface
- [ ] Define visual identity and UI design system.
- [ ] Prototype ChaOS launcher/dashboard.
- [ ] Create System, Gaming, Library, Performance, and Settings sections.
- [ ] Add clear status/error reporting and accessible controls.
- [ ] Evaluate whether the existing NEXUS WPF prototype should be retained as a Windows transition companion, replaced, or split into Windows and Linux components.

### Phase 3 — Gaming integration
- [ ] Integrate Steam and supported game launch workflows.
- [ ] Add game/library discovery without claiming unsupported titles are compatible.
- [ ] Provide Proton compatibility information and troubleshooting.
- [ ] Evaluate controller, handheld, and couch-mode usability.
- [ ] Document games or launchers that cannot safely share files between OSes.

### Phase 4 — Shared SSD and data design
- [ ] Define shared-storage partition/filesystem design without touching user disks.
- [ ] Document data categories: common documents/media, downloads, and optional game data.
- [ ] Establish safe mount/access behavior on both OSes.
- [ ] Document Windows Fast Startup/hibernation and dirty-volume risks.
- [ ] Test read/write interoperability in a VM using disposable virtual disks.
- [ ] Create a backup, recovery, and validation checklist.
- [ ] Treat shared game libraries as optional and title/launcher-specific; do not assume universal compatibility.

### Phase 5 — OS transition / switcher
- [ ] Define user-facing switch request and confirmation flow.
- [ ] Define state checks and graceful cancellation/error behavior.
- [ ] Design a separate, auditable boot-selection integration boundary.
- [ ] Define recovery behavior if the target OS is unavailable.
- [ ] Prototype and test only in a VM/disposable environment first.
- [ ] Require explicit confirmation for transitions and never imply an app can safely make arbitrary boot changes.

### Phase 6 — ChaOS Hardware Intelligence / Driver Lab
- [x] Add read-only PCI/USB hardware inventory prototype (initial implementation; validation and expansion remain in progress).
- [ ] Build a driver/firmware compatibility database with source links and tested versions.
- [ ] Report native Linux driver, firmware availability, support status, and known issues.
- [ ] Add diagnostics and compatibility checks before OS transition or setup.
- [ ] Investigate open-source driver code, hardware documentation, and firmware interfaces for gaps.
- [ ] Develop ChaOS-specific native Linux kernel modules only when needed and maintainable.
- [ ] Prefer userspace integrations when kernel-level work is unnecessary.
- [ ] Never treat Windows .sys drivers as directly reusable Linux drivers; APIs and binaries are not generally interchangeable.
- [ ] Validate driver work in isolated environments and document hardware-specific testing.

### Phase 7 — Custom ChaOS image
- [ ] Build a reproducible ChaOS image using the supported Bazzite/Universal Blue image workflow.
- [ ] Add ChaOS branding and curated defaults.
- [ ] Include only components with clear purpose and licensing.
- [ ] Validate update, rollback, recovery, and image integrity behavior.
- [ ] Publish VM testing instructions and known issues.

### Phase 8 — Release readiness
- [ ] Define support scope and minimum requirements.
- [ ] Verify clean installation in a VM.
- [ ] Verify updates and recovery/rollback.
- [ ] Test shared storage on disposable virtual disks.
- [ ] Test OS-switch UX in a simulated environment.
- [ ] Review privacy, telemetry, permissions, licensing, and documentation.
- [ ] Publish release notes and known limitations.

## Current status

The repository still contains the Windows WPF NEXUS starter/prototype and does not yet contain a ChaOS Linux image or working dual-OS switcher. The first Driver Lab component now exists: a read-only Linux sysfs PCI/USB inventory prototype with fixture-based tests. It has not yet been validated on real Bazzite hardware. Linux image, shared-storage setup, boot transition, and gaming integrations remain planned.

## Definition of done

A feature is not Implemented merely because a UI mockup or placeholder exists. It must work, be tested at the appropriate level, and have its limitations documented. Hardware/boot/storage features require test evidence and a recovery plan.

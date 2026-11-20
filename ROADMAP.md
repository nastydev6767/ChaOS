# ChaOS Roadmap

This roadmap describes the intended product and the evidence required to call each milestone complete. Status reflects the repository as inspected when this roadmap was added; update it in the same pull request as meaningful implementation work.

## Product direction

ChaOS is intended to be a polished, gaming-first and productivity-capable desktop operating system based on Bazzite, with KDE Plasma as the initial desktop environment. It should feel like a complete OS, not a terminal-driven project or a Windows application.

The long-term goal is optional coexistence with an existing Windows installation on the same computer, with a clear way to choose either OS at startup and a deliberately designed shared-data experience.

### Product principles

- **Gaming-ready:** build on Bazzite's existing gaming and graphics ecosystem rather than reimplementing it.
- **Useful for work:** support everyday productivity and configurable work profiles without compromising the base OS.
- **Beautiful and coherent:** provide a consistent ChaOS visual identity and an approachable desktop.
- **Easy to use:** common tasks should be available through graphical interfaces; terminal use is not a requirement for normal operation.
- **Reliable:** updates, rollback, recovery, networking, audio, graphics, input, peripherals, and suspend/resume must be tested.
- **Honest compatibility:** Linux needs its own drivers and application compatibility. Windows activation, drivers, and installed applications do not automatically transfer.
- **Safe coexistence:** Windows data access and dual-boot behavior must be explicitly designed and tested; no silent disk or boot changes.

## Status at roadmap creation

| Area | Status | Evidence / limitation |
|---|---|---|
| Repository OS foundation | Implemented | `chaos-os/Containerfile` and image-owned files exist on the foundation branch. |
| Bazzite base selection | Implemented | Containerfile references `ghcr.io/ublue-os/bazzite:stable`; pinning and update policy still need design. |
| Build-only CI | Implemented; verification pending | `.github/workflows/chaos-image.yml` defines a build job. A successful run must be checked before calling it verified. |
| ChaOS desktop identity | Planned | No branded shell, theme, wallpaper, or desktop configuration yet. |
| First-boot experience | Planned | No onboarding or device-status UI yet. |
| Gaming and work profiles | Planned | No ChaOS profile manager yet. |
| Shared Windows data | Planned | No shared-storage design or implementation yet. |
| VM boot and hardware validation | Planned | No documented VM test results yet. |
| Installer and dual-boot integration | Deferred | No installer or boot configuration changes; safety design comes later. |
| Image signing and distribution | Deferred | No signed public image or release pipeline. |

## Milestones

### M0 — Reproducible image foundation
**Status: In progress**

Deliverables:
- Maintain a minimal Bazzite-derived image definition.
- Keep the build reproducible and visible in GitHub Actions.
- Document upstream base, update strategy, image customization approach, and build instructions.
- Avoid unnecessary package additions until their purpose and maintenance cost are clear.

Acceptance criteria:
- CI builds the image successfully on the supported architecture.
- The base image and build process are documented.
- Build failures are visible and actionable.
- No installer, disk modification, or boot-order operation is part of this milestone.

### M1 — ChaOS desktop identity
**Status: Planned**

Deliverables:
- ChaOS wallpaper, icons, colors, typography, and coherent KDE Plasma defaults.
- A clean desktop layout with accessible navigation and sensible defaults.
- Branding that does not imitate Windows or obscure the Linux foundation.

Acceptance criteria:
- The image boots to a usable graphical desktop in a VM.
- Branding is consistent across login, desktop, and core settings surfaces where customization is supported.
- Keyboard navigation, scaling, and accessibility basics are checked.

### M2 — First-boot and system experience
**Status: Planned**

Deliverables:
- Friendly first-run welcome and setup.
- Graphical overview for hardware, network, updates, and system health.
- Clear links to supported settings rather than a custom replacement for every upstream tool.

Acceptance criteria:
- A new VM user can complete onboarding without using a terminal.
- Status is based on real system information and handles unavailable hardware gracefully.
- No privileged or destructive action runs without clear user intent.

### M3 — Gaming experience
**Status: Planned**

Deliverables:
- Clear access to Steam and supported game launchers.
- Game compatibility information and Proton guidance.
- Reversible gaming/performance presets with explanations.
- Controller, audio, display, and GPU validation.

Acceptance criteria:
- A documented set of representative games or test applications runs in the VM or on supported test hardware.
- Profile changes are reversible and do not silently weaken system security.
- Unsupported features are clearly identified.

### M4 — Productivity and workspaces
**Status: Planned**

Deliverables:
- Practical work profiles for common tasks.
- Optional curated productivity applications.
- Per-profile settings that are transparent and reversible.
- A simple way to return to the default desktop experience.

Acceptance criteria:
- Each profile has a documented purpose and dependency list.
- Switching profiles does not remove user data or unexpectedly alter system-wide security settings.
- Basic workflows are tested.

### M5 — Windows data interoperability
**Status: Planned**

Deliverables:
- A documented shared-data model for files that users intentionally want available from both OSes.
- Clear handling of filesystem permissions, encryption, hibernation/Fast Startup, and safe mounting.
- User-facing guidance for choosing shared folders.

Acceptance criteria:
- Test data can be read and written from both OSes in a controlled test setup.
- Windows system files and installed applications are not presented as a shared application environment.
- Unsafe or ambiguous mount states fail safely.
- The design does not rely on accessing a hibernated Windows system volume.

### M6 — VM reliability and compatibility
**Status: Planned**

Deliverables:
- Repeatable VM test matrix for boot, login, updates, rollback, networking, audio, graphics, input, storage, and suspend/resume where supported.
- Documented known issues and minimum VM requirements.
- Regression checks for each release candidate.

Acceptance criteria:
- Test results are recorded with image version and VM configuration.
- Critical boot, update, or data-loss issues block release.
- Recovery and rollback are demonstrated.

### M7 — Installer and dual-boot research
**Status: Deferred — design only after M0–M6**

Deliverables:
- Architecture and threat/risk review for installing alongside Windows.
- A non-destructive discovery and preflight design.
- Backup, recovery, rollback, and user-consent design.
- Test plan using disposable virtual disks and Windows/Linux VMs.

Acceptance criteria:
- No automatic repartitioning or boot changes.
- All destructive actions, if ever supported, are explicit, separately confirmed, and documented.
- Recovery has been tested before any physical-device release is considered.

### M8 — Signed image and release process
**Status: Deferred**

Deliverables:
- Image signing and verification.
- Versioned release notes and known-issues page.
- A controlled update and rollback policy.
- Distribution and support documentation.

Acceptance criteria:
- Users can verify image authenticity.
- Release artifacts are reproducible and traceable to source commits.
- Upgrade and rollback paths are tested before general distribution.

## Immediate next actions

1. Run and inspect the existing image-build GitHub Actions workflow; fix any real build failure.
2. Confirm the supported Bazzite image-customization template and document the chosen approach.
3. Create a repeatable VM boot test plan for the first image.
4. Start M1 only after M0 has a successful build and a documented test baseline.

## Scope guardrails

This roadmap is not a promise that every Linux application or device will work. Compatibility depends on hardware, firmware, drivers, and application support. The first release target should be a defined set of tested hardware and use cases, not an unverified claim of universal compatibility.

Do not implement physical dual-boot installation until the earlier milestones, recovery plan, and supervised test process are complete.

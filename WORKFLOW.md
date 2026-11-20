# ChaOS Development Workflow

This document defines how we plan, implement, test, and review changes. The goal is to keep ChaOS maintainable and prevent unfinished ideas from being mistaken for working OS features.

## 1. Source of truth

- GitHub is the source of truth for code, decisions, issues, and milestone status.
- The `main` branch is the stable integration branch.
- Work happens on short, focused branches created from the latest `main` (or from an explicitly identified active foundation branch while its pull request is open).
- Do not maintain competing copies of the project roadmap in chat messages.

## 2. Before starting work

1. Read `README.md`, `ROADMAP.md`, and this file.
2. Inspect the current implementation and recent commits; do not assume a planned feature exists.
3. Check open issues and pull requests for related work.
4. Define one small outcome and its acceptance criteria.
5. Identify risks, especially anything involving boot, storage, drivers, updates, or user data.

If a task changes architecture or a product promise, record the decision in the relevant documentation before or alongside implementation.

## 3. Branch and pull-request rules

Use descriptive branch names, for example:

- `feat/desktop-branding`
- `feat/first-boot`
- `fix/image-build`
- `docs/roadmap-update`

Keep each pull request focused. A pull request should include:

- What changed and why.
- Which roadmap milestone it supports.
- How it was tested, including exact commands or CI checks where applicable.
- Screenshots or logs for visible UI or runtime changes, when useful.
- Known limitations and follow-up work.
- Any data, security, compatibility, or recovery risks.

Prefer draft pull requests while work is incomplete. Do not merge a failing or unreviewed build just to make the roadmap look complete.

## 4. Implementation and testing order

For OS-level changes, use this order:

1. Validate syntax, formatting, and static checks.
2. Build the image in CI.
3. Boot the image in a disposable virtual machine.
4. Test the specific feature and relevant regressions.
5. Record the tested base image, VM configuration, results, and known issues.
6. Only consider physical-hardware testing after VM testing and a documented recovery plan.

A successful container build is not proof that the image boots or that hardware works.

## 5. Definition of done

A task is **Done** only when:

- Its acceptance criteria are met.
- Relevant automated checks pass.
- Runtime behavior has been tested at the level appropriate to the change.
- Documentation and roadmap status are updated.
- Limitations are stated honestly.
- The change has been reviewed and merged into `main`.

Use these status labels consistently:

- **Planned** — not implemented.
- **In progress** — implementation has started.
- **Implemented** — code exists, but required runtime validation may be incomplete.
- **Verified** — acceptance criteria passed in the documented test environment.
- **Blocked** — progress depends on an unresolved issue or decision.
- **Deferred** — intentionally postponed.

## 6. Safety and reliability rules

- Early development and testing are VM-only.
- No automated script may repartition disks, format filesystems, edit EFI boot entries, modify Windows BCD, or change boot order.
- Never assume the Windows system partition is safe to use as a general shared data partition. Design a dedicated shared-data approach and document filesystem and encryption limitations.
- Do not promise that Windows applications, drivers, activation, or device validation transfer to Linux. Check Linux support independently.
- Prefer reversible user-space configuration and supported Bazzite/Universal Blue customization mechanisms.
- Do not disable security features or weaken update verification as a shortcut.
- Any future installer or dual-boot work requires a threat/risk review, verified backups, recovery media, explicit user consent, and supervised testing.

## 7. Keeping documentation current

When a change affects project status:

- Update `ROADMAP.md` in the same pull request.
- Update the relevant component README.
- Add an Architecture Decision Record under `docs/decisions/` for significant choices (include context, options, decision, and consequences).
- Record validation evidence; do not mark a feature Verified based only on code review.

## 8. Current build workflow

The current GitHub Actions workflow is `.github/workflows/chaos-image.yml`. It performs a build-only CI check for the Bazzite-derived image. It does not publish an image, generate an installer, or install ChaOS on a device.

Treat CI as the first gate, not the final proof of a working operating system.

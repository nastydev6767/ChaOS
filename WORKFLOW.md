# ChaOS Development Workflow

## Source of truth
- VISION.md: purpose and product principles.
- ROADMAP.md: milestones and verified status.
- WORKFLOW.md: how changes are designed, tested, and documented.
- Component READMEs: build, run, and test instructions.
- Committed code and test evidence: what is actually implemented.

## Development loop
1. Select one small ROADMAP milestone.
2. Inspect existing code and documentation.
3. Write acceptance criteria and explicit non-goals.
4. Implement the smallest coherent change.
5. Run automated tests or isolated VM tests.
6. Review safety and recovery for boot, storage, drivers, firmware, and privileged operations.
7. Update documentation and roadmap status to match verified reality.
8. Commit with a descriptive message and record limitations.

## Commit style
Use focused imperative subjects, preferably with a component:
- feat(driver-lab): add read-only hardware inventory
- test(storage): cover shared-volume metadata parsing
- docs(architecture): record image strategy

## Testing levels
- Unit: parsers, models, validation, compatibility matching.
- Integration: Linux sysfs and service interaction using fixtures or isolated environments.
- VM: boot, image updates, UI, shared-storage interoperability on disposable virtual disks, simulated OS transitions.
- Hardware: only after VM validation, with backups and a documented recovery route.

## Safety boundaries
- Early development must not automate partitioning, formatting, bootloader changes, firmware changes, or reboot-to-other-OS actions.
- Treat boot/storage integration as design or simulation until separately reviewed and recovery-tested.
- Do not load Windows kernel drivers into Linux or present binary conversion as a general solution.
- Prefer upstream Linux drivers, documented firmware, and native implementations.
- Hardware inventory is read-only by default. Do not collect device serials or upload reports without consent.

## Status definitions
- Planned: documented, not started.
- In Progress: implementation exists, acceptance criteria incomplete.
- Implemented: acceptance criteria pass and usage/limitations are documented.
- Blocked: an external dependency or decision prevents progress.

## Session handoff
At each work-session end, update ROADMAP.md, relevant component READMEs, and architecture decision records where needed. Record the next concrete task, test results, and known limitations. A contributor should be able to continue from the repository without the full chat transcript.

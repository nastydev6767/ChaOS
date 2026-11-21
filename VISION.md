# ChaOS Vision

## One PC. Two operating systems. One shared data space.

ChaOS aims to turn a PC with Windows and a Linux gaming environment into a cohesive, deliberate dual-OS experience.

Windows remains available for everyday work, school, applications, and software that requires it. ChaOS is a Bazzite-based Linux environment focused on gaming, controller-friendly use, and a clean custom experience. The user chooses an environment, and switching between them means restarting into the selected OS.

## The experience

- **Windows stays Windows:** ChaOS should coexist with the existing Windows setup instead of replacing it.
- **ChaOS is real Linux:** Bazzite is the foundation, not a Windows skin or virtual machine pretending to be an OS.
- **Reboot-based switching:** a clear switch request leads to a restart into the other environment, with safety checks and recovery considerations.
- **Shared SSD/data space:** a deliberately designed shared storage area makes common files available from both OSes. Game files may be shared only where filesystem, launcher, and game compatibility allow it.
- **Gaming-first interface:** ChaOS should provide a custom launcher, game library, system dashboard, performance information, settings, and controller-friendly navigation.
- **Hardware compatibility as a feature:** ChaOS Hardware Intelligence (Driver Lab) inventories hardware and communicates support, missing firmware, known issues, and potential workarounds.
- **Native support over hacks:** prefer upstream Linux drivers and firmware. ChaOS-specific driver development should address real gaps, use documented interfaces, and remain maintainable. Windows drivers are not generally convertible or directly loadable as Linux drivers.
- **Recoverability and trust:** updates, storage operations, and OS-transition features must be transparent, tested, and recoverable.

## What ChaOS is not

- Not a replacement for Windows.
- Not a virtual machine that runs Windows and Linux at the same time.
- Not a wholesale fork of Bazzite.
- Not a collection of custom drivers without a real need.
- Not a tool that silently changes disks, partitions, firmware, or boot configuration.

## Product pillars

1. **Dual-OS coexistence** — preserve both environments.
2. **Seamless transitions** — make choosing and restarting into an OS understandable and reliable.
3. **Shared data** — common storage with honest compatibility boundaries.
4. **Gaming experience** — reduce friction between booting ChaOS and playing.
5. **Hardware confidence** — know what works before relying on the system.
6. **Maintainability** — upstream-first, modular, documented, and reproducible.

## Long-term goal

The long-term goal is a testable, custom ChaOS image based on Bazzite with a distinct interface, gaming integrations, a hardware compatibility system, and a safe, documented dual-OS transition experience. The project should evolve in small milestones and keep its source of truth in the repository rather than relying on chat history.

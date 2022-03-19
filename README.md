### RISC-V chroot environment on Gentoo Linux for qemu-user

If possible, it will create BtrFS subvolume, and disable the CoW.

#### depends on:

* bubblewrap
* qemu-user binary (static linked)
  ```bash
  # can be installed on gentoo linux by:
  echo "app-emulation/qemu static-user QEMU_USER_TARGETS: riscv32 riscv64" >>/etc/portage/package.use/qemu
  emerge -vj app-emulation/qemu --autounmask
  ```

#### init

```bash
./getLast.sh
./createRootFS.sh
```

#### chroot **the daily used*

```bash
./chroot.sh
```

#### clear tmpfs

```bash
./clearMount.sh
```

#### destroy

```bash
./deleteRootFS.sh
```

### RISC-V chroot environment on Gentoo Linux for qemu-user

If possible, it will create a BtrFS subvolume to store the stage3, and disable the CoW.

#### depends on:

* bubblewrap
* qemu-user binary (static linked)
  ```bash
  # can be installed on gentoo linux by:
  echo "app-emulation/qemu static-user QEMU_USER_TARGETS: riscv32 riscv64" >>/etc/portage/package.use/qemu
  emerge -vj app-emulation/qemu --autounmask # may should do somethings others by yourself here
  ```

#### init

```bash
# modify './env' to set to correct values

# Get the latest stage3 tarball
./getLast.sh

./createRootFS.sh
```

#### chroot *(the daily used)*

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

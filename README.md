### RISC-V chroot environment on Gentoo Linux for qemu-user

If possible, it will create BtrFS subvolume, and disable the CoW.

#### depends on:

* bubblewrap

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

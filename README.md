### RISC-V chroot environment on Gentoo Linux for qemu-user

If possible, it will create a BtrFS subvolume as the chroot rootfs, and disable the CoW feature.

#### depends on:

* bubblewrap
* qemu-user binary (static linked)
  ```bash
  # can be installed on gentoo linux by:
  echo "app-emulation/qemu static-user QEMU_USER_TARGETS: riscv32 riscv64" >>/etc/portage/package.use/qemu
  emerge -vj app-emulation/qemu --autounmask # may need to do something more by yourself here
  ```
* [Register binary format handlers](https://wiki.gentoo.org/wiki/Embedded_Handbook/General/Compiling_with_qemu_user_chroot#Register_binary_format_handlers)

#### init

1. modify `./env` to set proper values
2. option: add/delete/modify files under `./conf.d/` to do custom settings (the default number of jobs is: nproc - 2),
   all files under this dir will be pasted to `<chroot-rootfs>/etc/portage/` recursively,
   except `make.conf`, which will be appended to `<chroot-rootfs>/etc/portage/make.conf`.

```bash
# Get the latest stage3 tarball
./getLatest.sh # default to use 'rv64_lp64d-openrc'

./createRootFS.sh [instance-name] [-s <source instance>]
# the instance name should not be started in a '-'
# if no instance-name val provided, the default is 'default' (same below),
# and you can change it under the ./env file.

# if a `-s <name/path>` provided, it will create a new chroot fs from the specified one.
```

#### chroot *(the daily used)*

```bash
./chroot.sh [instance-name] [extra bwrap options]
# you can set an alias to use it at any place
```

#### push dir

```bash
# change to the chroot path (still in the host environment)
./pushDir.sh [instance-name] [-c <path-string>]
# you can set an alias to use it at any place
# it can be executed by a normal user

# if a `-c <path-string>` provided, it will search the PORTAGE_TMPDIR with maxdepth 4,
# and change into the most matched one.
# e.g.: ./pushDir.sh -c libre/work
#       # changed into <chroot-fs>/var/tmp/portage/app-office/libreoffice-7.3.1.3/work/
```

#### handle patches

```bash
# copy/remove patches under <chroot fs>/etc/portage/patches/
./doPatch.sh [instance-name] <patches> [more patches ...] -a <category/pkgname[-verison]> [-d] [-l]
# you can set an alias to use it at any place
# it can be executed by a normal user

# -d: delete specified patches instead of copy
# -l: list patches under the specified path by '-a'
```

#### update portage config
```bash
./updateEnv.sh [instance-name]
# the default behavior will override existed files,
# and you can change it under the ./env file.
# it will be called when `createRootFS.sh` called
```

#### clear tmpfs

```bash
# the purpose of mounting bwrap detached tmpfies is
# to make portage log files, build logs and others
# accessible from the outside.
./clearMount.sh [instance-name]
# it will be called when `deleteRootFS.sh` called
```

#### destroy

```bash
./deleteRootFS.sh [instance-name]
# the whole rootfs dir will be removed after a 5s countdown
```

### TODO

* make it can be runned by normal users

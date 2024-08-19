# Moving to Linux -- James Geddes

Contains my notes on moving to Linux in the long-run.

## Motivation

I have a number of partially overlapping reasons to consider moving to
Linux.

1. To have a consistent working environment across multiple laptops
   and servers.

   My work laptop is MacOS but we often need to work on servers, which
   are typically Linux. (Eg, the server behind the video wall.) I find
   translating from one to the other takes cognitive bandwith.
  
2. To reduce the impedence mismatch between the software I use and the
   system I run it on.
  
   Most of the software I use is written for Linux. While MacOS is a
   Unix-like system, a lot of software needs to be adapted in one way
   or another.
  
### Other reasons for being here

I would like much more of my compute environment to be set up
declaratively (that is, specified in a configuration file). This is,
in part, so that I don't have to remember how the system got to a
particular state, and in part so that I can create identical
environments by copying the configuration file.

There are two new package managers and associated distributions of
Linux that seek to enable completely declarative setup, both of
packages and of the entire system: Nix and Guix. Both of these are
designed for Linux and struggle with the Mac (Guix doesn't work at all
on MacOS, even as a package manager).

My own view is that such things are possibly “the future” and so I
would like to investigate them. As package managers, there are a
number of advantages:

- in principle, the end of “well it works on my machine;”

- users can install software without being root -- possibly addressing
  at least some of IT's security concerns;
  
- the thought that they might be adapted to produce _actually_
  reproducible data science.

In addition, I found packaging software for homebrew more difficult
than expected and so was already looking for an alternative.

I have done a little investigation of Nix as a package manager on
MacOS. It is promising but I found myself increasingly confused by the
conceptual structures. In particular, there seem to be two ways of
doing things: the old way and the new way. Everyone uses the new way
but it is still labelled “experimental” and the documentation mainly
discusses the old way. It seems to me that a _lot_ of the Nix
ecosystem revolves around conventions and idioms that are not fully
explained. (Perhaps this happens because Nix, the language, doesn't
have a proper module system.)

### Plan

One option is to run Guix, the package manager, both on all servers I
need to work on and locally. Guix doesn't work on MacOS, so I will
need to use a VM; which anyway seems like a good transition to
unifying my work environments. So my plan is to test the usability of
a VM-on-the-Mac as a daily work environment.

## Getting a VM running in QEMU on the Mac

```sh
brew install qemu
```

There is no pre-built Guix image for Aarch64, so this process
bootstraps from another Linux distro. I am currently using Armbian
(because it's ARM-specific) from
[https://www.armbian.com/qemu-uboot-arm64/]. You wil need two
(compressed) files: one ends in `.qcow2.xz` (that's the Linux image)
and one ends in `.u-boot.bin` (that's firmware). Previously I had been
running Ubuntu which uses UEFI as its firmware -- the whole thing is
extremely confusing.

Uncompress these files (with `unxz`). Rename them `armbian.qcow2` and
`u-boot.bin`. Then

```sh
qemu-img resize armbian.qcow 128G
```

will make the nominal size of the virtual machine's disk 128
GB. (Nominal because the file is only as large as needed.)

Then run the VM. I am using:

```txt
sudo qemu-system-aarch64 \
    -runas $(whoami) \
    -nographic \
    -cpu host -machine virt \
    -smp 4 -m 6G \
    -accel hvf \
    -nic vmnet-shared \
    -drive if=virtio,index=0,file=armbian.qcow2 \
    -device virtio-rng-pci \
    -bios u-boot.bin
```

Notes:

- If you don't `sudo`, the network "vmnet-shared" will fail. This
  network device is part of Apple's hypervisor framework (and is
  frustrating undocumented in the QEMU docs). There are other network
  devices but I haven't yet figured them out. (The default will let
  the guest VM see the internet, but won't let the Mac host see the
  guest.) I've added `-runas username` to change the userid back to
  non-root after QEMU is started.
  
  To enable fingerprint authentication for sudo, copy
  `/etc/pam.d/sudo_local.template` to `sudo_local` and edit it to
  uncomment the single line.
  
- The line `-bios u-boot.bin` uses the file from Armbian. (Other
  firmware, eg, UEFI, comes pre-built with QEMU.)
  
- The line `-smp 4 -m 12G` sets the number of guest cores to 4 (and
  will use 4 actual cores) and the guest RAM to 12 GB. I originally
  used 8G RAM but building the kernel maxxed out the space on tmpfs
  (which defaults to 50% of RAM on Armbian). 

### Making a Guix distribution image

1. In the VM, run `sudo apt install guix` followed by

   ```sh
   # sudo guix archive --authorize < prefix/share/guix/ci.guix.gnu.org.pub
   # sudo guix archive --authorize < prefix/share/guix/bordeaux.guix.gnu.org.pub
   ```

   where "prefix", in my case, turns out to be "`/usr`".

   Then `guix pull`. This may take a long time if the binary server
   hasn't got up to date binaries and guix decides to recompile.
  
   Then (as prompted):

   ```sh
   GUIX_PROFILE="/home/james/.config/guix/current"
     . "$GUIX_PROFILE/etc/profile"
   ```

2. Perhaps follow instructions here:
   [https://guix.gnu.org/manual/en/html_node/Application-Setup.html]

   ```sh
   guix install glibc-locales
   ```

   (<ight need to logout/in to set up path (which is set in `/etc/profile.d/guix.sh`)


https://github.com/mzadel/guix-on-m1-qemu

qemu-img create -f qcow2 -o size=128G guix.qcow2

Add to armbian.sh:

  -drive if=virtio,index=1,file=guix.qcow2 \


Use cfdisk (as root) to make two partitions on /dev/vbd: 
- the first is type "EFI System", of 1G
- the second is type "Linux filesystem" of the remaining space

Then format these:

mkfs.fat /dev/vdb1
mkfs.ext4 /dev/vdb2

Then mount

mount /dev/vdb2 /mnt/
mkdir /mnt/etc
cp config.scm /mnt/etc
mkdir -p /mnt/boot/efi

mount /dev/vdb1 /mnt/boot/efi/

Then `guix system init --system=aarch64-linux --skip-checks /mnt/etc/config.scm /mnt`. Although, if you
sudo that, guile can't find the packages; and if you run it as you, it
can't finalise the installation. So ... I ran once as non-root and
once as sudo. But I think perhaps the right thing is just to start
from the top as root.

3. Made a `config.scm`. Ran `guix system image --image-type=iso9660
   config.scm`

   That got me an error:

   ```txt
   error: plain image kernel not supported -- rebuild with
   CONFIG_U(EFI)_STUB enabled.
   ```

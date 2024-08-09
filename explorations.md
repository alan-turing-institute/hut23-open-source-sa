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

## Getting a VM running on the Mac

### Running Arch Linux

My goal is to get Guix running. However, Guix don't provide an
installation image for Aarch64. So my new plan is to get _some_
distribution running.

UTM is an app for MacOS which wraps QEMU in a (hopefully)
user-friendly GUI. UTM provide a downloadable ArchLinux installation.

I unzipped the download and moved the resulting to ~/vms. It's a
package with the following structure:

```sh
ArchLinux.utm
├── config.plist
└── Data
   ├── BB208CBD-BFB4-4895-9542-48527C9E5473.qcow2
   └── efi_vars.fd
```

The file ending in ~.qcow2~ is a disk image.

The result is a text-only virtual machine. It presents as having four cores
(which I think map to the four efficiency cores on my Mac), 2 GB of
RAM, and a 10 GB hard drive.

### Running Ubuntu Server

Okay, Arch linux turned out to be too barebones and there was too much
to do to get Guix running.

I think perhaps starting with Ubuntu is a better idea. That's what's
likely to be running on any server I use, anyway.

1. I downloaded an ISO file.
2. Started following the guide here:
   [https://docs.getutm.app/guides/ubuntu/]
   - 8192 MB RAM
   - Default number of cores
   - I ticked "Enable hardware OpenGL acceleration"
   - 64 GB drive
3. GNU Grub started okay, started Ubuntu installation
   - Did NOT "Search for third-party drivers"
   - Turned OFF "Set up this disk as an LVM group"
   - SELECTED "Install OpenSSH server"
4. After "Installation complete!", rebooting failed. Turned off VM,
   unmounted the ISO, and restarted from UTM.
5. When logged in, ran `sudo apt upgrade`, and `sudo apt install spice-vdagent`

Here is the complete QEMU settings:

```sh
qemu-system-aarch64 -L /Applications/UTM.app/Contents/Resources/qemu -S\
					-spice \
					unix=on,addr=77A2E4EE-26C9-4E35-A316-C4E719B4883A.spice,\
					disable-ticketing=on,image-compression=off,playback-compression=off,\
					streaming-video=off,gl=on -chardev spiceport,name=org.qemu.monitor.qmp.0,\
					id=org.qemu.monitor.qmp -mon chardev=org.qemu.monitor.qmp,\
					mode=control\
					-nodefaults -vga none\
					-device virtio-net-pci, mac=C6:92:33:CA:AA:9F, netdev=net0\
					-netdev vmnet-shared,id=net0 -device virtio-gpu-gl-pci\
					-cpu host -smp cpus=4,sockets=1,cores=4,threads=1\
					-machine virt -accel hvf\
					-drive if=pflash,format=raw,unit=0,file=/Applications/UTM.app/Contents/Resources/qemu/edk2-aarch64-code.fd,readonly=on\
					-drive if=pflash,unit=1,file=/Users/james/Library/Containers/com.utmapp.UTM/Data/Documents/Ubuntu.utm/Data/efi_vars.fd\
					-m 8192 -audiodev spice,id=audio0 -device intel-hda\
					-device hda-duplex,audiodev=audio0\
					-device nec-usb-xhci,id=usb-bus\
					-device usb-tablet,bus=usb-bus.0\
					-device usb-mouse,bus=usb-bus.0\
					-device usb-kbd,bus=usb-bus.0\
					-device qemu-xhci,id=usb-controller-0\
					-chardev spicevmc,name=usbredir,id=usbredirchardev0\
					-device usb-redir,chardev=usbredirchardev0,id=usbredirdev0,bus=usb-controller-0.0\
					-chardev spicevmc,name=usbredir,id=usbredirchardev1\
					-device usb-redir,chardev=usbredirchardev1,id=usbredirdev1,bus=usb-controller-0.0\
					-chardev spicevmc,name=usbredir,id=usbredirchardev2\
					-device usb-redir,chardev=usbredirchardev2,id=usbredirdev2,bus=usb-controller-0.0\
					-device usb-storage,drive=drive5DCBC04B-4835-452E-BB8D-042C074E9078,removable=true,bootindex=0,bus=usb-bus.0\
					-drive if=none,media=cdrom,id=drive5DCBC04B-4835-452E-BB8D-042C074E9078,readonly=on\
					-device virtio-blk-pci,drive=drive91B59E58-B100-4654-A7D6-F0412AC1AFB4,bootindex=1\
					-drive if=none,media=disk,id=drive91B59E58-B100-4654-A7D6-F0412AC1AFB4,file=/Users/james/Library/Containers/com.utmapp.UTM/Data/Documents/Ubuntu.utm/Data/91B59E58-B100-4654-A7D6-F0412AC1AFB4.qcow2,discard=unmap,detect-zeroes=unmap\
					-device virtio-serial\
					-device virtserialport,chardev=org.qemu.guest_agent,name=org.qemu.guest_agent.0\
					-chardev spiceport,name=org.qemu.guest_agent.0,id=org.qemu.guest_agent\
					-device virtserialport,chardev=vdagent,name=com.redhat.spice.0\
					-chardev spicevmc,id=vdagent,debug=0,name=vdagent\
					-name Ubuntu -uuid 77A2E4EE-26C9-4E35-A316-C4E719B4883A\
					-device virtio-rng-pci -device virtio-balloon-pci
```

(I also ENABLED "Balloon device")

### Making a Guix distribution image

1. Ran: `sudo apt install guix`, followed by `guix pull`
   - Which took a really long time --- must figure out what that
     does. I think it's rebuilding packages from scratch rather than
     using prebuilt binaries.
   - Oh, needed to authorize "substitute" servers:
  
   ```sh
   # guix archive --authorize < prefix/share/guix/ci.guix.gnu.org.pub
   # guix archive --authorize < prefix/share/guix/bordeaux.guix.gnu.org.pub
   ```

   - also, might need to logout/in to set up path (which is set in `/etc/profile.d/guix.sh`)

2. Followed instructions here:
   [https://guix.gnu.org/manual/en/html_node/Application-Setup.html]

3. Made a `config.scm`. Ran `guix system image --image-type=iso9660
   config.scm`
   
That got me an error:

```
error: plain image kernel not supported -- rebuild with
CONFIG_U(EFI)_STUB enabled.
```


;; -*- mode: scheme; -*-
;; This is an operating system configuration template
;; for a "bare bones" setup, with no X11 display server.

(use-modules (gnu)
	     (gnu packages linux)
	     (gnu system keyboard))
(use-service-modules networking ssh)
(use-package-modules screen ssh)

(operating-system
  (host-name "vosso")
  (timezone "Europe/London")
  (locale "en_GB.utf8")
  (keyboard-layout
   (keyboard-layout "gb" "mac"))

  (bootloader (bootloader-configuration
               (bootloader grub-efi-bootloader)
               (targets '("/boot/efi/"))))


  (kernel
   (customize-linux
    #:configs '("CONFIG_EFI_STUB=y")))
  
  (kernel-arguments (list "console=ttyAMA0,115200" "nomodeset"))

  (file-systems (append
		 (list
		  (file-system
		   (device "/dev/vda2")
		   (mount-point "/")
		   (type "ext4"))
		  (file-system
		   (device "/dev/vda1")
		   (mount-point "/boot/efi")
		   (type "vfat")))
                 %base-file-systems))

  ;; This is where user accounts are specified.  The "root"
  ;; account is implicit, and is initially created with the
  ;; empty password.
  (users (cons (user-account
                (name "james")
                (comment "James")
                (group "users")

                ;; Adding the account to the "wheel" group
                ;; makes it a sudoer.  Adding it to "audio"
                ;; and "video" allows the user to play sound
                ;; and access the webcam.
                (supplementary-groups '("wheel")))
               %base-user-accounts))

  ;; Globally-installed packages.
  (packages (cons screen %base-packages))

  ;; Add services to the baseline: a DHCP client and an SSH
  ;; server.  You may wish to add an NTP service here.
  (services (append (list (service dhcp-client-service-type)
                          (service openssh-service-type
                                   (openssh-configuration
                                    (openssh openssh-sans-x)
                                    (port-number 2222))))
                    %base-services)))

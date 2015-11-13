Ubuntu OS installation script for Chromebooks
============================================

This will install Ubuntu or Kubuntu (with ChrUbuntu) and apply automatically all the necessary fixes to run Ubuntu on Chromebooks. You will be able to boot in ChromeOS or Ubuntu on your Chromebook.

Supported device(s)
-------------------

* Acer C720 (Tested)
* HP Chromebook 14 (Untested, but should work using the Acer C720 device profile)
* Asus Panther Chromebox (Tested)
* Toshiba Chromebook (Untested)

Prerequisites
-------------

* A Chromebook listed in the supported device(s) section
* A recovery image for you Chromebook in case something goes wrong. In order to achieve that, go to [chrome://imageburner](chrome://imageburner), on your Chromebook, and follow the instructions
* Chromebook in developer mode
* An external media of at least 2GB (USB Flash drive or SD Card)
* Patience

Usage
-----

**ATTENTION: This will wipe everything on your device**

**ATTENTION: This is still a pre-release, there could be bugs**

1. Enable [developer mode](http://www.chromium.org/chromium-os/developer-information-for-chrome-os-devices) on your device
2. Download the latest pre-release of this installer and extract it to a removable media
3. Boot into ChromeOS, connect to a wireless network and log in as guest
4. Open a shell (CTRL + ALT + t) and type `shell`
5. From the shell go to the location of the script on the removable media `cd /media/removable/` and press **[TAB] [TAB]** on your keyboard to show and auto-complete your removable media path automatically
6. Run the script with the `list` parameter to list the supported device(s) `sudo bash main.sh list` or the `search` parameter to search in all devices profile(s) `sudo bash main.sh search DEVICE_PROFILE` (ex: sudo bash main.sh search acer)
7. Run the script with the appropriate manifest for your device `sudo bash main.sh DEVICE_PROFILE` (ex: sudo bash main.sh acer-c720)
8. On the first run you will be asked how much storage space you want to dedicate to Ubuntu
9. After the first run, your system will reboot to complete the initial formating, then you will need to re-run the script with the same parameters to complete the installation process
10. Follow the prompt to complete the installation
11. After the installation is completed and the Chromebook has rebooted, press CTRL+L to boot into Ubuntu
12. On first boot you will be asked to complete your system configuration (Language, Time zone, Computer name) and create a user account

On future kernel updates, the script (profiles/devices/acer-c720/scripts/trusty-patch.sh) can be run from the installer folder to update the patches with updated kernels.(to some degree)

Optional
--------
If you want the Search key to function as Caps Lock, look at the keybind config listed here:
https://github.com/eyecreate/ubuntu-chromebook-installer/issues/18

Credit(s)
---------

* The [Ubuntu](http://ubuntu.com/) development team for creating this awesome Linux distribution
* Parimal Satyal for making a [guide](http://realityequation.net/installing-elementary-os-on-an-hp-chromebook-14) on how to install Ubuntu on the HP Chromebook 14
* Jay Lee for creating [ChrUbuntu](http://chromeos-cr48.blogspot.ca/) from which I use a modified version
* SuccessInCircuit on reddit for making a [guide](http://www.reddit.com/r/chrubuntu/comments/1rsxkd/list_of_fixes_for_xubuntu_1310_on_the_acer_c720/) on how to fix mostly everything with the Acer C720
* Benson Leung for his [cros-haswell-modules](https://googledrive.com/host/0B0YvUuHHn3MndlNDbXhPRlB2eFE/cros-haswell-modules.sh) script
* [Quatral Solutions](http://www.quatral.com) for providing the Acer C720 Chromebook
* Jesus Lopez - Thanks for helping testing ChromeeOS for the Asus Chromebox
* Jonathan Frank (Setsuna666) for creating Chromeeos and the Acer C720 profile
* Everyone who contributed
* Kevin Whitaker for c720p patches and Ubuntu specific changes from elementary OS

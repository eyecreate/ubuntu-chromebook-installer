elementary OS install script for Chromebooks
============================================

This script will apply automatically all the necessary fixes to run elementary OS on Chromebooks.


Supported device(s)
-------------------

* Acer C720

Prerequisites
-------------

* A Chromebook which is listed in the supported device(s) section
* A recovery image for you Chromebook in case something goes wrong
* Enabled developer mode and legacy boot with usb support
* Knowledge necessary to boot from an external storage and do the initial installation of elementary OS on a Chromebook
* Patience

### Acer C720
1. Before starting the installation process, you will need to run the following command in a terminal in order for the wireless card to work properly `modprobe sudo modprobe ath9k nohwcrypt=1 blink=1 btcoex_enable=1 enable_diversity=1`
2. Install elementary OS on your Chromebook
3. After the installation process is done and your Chromebook is booted in elementary OS, you will need to run the same command in a shell before running the script

Usage
-----

In order to use this script, you will have to download this file http://URL_TO_SCRIPT/ which will install all the prerequisites to clone this github repository and launch the setup process.

1. From a web browser go to http://URL_TO_SCRIPT/ or in a terminal with the command `wget http://URL_TO_SCRIPT/`
2. Change the permission of the file with the command `chmod +x FILENAME`
3. As a user, run the script with the command `sh -e ~/Downloads/FILENAME`

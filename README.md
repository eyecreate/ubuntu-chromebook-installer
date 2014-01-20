ChromeeOS - elementary OS installation script for Chromebooks
============================================

ChromeeOS will install elementary OS (with ChrUbuntu) and apply automatically all the necessary fixes to run elementary OS on Chromebooks. By default, it will use ChrUbuntu to simplify the installation process, but it can be used without it.


Supported device(s)
-------------------

* Acer C720
* HP Chromebook 14 (Untested, but should work using the acer-c720 manifest)

Prerequisites
-------------

* A Chromebook which is listed in the supported device(s) section
* A recovery image for you Chromebook in case something goes wrong
* Enabled developer mode
* An external media of at least 1GB (USB Flash drive or SD Card)
* Patience

Usage
-----

In order to use this script, you will have to download this file http://URL_TO_SCRIPT/ which will install all the prerequisites to clone this github repository and launch the setup process.

1. From a web browser go to http://URL_TO_SCRIPT/ or in a terminal with the command `wget http://URL_TO_SCRIPT/`
2. Change the permission of the file with the command `chmod +x FILENAME`
3. As a user, run the script with the command `sh -e ~/Downloads/FILENAME`

Credit(s)
---------

* Parimal Satyal for making a [guide](http://realityequation.net/installing-elementary-os-on-an-hp-chromebook-14) on how to install elementary OS on the HP Chromebook 14
* Jay Lee for creating [ChrUbuntu](http://chromeos-cr48.blogspot.ca/) from which I use a modified version
* SuccessInCircuit on reddit for making a [guide](http://www.reddit.com/r/chrubuntu/comments/1rsxkd/list_of_fixes_for_xubuntu_1310_on_the_acer_c720/) on how to fix mostly everything on the Acer C720
* Everyone who contributed

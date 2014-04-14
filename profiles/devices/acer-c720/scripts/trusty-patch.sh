# Create a temp directory for our work
tempbuild=`mktemp -d`
cd $tempbuild

# Determine kernel version (with and without Ubuntu-specific suffix)
#mykern=${1:-$(uname -r)}
#mykern=$(uname -r)
#mykern=$(python linux-ver-latest.py "`apt-cache show linux-image-generic | grep Depends |head -1`")
mykern=3.13.0-23-generic
mykernver=linux-$(echo $mykern | cut -d'-' -f 1)


# Install necessary deps to build a kernel
sudo apt-get build-dep -y --no-install-recommends linux-image-$mykern

# Grab Ubuntu kernel source
apt-get source linux-image-$mykern
cd $mykernver

# Use Benson Leung's post-Pixel Chromebook patches:
# https://patchwork.kernel.org/bundle/bleung/chromeos-laptop-deferring-and-haswell/
for patch in 3078491 3078481; do
  wget -O - https://patchwork.kernel.org/patch/$patch/raw/ | patch -p1
done

#for patch in 8759835 8759842 8759848 8759852 8759855 8759857; do
#  wget -O - http://pastie.org/pastes/$patch/download | patch -p1
#done
wget -O - http://pastie.org/pastes/8878181/download | patch -p0

# Need this
cp /usr/src/linux-headers-$mykern/Module.symvers .

# Prep tree
cp /boot/config-$mykern ./.config
make oldconfig
make prepare
make modules_prepare

# Build only the needed directories
make SUBDIRS=drivers/platform/chrome modules
make SUBDIRS=drivers/i2c/busses modules

# switch to using our new chromeos_laptop.ko module
# preserve old as .orig
sudo mv /lib/modules/$mykern/kernel/drivers/platform/chrome/chromeos_laptop.ko /lib/modules/$mykern/kernel/drivers/platform/chrome/chromeos_laptop.ko.orig
sudo cp drivers/platform/chrome/chromeos_laptop.ko /lib/modules/$mykern/kernel/drivers/platform/chrome/

# switch to using our new designware i2c modules
# preserve old as .orig
sudo mv /lib/modules/$mykern/kernel/drivers/i2c/busses/i2c-designware-core.ko /lib/modules/$mykern/kernel/drivers/i2c/busses/i2c-designware-core.ko.orig
sudo mv /lib/modules/$mykern/kernel/drivers/i2c/busses/i2c-designware-pci.ko /lib/modules/$mykern/kernel/drivers/i2c/busses/i2c-designware-pci.ko.orig
sudo mv /lib/modules/$mykern/kernel/drivers/i2c/busses/i2c-designware-platform.ko /lib/modules/$mykern/kernel/drivers/i2c/busses/i2c-designware-platform.ko.orig
sudo cp drivers/i2c/busses/i2c-designware-*.ko /lib/modules/$mykern/kernel/drivers/i2c/busses/
sudo depmod -a $mykern
echo "Finished building Chromebook modules in $tempbuild. Reboot to use them."
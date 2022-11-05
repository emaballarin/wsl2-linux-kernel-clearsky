#!/usr/bin/env bash

# Become location-aware
PWD_CALLDIR="$(pwd)"

# Download latest published release tarball
eval wget $(curl -s https://api.github.com/repos/emaballarin/wsl2-linux-kernel-clearsky/releases/latest  | grep browser_download_url | cut -d : -f 2,3 | tr -d '"')

# Unpack it
tar xfv ./linux-msft-wsl-*.tar.gz

# Enter extracted folder
cd ./WSL2-Linux-Kernel-linux-msft-wsl-*

# Apply custom configuration
cp ./Microsoft/config-wsl-clearsky-custom ./.config

# Number of build-threads heuristic for WSL2
WSL_NTHREADS=$(($(nproc --all)/2))

# Build
make -j$WSL_NTHREADS

# Copy back relevant build artifact
cp ./arch/x86/boot/bzImage ../clearsky.bzImage

# Build usbip tools/libraries
cd ./tools/usb/usbip
./autogen.sh
./configure --enable-dependency-tracking
make -j$WSL_NTHREADS

# Optionally install such tools/libraries
read -p "Install? [y/N] " -n 1 -r
echo " "
if [[ $REPLY =~ ^[Yy]$ ]]
then
    sudo make install -j$WSL_NTHREADS
    sudo cp -f ./libsrc/.libs/libusbip.a /usr/local/lib/
    sudo cp -f ./libsrc/.libs/libusbip.la /usr/local/lib/
    sudo cp -f ./libsrc/.libs/libusbip.so.0.0.* /usr/local/lib/
    echo "INSTALLED! :)"
fi

# Cleanup
cd "$PWD_CALLDIR"
rm -f ./linux-msft-wsl-*.tar.gz
rm -R -f ./WSL2-Linux-Kernel-linux-msft-wsl-*

# Final greeting
echo " "
echo "Everything done!"
echo "Now remember to copy clearsky.bzImage to an adequate location, and to set-up your .wslconfig file accordingly!"
echo " "

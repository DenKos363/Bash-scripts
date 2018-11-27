#!/bin/bash

#provides variables export according to selected architecture
echo Select x32 or x64 mesa build

read mesa_build

if [ $mesa_build = x64 ]
then
    PATH_TO_LIB=/home/den/mesa64
    export PKG_CONFIG_PATH=/home/den/work/xcb/out/1.13/lib/pkgconfig
    echo $PATH_TO_LIB
elif [ $mesa_build = x32 ]
then
   PATH_TO_LIB=/home/den/mesa32
   export PKG_CONFIG_PATH=/home/den/work/x32/out/xcb_real/1.13/lib/pkgconfig:/home/den/work/x32/out/xcb/1.13/lib/pkgconfig:/home/den/work/x32/out/libdrm/lib/pkgconfig:/usr/lib/i386-linux-gnu/pkgconfig/
   echo $PATH_TO_LIB
   echo $PKG_CONFIG_PATH

else
   echo "WRONG, START AGAIN"
   exit
fi

#provides folder name which includes git tag and current date
echo Provide a folder name please

read foldername
cd /home/den/repositories/mesa/

mesa_hash=git rev-parse --short HEAD
current_date=$(date "+%d.%m")
foldername1=$foldername-$mesa_hash-$current_date

echo Library will be installed into $PATH_TO_LIB/$foldername1
#set -x			# activate debugging from here

#checks for previously built folders and clean them if they exist and then builds libs
if [ -d "mbuild64" ]
then
   rm -rf mbuild64/
elif [ -d "mbuild32" ]
then
   rm -rf mbuild32/
fi

if [ $mesa_build = x64 ]
then
   meson -Dbuildtype=debug -Dvalgrind=false -Ddri-drivers=i965 -Dgallium-drivers= -Dvulkan-drivers= -Dgallium-omx="disabled" -Dplatforms=x11,drm,surfaceless -Dtools=intel --prefix=$PATH_TO_LIB/$foldername1 ./mbuild64/
   ninja -C ./mbuild64/ install
else
   export CC="gcc -m32"
   export CXX="g++ -m32"
   export LDFLAGS="-O0 -ggdb3 -m32"
   meson -Dbuildtype=debug -Dvalgrind=false -Ddri-drivers=i965 -Dgallium-drivers= -Dvulkan-drivers= -Dgallium-omx="disabled" -Dplatforms=x11,drm,surfaceless -Dtools=intel --prefix=$PATH_TO_LIB/$foldername1 ./mbuild32/
   ninja -C ./mbuild32/ install
#set +x			# stop debugging from here
fi

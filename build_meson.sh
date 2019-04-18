#!/bin/bash

filename=$(dirname "$0")/config
test -f $filename || touch $filename
source $(dirname "$0")/config
if [ -z "$MESA_PATH" ]  ||  [ -z "$MESA_OUTPUT_PATH_x32" ]  ||  [ -z "$MESA_OUTPUT_PATH_x64" ]
then
    echo "provide absolute path to local mesa repository"
    read MESA_PATH
    echo "provide desired pathes to x32 mesa version output"
    read MESA_OUTPUT_PATH_x32
    echo "provide desired pathes to x64 mesa version output"
    read MESA_OUTPUT_PATH_x64
    echo "MESA_PATH=$MESA_PATH" >> $(dirname "$0")/config
    echo "MESA_OUTPUT_PATH_x32=$MESA_OUTPUT_PATH_x32" >> $(dirname "$0")/config
    echo "MESA_OUTPUT_PATH_x64=$MESA_OUTPUT_PATH_x64" >> $(dirname "$0")/config
else
    echo "Variables were taken from $(dirname "$0")/config file. If you want to change "
fi

#provides variables export according to selected architecture
echo "Select x32 or x64 mesa build"
read mesa_build

if [ $mesa_build = x64 ]
then
    PATH_TO_LIB=$MESA_OUTPUT_PATH_x64
    echo $PATH_TO_LIB
elif [ $mesa_build = x32 ]
then
   PATH_TO_LIB=$MESA_OUTPUT_PATH_x32
   echo $PATH_TO_LIB

else
   echo "WRONG, START AGAIN"
   exit
fi

cd $MESA_PATH
mesa_version=$(cat VERSION)

mesa_hash=$(git rev-parse --short HEAD)
current_date=$(date "+%d.%m")
foldername1=$mesa_version-$mesa_hash-$current_date-DEBUG

echo "Library will be installed into $PATH_TO_LIB/$foldername1"

#checks for previously built folders and clean them if they exist and then builds libs
git clean -dfx

if [ $mesa_build = x64 ]
then
   meson \
   -Dbuildtype=debug \
   -Dvalgrind=false \
   -Ddri-drivers=i965 \
   -Dgallium-drivers= \
   -Dvulkan-drivers= \
   -Dgallium-omx="disabled" \
   -Dplatforms=x11,drm,surfaceless \
   -Dtools=intel \
   -Dd_ndebug=false \
   --prefix=$PATH_TO_LIB/$foldername1 ./mbuild64/
   ninja -C ./mbuild64/ install
else
   export CC="gcc -m32"
   export CXX="g++ -m32"
   export LDFLAGS="-O0 -ggdb3 -m32"
   meson \
   -Dbuildtype=debug \
   -Dvalgrind=false \
   -Ddri-drivers=i965 \
   -Dgallium-drivers= \
   -Dvulkan-drivers= \
   -Dgallium-omx="disabled" \
   -Dplatforms=x11,drm,surfaceless \
   -Dtools=intel \
   -Dd_ndebug=false \
   --prefix=$PATH_TO_LIB/$foldername1 ./mbuild32/
   ninja -C ./mbuild32/ install
#set +x			# stop debugging from here
fi

echo "Do you want to export env variables? Type yes or no."
read answer
if [ $answer = yes ]
then
    export LD_PRELOAD=$(find $MESA_OUTPUT_PATH_x64/$foldername1/ -name libGL.so.1)
    export LIBGL_DRIVERS_PATH=$(find $MESA_OUTPUT_PATH_x64/$foldername1/ -name dri)
    echo "Export was successfull"
fi
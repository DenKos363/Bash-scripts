#!/bin/bash
echo Select x32 or x64 mesa build

read mesa_build

if [ $mesa_build = x64 ]
then
    PATH_TO_LIB=/home/den/mesa64
    echo $PATH_TO_LIB
elif [ $mesa_build = x32 ]
then
   PATH_TO_LIB=/home/den/mesa32
   echo $PATH_TO_LIB
else
   echo "WRONG, START AGAIN"
   exit
fi


echo Provide a folder name please

read foldername

echo Library will be installed into $PATH_TO_LIB/$foldername

cd /home/den/repositories/mesa/
make distclean
if [ $mesa_build = x64 ]
then
    ./autogen.sh --with-gallium-drivers="" --with-dri-drivers=i965 --prefix=$PATH_TO_LIB/$foldername
#    make -j4
#    make install
#    echo INSTALLATION COMPLETE to $PATH_TO_LIB/$foldername
else
    export CC="gcc -m32"
    export CXX="g++ -m32"
    ./autogen.sh --with-gallium-drivers= --with-dri-drivers=i965 --build=x86_64-linux-gnu --host=i686-pc-linux-gnu --prefix=$PATH_TO_LIB/$foldername
#    make -j4
#    make install
#    echo INSTALLATION COMPLETE to $PATH_TO_LIB/$foldername
fi

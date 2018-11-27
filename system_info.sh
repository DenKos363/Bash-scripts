#!/bin/bash
#Distro=`lsb_release -a | grep Description`
#Distro_name=${Distro##*:}
#echo Distributive "->" $Distro_name
echo Distributive "->" `lsb_release -ds 2>/dev/null || cat /etc/*release 2>/dev/null | head -n1 || uname -om`
echo Kernel version "->" `uname -r`
GPU1=`glxinfo -B | grep "OpenGL renderer"`
GPU_NAME=${GPU1##*:}
echo GPU "->" $GPU_NAME
MESA=`glxinfo -B | grep "OpenGL version"`
MESA_VERSION=${MESA##*:}
echo Mesa version "->" $MESA_VERSION
echo `grep "X.Org X Server" /var/log/Xorg.0.log`

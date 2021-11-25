#!/bin/bash
# Determine OS platform
UNAME=$(uname)
# If Linux, try to determine specific distribution
if [ "${UNAME,,}" == "linux" ]; then
    # If available, use LSB to identify distribution
    if [ -f /etc/lsb-release -o -d /etc/lsb-release.d ]; then
        DISTRO=$(lsb_release -i | cut -d':' -f2 | sed s/'^\t'// | tr "[:upper:]" "[:lower:]" ) && echo ${DISTRO} > /tmp/linux_distro1.txt
    # Otherwise, use release info file
    else
        DISTRO=$(ls -d /etc/[A-Za-z]*[_-][rv]e[lr]* | grep -v "lsb" | cut -d'/' -f3 | cut -d'-' -f1 | cut -d'_' -f1 | tr "[:upper:]" "[:lower:]") && echo ${DISTRO} >/tmp/linux_distro2.txt
    fi
fi
# For everything else (or if above failed), just use generic identifier
# [ "$DISTRO" == "" ] && echo $UNAME > /tmp/linux_distro.txt

for dist in $DISTRO
do
   if [ ${dist,,} == "centos" ]; then
        echo ${dist} > /tmp/linux_specific.txt
   elif [ ${dist,,} == "ubuntu" ]; then
	echo ${dist} > /tmp/linux_specific.txt
   elif [ ${dist,,}  == "debian" ]; then
	echo ${dist} > /tmp/linux_specific.txt
   fi
done

unset UNAME
unset DISTRO

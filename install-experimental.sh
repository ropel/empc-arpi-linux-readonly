#!/bin/bash

ERR='\033[0;31m'
INFO='\033[0;32m'
NC='\033[0m' # No Color

if [ $EUID -ne 0 ]; then
    echo -e "ERRORE: Questo script deve girare come root" 1>&2
    exit 1
fi

KERNEL=$(uname -r)

VERSION=$(echo $KERNEL | cut -d. -f1)
PATCHLEVEL=$(echo $KERNEL | cut -d. -f2)
SUBLEVEL=$(echo $KERNEL | cut -d. -f3 | cut -d- -f1)

KERNELVER=$(($VERSION*100000+1000*$PATCHLEVEL+$SUBLEVEL));

if [ $KERNELVER -le 409040 ]; then 
 echo "$ERR WARNING: versione kernel non supportata. >4.9.40 required $NC" 1>&2
 exit 0
fi

if (cat /etc/issue | grep -v Raspbian) then
    echo -e "$ERR ERROR: Questo script è compatibile solo con Raspbian Linux. $NC" 1>&2
    exit 1
fi

clear
WELCOME="Questo script attiva il read-only filesystem overlay\n
continuare l'installazione?"

if (whiptail --title "Script installazione Read-only Filesystem" --yesno "$WELCOME" 20 60) then
    echo ""
else
    exit 0
fi

sed -i '1 s/^/overlay=yes /' /boot/cmdline.txt 

wget -nv https://raw.githubusercontent.com/ropel/empc-arpi-linux-readonly/master/hooks_overlay -O /etc/initramfs-tools/hooks/overlay
wget -nv https://raw.githubusercontent.com/ropel/empc-arpi-linux-readonly/master/init-bottom_overlay -O /etc/initramfs-tools/scripts/init-bottom/overlay

chmod +x /etc/initramfs-tools/hooks/overlay
chmod +x /etc/initramfs-tools/scripts/init-bottom/overlay

mkinitramfs -o /boot/initramfs.gz
echo "initramfs initramfs.gz followkernel" >>/boot/config.txt

if (whiptail --title "Script installazione Read-only Filesystem" --yesno "Installazione completata! Necessario reboot\n\nreboot adesso?" 12 60) then
    reboot
fi

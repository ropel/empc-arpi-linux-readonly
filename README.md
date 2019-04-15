Proteggi la µSD card  del tuo Raspberry Pi (usa un filesystem read-only)
=============================================================

**ATTENZIONE!! IMPOSTAZIONI SPERIMENTALI:fai una copia di backup della tua µSD card prima di applicare queste impostazioni!**

* rendi il filesystem read only per evitarne l'accidentale danneggiamento quando si toglie l'alimentazione
* le operazioni di scrittura sulla µSD card vengono dirottate su un overlay filesystem in RAM 

Prerequisiti:
* Raspbian Stretch with Desktop (2017-09-07)
* Raspbian Stretch Lite (2017-09-07)

scripts basati su: https://gist.github.com/mutability/6cc944bde1cf4f61908e316befd42bc4
e: https://github.com/janztec/empc-arpi-linux-readonly

Rendere il Filesystem Read-Only
=========================

**Disabilitare lo SWAP**
```
sudo dphys-swapfile swapoff
sudo systemctl disable dphys-swapfile
sudo apt-get purge dphys-swapfile
```

**Disabilitare il man indexing**
```
sudo chmod -x /etc/cron.daily/man-db
sudo chmod -x /etc/cron.weekly/man-db
```

**Spostare /var/log to tmpfs**

Aggiungere al file /etc/fstab (utilizzare nano o  vi)

_tmpfs		/var/log	tmpfs	size=70M	0	0_
```
sudo nano /etc/fstab
```


**Disabilitare log files non necessari**
```
sudo nano /etc/rsyslog.conf
```

**Installare lo script script**
```
cd /tmp
wget https://raw.githubusercontent.com/ropel/empc-arpi-linux-readonly/master/install-experimental.sh -O install-experimental.sh
pi@raspberrypi:/tmp $ sudo bash install-experimental.sh
```


Check Stato
-------------

* Read only mode abilitato
```
pi@raspberrypi:/home/pi $ sudo df
Filesystem     1K-blocks    Used Available Use% Mounted on
...
/dev/mmcblk0p2  15205520 4309620  10215392  30% /ro
overlay-rw        262144  115108    147036  44% /rw
...
```


Rendere il Filesystem nuovamente Read-Write 
================================

* sudo nano /boot/cmdline.txt
* change *overlay=yes* to *overlay=no*
* Ctrl+o and Ctrl+x
* sudo reboot


Check Stato
-------------

* Read only mode disabilitato
```
pi@raspberrypi:/home/pi $ sudo df
Filesystem     1K-blocks    Used Available Use% Mounted on
/dev/mmcblk0p2  15205520 4309756  10215256  30% /
```

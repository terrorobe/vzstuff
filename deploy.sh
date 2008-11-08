#!/bin/bash

echo $1

VEID=$1

echo $VEID

exit

debootstrap --exclude=dhcp-client,dhcp3-client,dhcp3-common,dmidecode,gcc-4.2-base,nano,module-init-tools,tasksel,tasksel-data,libdb4.4,libsasl2-2,libgnutls26,libconsole,libgnutls13,libtasn1-3,liblzo2-2,libopencdk10,libgcrypt11 --include=vim,mailx,mtr-tiny,screen,strace,ltrace,telnet,dnsutils,file,less,iptraf,lsof,rsync --arch amd64 lenny /var/lib/vz/private/$VEID http://ftp.at.debian.org/debian

perl -pi -e 's\^(?!#)(.*/sbin/getty)\#$1\' /var/lib/vz/private/$VEID/etc/inittab


#vzctl create 3000 --ipadd 86.59.21.20 --hostname trottelkunde.amd.co.at --ostemplate debian-4.1-bootstrap

# unattended-upgrades
#
#APT::Periodic::Update-Package-Lists "1";
#APT::Periodic::Unattended-Upgrade "1";
#APT::Periodic::AuotcleanInterval 60;

#etckeeper
#etckeeper init
#cd /etc/
#git ci -m "initial commit"
#git commit -m "initial commit"
#git gc
#


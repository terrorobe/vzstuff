#!/bin/bash -x

if [ $# -ne  3 ]; then
	echo "Usage: $0 <VEID> <Hostname> <IP-Address>"
	exit 1
fi

VEID=$1
HN=$2
IP=$3
VEROOT=/var/lib/vz/private/$VEID

echo "VEID: $VEID"
echo "Hostname: $HN"
echo "IP: $IP"
echo "VEROOT: $VEROOT"
echo "Is this fine?"

read lala

exit

check_rc() {
RC=$?
if [ $RC -gt 0 ]; then
        echo "Failed in $1, RC was $RC. Bailing out"
        exit 1
fi
}

 
vzctl create $VEID --ipadd $IP --hostname $HN --ostemplate debian-4.1-bootstrap
check_rc "vzctl create"

debootstrap --exclude=dhcp-client,dhcp3-client,dhcp3-common,dmidecode,gcc-4.2-base,nano,module-init-tools,tasksel,tasksel-data,libdb4.4,libsasl2-2,libgnutls26,libconsole,libgnutls13,libtasn1-3,liblzo2-2,libopencdk10,libgcrypt11 --include=vim,mailx,mtr-tiny,screen,strace,ltrace,telnet,dnsutils,file,less,iptraf,lsof,rsync,unattended-upgrades,etckeeper --arch amd64 lenny $VEROOT http://ftp.at.debian.org/debian
check_rc "debootstrap"

perl -pi -e 's\^(?!#)(.*/sbin/getty)\#$1\' $VEROOT/etc/inittab
check_rc "inittab edit"

cat << EOF >> $VEROOT/etc/apt/apt.conf
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::AuotcleanInterval 60;
EOF
check_rc "Editing apt.conf"


#etckeeper
#etckeeper init
#cd /etc/
#git ci -m "initial commit"
#git commit -m "initial commit"
#git gc
#


#!/bin/bash

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
echo "Is this fine? (y/n)"

read safetypin
if [ "$safetypin" != "y" ]; then
        echo "Aborting at your discretion"
        exit 1
fi

check_rc() {
RC=$?
if [ $RC -ne 0 ]; then
        echo "Failed in $1, RC was $RC. Bailing out"
        exit 1
fi
}

# This is needed so that etckeeper doesn't complain about nonexisting locales
unset LANG
 
vzctl create $VEID --ipadd $IP --hostname $HN --ostemplate debian-4.1-bootstrap
check_rc "vzctl create"

echo "Bootstrapping silently"
debootstrap --exclude=dhcp-client,dhcp3-client,dhcp3-common,dmidecode,gcc-4.2-base,nano,module-init-tools,tasksel,tasksel-data,libdb4.4,libsasl2-2,libgnutls26,libconsole,libgnutls13,libtasn1-3,liblzo2-2,libopencdk10,libgcrypt11 --include=vim,mailx,mtr-tiny,screen,strace,ltrace,telnet,dnsutils,file,less,iptraf,lsof,rsync,unattended-upgrades,etckeeper --arch amd64 lenny $VEROOT http://ftp.at.debian.org/debian > /dev/null
check_rc "debootstrap"

#Removing gettys from inittab, since they are of no use in a VE
perl -pi -e 's\^(?!#)(.*/sbin/getty)\#$1\' $VEROOT/etc/inittab
check_rc "inittab edit"

#Unattended upgrades settings
cat << EOF >> $VEROOT/etc/apt/apt.conf
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::AuotcleanInterval 60;
EOF
check_rc "Editing apt.conf"

cat << EOF >> $VEROOT/root/etckickoff.sh
#!/bin/bash
etckeeper init
cd /etc
git commit -a -m "initial commit"
EOF
check_rc "Writing etckeeper script"

echo "Setting up etckeeper"
chroot /var/lib/vz/private/$VEID /bin/bash /root/etckickoff.sh > /dev/null
check_rc "Executing etckeeper script"


#Removing etckeeper setup and template dummy files
rm $VEROOT/INSTANCEd $VEROOT/root/etckickoff.sh
check_rc "Deleting setup files"

echo "We completed successfully."



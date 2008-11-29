#!/bin/bash

# This scripts creates an OpenVZ VE and bootstraps a Debian lenny system to the given _empty_ private area
# Author: Michael Renner

SCRIPTDIR=`dirname $PWD/$0`
CONFIGFILE=$SCRIPTDIR/deploy.conf
VZCONFDIR=/etc/vz
VZCONF=$VZCONFDIR/vz.conf

if [ ! -f $CONFIGFILE ]; then
        echo "Please create a file named 'deploy.conf' in the same directory as the script."
        echo "See deploy.conf.example for needed parameters."
        exit 1
fi

source $CONFIGFILE

source $SCRIPTDIR/deploy-functions.sh

check_settings


if [ "$1" == "setup" ]; then
	echo "I am going to create the OpenVZ template and distribution $DEPLOYTEMPLATE."
	echo "Is this fine? (y/n)"
	prompt_user
	create_template
	create_dist
	echo "Successfully created $DEPLOYTEMPLATE"
	exit 0
fi

if [ $# -ne  3 ]; then
	echo "Usage: $0 <VEID> <Hostname> <IP-Address>"
	echo "or to create the needed template and distribution:"
	echo "Usage: $0 setup"
	exit 1
fi

VEID=$1
HN=$2
IP=$3

fetch_vz_setting "VE_PRIVATE"
# interpolating strings, bash-style
VEROOT=`eval echo $VZCONFVALUE`

echo "VEID: $VEID"
echo "Hostname: $HN"
echo "IP: $IP"
echo "VEROOT: $VEROOT"
echo "ADMINADDR: $ADMINADDR"
echo "RECURSOR: $RECURSOR"
echo "SMARTHOST: $SMARTHOST"
echo "Is this fine? (y/n)"


prompt_user


# This is needed so that etckeeper doesn't complain about nonexisting locales
unset LANG
 
vzctl create $VEID --ipadd $IP --hostname $HN --ostemplate debian-4.1-bootstrap
check_rc "vzctl create"
vzctl set $VEID --save --nameserver $RECURSOR
check_rc "vzctl set nameserver"

echo "Bootstrapping silently"
debootstrap --exclude=dhcp-client,dhcp3-client,dhcp3-common,dmidecode,gcc-4.2-base,nano,module-init-tools,tasksel,tasksel-data,libdb4.4,libsasl2-2,libgnutls26,libconsole,libgnutls13,libtasn1-3,liblzo2-2,libopencdk10,libgcrypt11 --include=vim,mtr-tiny,screen,strace,ltrace,telnet,dnsutils,file,less,iptraf,lsof,rsync,unattended-upgrades,etckeeper,nullmailer --arch amd64 lenny $VEROOT $DEBMIRROR > /dev/null
check_rc "debootstrap"

#Removing gettys from inittab, since they are of no use in a VE
perl -pi -e 's|^(?!#)(.*/sbin/getty)|#$1|' $VEROOT/etc/inittab
check_rc "inittab edit"

#Unattended upgrades settings
cat << EOF >> $VEROOT/etc/apt/apt.conf
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::AutocleanInterval 60;
EOF
check_rc "Editing apt.conf"

echo -e "\n\ndeb http://security.debian.org/ lenny/updates main\n" >> $VEROOT/etc/apt/sources.list
check_rc "Editing sources.list"

cat << EOF >> $VEROOT/root/etckickoff.sh
#!/bin/bash
etckeeper init
cd /etc
git commit -a -m "initial commit"
apt-get update
EOF
check_rc "Writing etckeeper script"


echo "Setting up nullmailer"
echo $ADMINADDR > $VEROOT/etc/nullmailer/adminaddr
check_rc "Setting nullmailer adminaddr"
echo $SMARTHOST > $VEROOT/etc/nullmailer/remotes
check_rc "Setting nullmailer remotes"
echo $HN > $VEROOT/etc/mailname
check_rc "Setting mailname"

#This should be done pretty much at the end since it does the inital commit of the /etc directory
echo "Setting up etckeeper, invoking post-install commands"
chroot $VEROOT /bin/bash /root/etckickoff.sh > /dev/null
check_rc "Executing etckeeper script"


#Removing etckeeper setup and template dummy files
rm $VEROOT/BOOTSTRAPPED $VEROOT/root/etckickoff.sh
check_rc "Deleting setup files"

echo "We completed successfully."



# These are helper functions for deploy.sh
# (c) 2008-2011, Michael Renner

check_settings() {

if [ "${ADMINADDR+set}" != set ]; then
        echo "ADMINADDR is not set. Please check '$CONFIGFILE'"
        exit 1
fi

if [ "${RECURSOR+set}" != set ]; then
        echo "RECURSOR is not set. Please check '$CONFIGFILE'"
        exit 1
fi

if [ "${SMARTHOST+set}" != set ]; then
        echo "SMARTHOST is not set. Please check '$CONFIGFILE'"
        exit 1
fi

if [ "${DEPLOYTEMPLATE+set}" != set ]; then
        echo "DEPLOYTEMPLATE is not set. Please check '$CONFIGFILE'"
        exit 1
fi

if [ "${DEBMIRROR+set}" != set ]; then
        echo "DEBMIRROR is not set. Please check '$CONFIGFILE'"
        exit 1
fi

if [ "${DEBARCH+set}" != set ]; then
        echo "DEBARCH is not set. Please check '$CONFIGFILE'"
        exit 1
fi

}


prompt_user() {
read safetypin
if [ "$safetypin" != "y" ]; then
        echo "Aborting at your discretion"
        exit 1
fi
}


check_rc() {
RC=$?
if [ $RC -ne 0 ]; then
        echo "Failed in $1, RC was $RC. Bailing out"
        exit 1
fi
}

fetch_vz_setting() {

VZCONFVALUE=`grep -m1 ^$1= $VZCONF | cut -f2- -d"="`
}

create_template() {

fetch_vz_setting "TEMPLATE"
TEMPLATEDIR=$VZCONFVALUE
TARGETFILE=$TEMPLATEDIR/cache/$DEPLOYTEMPLATE.tar.gz
if [ -f $TARGETFILE ]; then
	echo "$TARGETFILE already exists. Skipping template creation."
	return
fi

TEMPDIR=`mktemp -d` || exit 1
TEMPFILE=`mktemp` || exit 1

# We need a file in the tarball since vzcreate barfs on empty tarballs
touch $TEMPDIR/BOOTSTRAPPED
tar -zc -C $TEMPDIR . -f $TEMPFILE

mv $TEMPFILE $TARGETFILE

rm $TEMPDIR/BOOTSTRAPPED
rmdir $TEMPDIR
}

create_dist() {

SOURCEFILE=$VZCONFDIR/dists/debian.conf
TARGETFILE=$VZCONFDIR/dists/$DEPLOYTEMPLATE.conf
if [ -a $TARGETFILE ]; then

	echo "$TARGETFILE already exists. Skipping dists creation."
	return
fi

cp $SOURCEFILE $TARGETFILE

}

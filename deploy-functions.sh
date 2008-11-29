

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
/bin/false
}

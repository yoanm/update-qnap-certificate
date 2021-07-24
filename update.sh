#!/bin/bash

USAGE_PARAMS="\"Certificate filepath\" \"Key filepath\" [--quiet]";
STUNNEL_PATH="/etc/stunnel";
STUNNEL_TMP_PATH="${STUNNEL_PATH}/tmp_cert_file";
CERT_DEST_FILEPATH="${STUNNEL_PATH}/backup.cert.def";
KEY_DEST_FILEPATH="${STUNNEL_PATH}/backup.key.def";

if [[ -z $1 ]] || [[ -z $2 ]]; then
	echo "Usage: $0 or $0 ${USAGE_PARAMS}";
	exit 1;
else
	CERT_FILEPATH="$1";
	KEY_FILEPATH="$2";
	QUIET=false;
	if [ "$3" = "--quiet" ] ; then
		QUIET=true
	fi
fi

if [ "$QUIET" = false ] ; then
	echo "[$(date)] Starting"
fi

if [[ ! -f $CERT_FILEPATH ]]; then
	if [ "$QUIET" = false ] ; then
		echo "${CERT_FILEPATH} not found !";
	fi
	exit 2;
fi
if [[ ! -f $KEY_FILEPATH ]]; then
	if [ "$QUIET" = false ] ; then
		echo "${KEY_FILEPATH} not found !";
	fi
	exit 2;
fi

CERT_DIRECTORY=$(dirname ${CERT_FILEPATH});
KEY_DIRECTORY=$(dirname ${KEY_FILEPATH});
TMP_CERT_FILEPATH=$(echo $CERT_FILEPATH | sed "s#${CERT_DIRECTORY}#${STUNNEL_TMP_PATH}#g");
TMP_KEY_FILEPATH=$(echo $KEY_FILEPATH | sed "s#${KEY_DIRECTORY}#${STUNNEL_TMP_PATH}#g");

mkdir -p $STUNNEL_TMP_PATH;

echo "Move files to stunnel tmp folder";
mv $CERT_FILEPATH $KEY_FILEPATH $STUNNEL_TMP_PATH;
if [[ $? -ne 0 ]]; then
	echo "Error during move to tmp folder !"; 
	exit 3;
fi

echo "Copy certificate ${TMP_CERT_FILEPATH} to ${CERT_DEST_FILEPATH}";
cp $TMP_CERT_FILEPATH $CERT_DEST_FILEPATH;
if [[ $? -ne 0 ]]; then
	echo "Error during certificate copy !"; 
	exit 4;
fi


echo "Copy certificate ${TMP_KEY_FILEPATH} to ${KEY_DEST_FILEPATH}";
cp $TMP_KEY_FILEPATH $KEY_DEST_FILEPATH
if [[ $? -ne 0 ]]; then
	echo "Error during key copy !"; 
	exit 4;
fi


echo "Generating certificate files";
/etc/init.d/stunnel.sh generate_cert_key
if [[ $? -ne 0 ]]; then
	echo "Error during certificate files generation !"; 
	exit 5;
fi


echo "Restart services";
/etc/init.d/stunnel.sh restart && /etc/init.d/Qthttpd.sh restart
if [[ $? -ne 0 ]]; then
	echo "Error during service restart !"; 
	exit 6;
fi


echo "Remove original files"
rm -Rf $STUNNEL_TMP_PATH
if [[ $? -ne 0 ]]; then
	echo "Error during cleaning !"; 
	exit 7;
fi

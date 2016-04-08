#!/bin/bash 

# Script to update the local dnsmasq DNS forwarders
# it will restart dnsmasq only when necesary

DNS_SCRIPT=$PWD/fuel-devops-local-dnsmasq.py
TMP_FILE=/tmp/tmp-fuel-devops-environments
DNSMASQ_FILE=/etc/dnsmasq.d/fuel-devops-environments

#Check if Python virtual env is active
# add extra export so it works when sourcing this script
if [ "$VIRTUAL_ENV" = "" ] ; then
        echo "Python VIRTUAL ENV not detected"
        export WORKON_HOME=$HOME/.virtualenvs
        source /usr/local/bin/virtualenvwrapper.sh

        # Set python virtual envirionment:
        workon fuel-devops-development-venv-2.9
        export VENV_PATH=fuel-devops-development-venv-2.9
fi

# Output tmp file
$DNS_SCRIPT > $TMP_FILE

# Compare files:
DIFF=$( diff -I '^# last update.*' $TMP_FILE $DNSMASQ_FILE )
echo "Comparing tmp file $TMP_FILE with $DNSMASQ_FILE"
if [ ! "${DIFF}" = "" ] ; then
	echo "Update to dnsmasq file is needed"
	echo "diff output:"
	colordiff -I '^# last update.*' $TMP_FILE $DNSMASQ_FILE
	sudo mv $TMP_FILE $DNSMASQ_FILE
	echo "Restarting dnsmasq to force updates"
	sudo service dnsmasq force-reload
else
	echo "No updates to dnsmasq"
fi

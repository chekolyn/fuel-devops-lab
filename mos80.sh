#!/bin/bash 

#Check if Python virtual env is active
# add extra export so it works when sourcing this script
if [ "$VIRTUAL_ENV" = "" ] ; then
	echo "Python VIRTUAL ENV not detected"
	export WORKON_HOME=$HOME/.virtualenvs
	source /usr/local/bin/virtualenvwrapper.sh
	
	# Set python virtual envirionment:
	workon fuel-devops-venv-2.9
	export VENV_PATH=fuel-devops-venv-2.9
fi

########################################################################################
# Fuel devops settings

export ENV_NAME=mos80			#YOUR ENV Name must be unique; also used in DNS
export ISO_PATH=/home/sto/ISO/MirantisOpenStack-8.0.iso
export NODE_COUNT=5
export ADMIN_NODE_CPU=4
export ADMIN_NODE_MEMORY=6144
export ADMIN_NODE_VOLUME_SIZE=75
export SLAVE_NODE_CPU=4
export SLAVE_NODE_MEMORY=4096
export INTERFACE_MODEL=virtio		#very important for performance
export DRIVER_USE_HOST_CPU=False	#very important because with out VMs will hang

########################################################################################

# DNS information:
# This will infered based on your environment name + host node fqdn
# Please dont change DNS settings so we have a standard accross envs
export FUEL_MASTER_HOSTNAME=fuel
export HOST_FQDN=$(hostname -f) #local
export DEFAULT_MASTER_FQDN=$FUEL_MASTER_HOSTNAME.$ENV_NAME.$HOST_FQDN #fuel-devops
export DEFAULT_DOMAIN=${ENV_NAME}.${HOST_FQDN}

# Networking:
# Currentl fuel-devops ignores the forwarding rules;
# a manual hack has been added to the code:
# please see: https://mirantis.jira.com/wiki/display/2S/STO+Lab+with+fuel-devops#STOLabwithfuel-devops-codechanges
export FORWARD_DEFAULT=route		#currently not working
export ADMIN_FORWARD=route		#currently not working
export PUBLIC_FORWARD=route		#currently not working
export NET_POOL='172.17.0.0/21:27'	#STO Subnet 02; directly routed to suplab02


# Echo env settings
echo "*** Showing ENV Variables ***"
echo "ENV_NAME=${ENV_NAME}"
echo "DEFAULT_MASTER_FQDN=${DEFAULT_MASTER_FQDN}"
echo "DEFAULT_DOMAIN=${DEFAULT_DOMAIN}"
echo "ISO_PATH=${ISO_PATH}"
#echo "FORWARD_DEFAULT=${FORWARD_DEFAULT}"
echo "NET_POOL=${NET_POOL}"

ENV_CREATE="dos.py create --node-count $NODE_COUNT --vcpu $SLAVE_NODE_CPU --ram $SLAVE_NODE_MEMORY --iso-path $ISO_PATH --admin-ram $ADMIN_NODE_MEMORY --admin-vcpu $ADMIN_NODE_CPU --admin-disk-size $ADMIN_NODE_VOLUME_SIZE --net-pool $NET_POOL $ENV_NAME"

# Important to use eth0 when using virtio
# if not kernel boot parameters with not be correct
ADMIN_SETUP="dos.py admin-setup-centos7 --admin-disk-size $ADMIN_NODE_VOLUME_SIZE --iface eth0 $ENV_NAME"

if [[ $1 = "run" ]] ; then
    echo "*** Running mode ***"
    echo "Creating the env: $ENV_NAME"
    #$ENV_CREATE
    echo "Setup of Admin node in env: $ENV_NAME"
    #$ADMIN_SETUP
    #echo "Checking for DNS changes:"
    #$HOME/bin/update-fuel-devops-local-dnsmasq.sh
else
    echo "*** DEMO MODE ***"
    echo "Add run at the end to run the dos.py commands:"    
    echo "Command to create the env: $ENV_NAME"
    echo $ENV_CREATE
    echo "Command to setup the admin node in env: $ENV_NAME"
    echo $ADMIN_SETUP
    echo "When running manual commands don't forget to source this script to set the ENV variables"
fi


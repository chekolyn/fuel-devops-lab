#!/usr/bin/env python

# This script will look at the local fuel-devops environments
# and it will output a dsnmasq compatible file for
# the proper DNS forwarders for each fuel-devops environment
# this file output should be put somewhere at /etc/dnsmasq.d/*

import datetime
import socket
from ipaddr import IPNetwork

from devops.helpers.helpers import SSHClient
from devops.models import DiskDevice
from devops.models import Environment
from devops.models import Interface
from devops.models import Network
from devops.models import Node
from devops.models import Volume

def list_env():
    environments = Environment.list_all()
    for env in environments:
        print "Env: %s" % env.name
        print "DNS: %s" % socket.getfqdn()

        for node in env.get_nodes():
            if node.is_admin:
                print "admin node ip: %s" % node.get_ip_address_by_network_name('admin')

def dnsmasq_file_output():
    environments = Environment.list_all()
    print "# fuel-devops dnsmasq output:"
    print "# last update UTC: %s" % datetime.datetime.utcnow()
    for env in environments:
        for node in env.get_nodes():
            if node.is_admin:
                #dnsmasq format: 
                print("server=/{0}.{1}/{2}".format(env.name, socket.getfqdn(), node.get_ip_address_by_network_name('admin')))

if __name__ == '__main__':
    #list_env()
    dnsmasq_file_output()


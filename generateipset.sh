#!/bin/bash
#########################################################
#   Filename   : generateipset.sh                             #
#   Description: TODO   #
#########################################################

PROGNAME="$(basename $0)"
quiet=false

set -u
whitelistdir="/etc/myipsets/whitelist.d"
blacklistdir="/etc/myipsets/blacklist.d"

mkdir -p "$whitelistdir"
mkdir -p "$blacklistdir"

ipset destroy blacklist
ipset flush blacklist
ipset create blacklist hash:ip hashsize 4096

for port in 22 80 443; do
    iptables -I INPUT  -m set --match-set blacklist src -p TCP \
         --destination-port $port -j REJECT
    iptables -I INPUT  -m set --match-set blacklist src -p TCP \
         --destination-port $port -j LOG --log-prefix '[REJECT]:'
done



listip=$(curl -s http://www.openbl.org/lists/base_30days.txt.gz | gunzip | grep -v "^#")


echo "$listip" > "$blacklistdir/base_30days.txt"



for ip in  $(grep -h -v -f $whitelistdir/*.txt $blacklistdir/*.txt); do
    echo "black $ip"
    ipset add blacklist $ip
done



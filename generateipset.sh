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

iptables="/sbin/iptables"
ipset="/sbin/ipset"

allowedports="22 80 443 29000"

. /etc/default/myblacklist

mkdir -p "$whitelistdir"
mkdir -p "$blacklistdir"


$ipset destroy blacklist

$iptables -F
$iptables -X
$iptables -F

$iptables -A INPUT -i lo -j ACCEPT

$ipset create blacklist hash:ip hashsize 4096

for port in $allowedports; do
    $iptables -A INPUT  -m set --match-set blacklist src -p TCP\
         --destination-port $port -j REJECT
    $iptables -A INPUT  -m set --match-set blacklist src -p TCP\
         --destination-port $port -j LOG --log-prefix '[IPTABLES][BACKLIST]:'
    $iptables -A INPUT  -m set --match-set blacklist src -p UDP\
         --destination-port $port -j REJECT
    $iptables -A INPUT  -m set --match-set blacklist src -p UDP\
         --destination-port $port -j LOG --log-prefix '[IPTABLES][BACKLIST]:'
done

for port in $allowedports; do
    $iptables -A INPUT -i eth0 -p tcp --dport $port -j ACCEPT
    $iptables -A INPUT -i eth0 -p udp --dport $port -j ACCEPT
done

listip=$(curl -s http://www.openbl.org/lists/base_30days.txt.gz | gunzip | grep -v "^#")
echo "$listip" > "$blacklistdir/base_30days.txt"


for ip in  $(grep -h -v -f $whitelistdir/*.txt $blacklistdir/*.txt); do
    $ipset add blacklist $ip -exist
done

count="$(grep -c -h -v -f $whitelistdir/*.txt $blacklistdir/*.txt)"

echo "[Blacklist] $count IP bloquees"

# bloquer tout le reste
$iptables -A INPUT -p icmp -j ACCEPT

$iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT  
$iptables -A INPUT -m limit --limit 2/min -j LOG --log-prefix '[IPTABLES][FORBIDDENPORT]:'
$iptables -A INPUT -j DROP




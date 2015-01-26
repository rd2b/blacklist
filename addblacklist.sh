#!/bin/bash
#########################################################
#   Filename   : addblacklist.sh                             #
#   Description: TODO   #
#########################################################

PROGNAME="$(basename $0)"
quiet=false

set -u

authfile="/var/log/auth.log"
whitelist="/etc/myipsets/whitelist.d/*"
blacklist="/etc/myipsets/blacklist.d/*"

. /etc/default/myblacklist

black="$blacklist/authfailed_$(date +%F).txt"

grep Failed $authfile | grep -v -f $whitelist | grep   -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" |sort -u >> $black

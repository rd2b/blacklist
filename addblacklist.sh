#!/bin/bash
#########################################################
#   Filename   : addblacklist.sh                             #
#   Description: TODO   #
#########################################################

PROGNAME="$(basename $0)"
quiet=false

set -u

authfile="/var/log/auth.log"
whitelistdir="/etc/myipsets/whitelist.d/"
blacklistdir="/etc/myipsets/blacklist.d/"

. /etc/default/myblacklist

black="$blacklistdir/authfailed_$(date +%F).txt"

grep Failed $authfile | grep -v -f "$whitelistdir/*.txt" | grep   -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" |sort -u >> $black

#!/bin/bash
#########################################################
#   Filename   : addblacklist.sh                             #
#   Description: TODO   #
#########################################################

PROGNAME="$(basename $0)"
quiet=false

set -u
set -e
authfile="/var/log/auth.log"
whitelist="/etc/myipsets/whitelist.d/*"
black="/etc/myipsets/blacklist.d/authfailed_$(date +%F).txt"

grep Failed $authfile | grep -v -f $whitelist | grep   -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" |sort -u >> $black

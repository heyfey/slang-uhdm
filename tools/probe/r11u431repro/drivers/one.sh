#!/bin/bash
# one.sh <db>: dump the pristine db and scan it; output lines prefixed with the db path
D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
[ -x "$D" ] || { echo "no dump"; exit 1; }
t=$(mktemp /tmp/r11u431_scr/scan/d.XXXXXX)
timeout 600 $D "$1" > $t 2>/dev/null
python3 /tmp/r11u431_scr/scan/scan.py $t | sed "s|^|$1\t|"
rm -f $t

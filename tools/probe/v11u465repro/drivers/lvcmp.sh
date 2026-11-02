#!/bin/bash
# lvcmp.sh <casedir-run>: per loop var line, the own ts + actual's ts (no parent chain); golden vs pris vs law mismatch counts
W=$1
f(){ /tmp/v11u465_tools/lvall $1 | sed -E 's/ <[^ ]*//g; s/<[^ ]*//g' | sort; }
g=$(f $W/sl/slpp_all/surelog.uhdm); p=$(f $W/pris.uhdm); l=$(f $W/law.uhdm)
echo "pris_miss=$(diff <(echo "$g") <(echo "$p") | grep -c '^>') law_miss=$(diff <(echo "$g") <(echo "$l") | grep -c '^>')"

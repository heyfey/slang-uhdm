#!/bin/bash
# sdiff.sh <casedir> <outtag>: the strict records that differ (golden A, ours B)
c=$(cd $1 && pwd); t=$2
SC=${STRICTCMP:-/tmp/r11u418_bin/uhdm-strictcmp}
h=$(cat $(ls -d $c/* | sort) | md5sum | cut -c1-12)
key=$(echo $c | sed 's|.*/cases/||; s|/|_|g')
$SC --max ${MAX:-6} /tmp/r11u418_scr/gold/$h/slpp_all/surelog.uhdm /tmp/r11u418_scr/out/$key/$t/ours.uhdm 2>&1 | tail -${LINES_:-30}

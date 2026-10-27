#!/bin/bash
# sdiff.sh <casedir> <tag> [--no-canon]: diff of uhdm-strictcmp's walk records, golden vs ours
c=$(cd $1 && pwd); t=$2; shift 2
SC=${STRICTCMP:-/tmp/r11u442_bin/strictcmp}
h=$(cat $(ls -d $c/* | sort) | md5sum | cut -c1-12)
key=$(echo $c | sed "s|.*/tools/probe/||; s|/|_|g")
$SC "$@" --dump-a /tmp/r11u442_scratch/sd_a.txt --dump-b /tmp/r11u442_scratch/sd_b.txt /tmp/r11u442_scr/gold/$h/slpp_all/surelog.uhdm /tmp/r11u442_scr/out/$key/$t/ours.uhdm > /dev/null 2>&1
diff /tmp/r11u442_scratch/sd_a.txt /tmp/r11u442_scratch/sd_b.txt

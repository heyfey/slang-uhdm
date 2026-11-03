#!/bin/bash
# away1.sh <dir>: rc:md5 of pristine, law, ver1 on dut.sv --single-unit --nobuiltin
d=$1; O=/tmp/v11u479_away_$$.uhdm; r=""
for B in /tmp/v11u479_bin/pristine /tmp/v11u479_bin/law /tmp/v11u479_bin/ver1; do
  rm -f $O; (cd "$d" && timeout 120 "$B" dut.sv --single-unit --nobuiltin -o $O >/dev/null 2>&1 </dev/null); r="$r $?:$( [ -f $O ] && md5sum < $O | cut -c1-12)"
done; rm -f $O; echo "$d$r"

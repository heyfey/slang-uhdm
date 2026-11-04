#!/bin/bash
# g478md5.sh <tagA> <tagB> [VAR=val...]: the byte check of § aliasParamStoredRead480 on the r11u478
# and v11u478 grids (98 case dirs): runcase.sh with both frozen binaries, then the dirs whose md5
# differs.  Explicit directories only.
D=$(cd "$(dirname "$0")" && pwd); R=$(cd "$D/../.." && pwd)
A=$1; B=$2; shift 2
dirs=$(find "$R/r11u478repro/cases" "$R/v11u478repro/cases" -mindepth 2 -maxdepth 2 -type d | sort)
"$D/runcase.sh" /tmp/r11u480_bin/slang-uhdm.$A $A $dirs > /tmp/r11u480_md5_$A.txt
env "$@" "$D/runcase.sh" /tmp/r11u480_bin/slang-uhdm.$B $B $dirs > /tmp/r11u480_md5_$B.txt
paste -d' ' <(awk '{print $1, $NF}' /tmp/r11u480_md5_$A.txt) <(awk '{print $NF}' /tmp/r11u480_md5_$B.txt) |
  awk '{n++; if ($2 != $3) {m++; print "MOVE", $0}} END {print n, "dirs,", m + 0, "movers"}'

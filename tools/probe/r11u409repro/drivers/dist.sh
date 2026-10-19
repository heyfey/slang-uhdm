#!/bin/bash
# dist.sh <case> <binA> <binB>: dump-diff line counts vs golden for both binaries
D=$(dirname $0); c=$1; G=$($(dirname $0)/gd.sh $c)
for b in $2 $3; do O=/tmp/r11u409_scr/dist_$(basename $b).uhdm; rm -f $O; (cd $c && $b dut.sv --single-unit --nobuiltin -o $O >/dev/null 2>&1); n=$($D/ddiff.sh $G $O | grep -c '^[<>]'); printf '%s=%s ' $(basename $b) $n; done; echo

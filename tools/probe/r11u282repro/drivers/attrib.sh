#!/bin/bash
# r11u282 attrib.sh <law bin> <gridsum.txt> <out>: for every MOVER case-view, the law binary with each switch off
# alone (`<case> <view> law+<SWITCH> ...md5=..`); attrib.py reads it against gridall.txt.  Fail-closed on $FENCED.
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "attrib.sh: FENCED unset" >&2; exit 2; }
H=$(cd "$(dirname "$0")" && pwd); C=$(cd "$H/../cases" && pwd)
L=$1; G=$2; O=$3
SW="R11U282_PROCSELINST_OFF R11U282_PROCOPINPLACE_OFF R11U282_PROCCATINST_OFF R11U282_PROCIPSINST_OFF R11U282_TFCASEINS_OFF R11U282_CAREPLINST_OFF R11U282_LHSIPSINPLACE_OFF R11U282_CASELBOUND_OFF R11U282_CAHIERBOUND_OFF R11U282_CASTORPHAN_OFF R11U282_CAIMPLICIT_OFF R11U282_CAUNSIZED_OFF R11U282_PROCOPUNARY_OFF R11U282_PROCCATUNARY_OFF R11U282_LHSIPSCLONE_OFF R11U282_REPLCLONE_OFF"
grep '^MOVER' $G | while read -r _ c v _; do v=${v%:}; for sw in $SW; do echo "$c $v $sw"; done; done |
  xargs -P 3 -L 1 bash -c 'export $2=1; echo "$0 $1 law+$2 $(bash '"$H"'/case.sh '"$C"'/$0 '"$L"' $1 5)"' | sort > $O
wc -l < $O

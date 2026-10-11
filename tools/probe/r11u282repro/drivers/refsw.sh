#!/bin/bash
# r11u282 refsw.sh <law bin> <out> <case family>...: the positive control of each refinement switch. Every case-view
# of the named families (both views) runs with the law and with each refinement switch off alone; one line per
# case-view and switch where the bytes differ: `<case> <view> <SWITCH> law=<verdict> off=<verdict>`.  A refinement
# that fixes a break restores the break with its switch off.  Fail-closed on $FENCED (case.sh).
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "refsw.sh: FENCED unset" >&2; exit 2; }
H=$(cd "$(dirname "$0")" && pwd); C=$(cd "$H/../cases" && pwd)
L=$1; O=$2; shift 2
SW="R11U282_CAIMPLICIT_OFF R11U282_CAUNSIZED_OFF R11U282_PROCOPUNARY_OFF R11U282_PROCCATUNARY_OFF R11U282_LHSIPSCLONE_OFF R11U282_REPLCLONE_OFF"
for f in "$@"; do for d in $(cd $C && ls -d $f/*/ | sed 's#/$##'); do for v in d e; do echo "$d $v"; done; done; done |
  xargs -P 3 -L 1 bash -c 'a=$(bash '"$H"'/case.sh '"$C"'/$0 '"$L"' $1 5); for s in '"$SW"'; do b=$(env $s=1 bash '"$H"'/case.sh '"$C"'/$0 '"$L"' $1 5); [ "${a##*md5=}" = "${b##*md5=}" ] || echo "$0 $1 $s law=$(echo $a | cut -d" " -f3,4) off=$(echo $b | cut -d" " -f3,4)"; done' | sort > $O
wc -l < $O

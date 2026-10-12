# (v11u300: copied from r11u300repro/drivers)
# (r11u300: copied from r11u298repro/drivers)
#!/bin/bash
# r11u298 (copied from r11u294repro) (copied from r11u288repro; # r11u288 (copied from r11u286repro; r11u286 copied from r11u284repro; r11u284 copied from r11u282repro) gridall.sh : <pristine bin> <law bin> <out> [label=ENV ...]: every case dir under cases/ in both views, one
# line per case-view and binary label: `<case> <view> <label> rc=.. cmp=.. <strict verdict> md5=..`.  Labels:
# pristine, law, law+R11U300_OFF, and law+<SWITCH> for each extra argument.  Fail-closed on $FENCED (case.sh).
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "gridall.sh: FENCED unset" >&2; exit 2; }
H=$(cd "$(dirname "$0")" && pwd); C=$(cd "${CASES:-$H/../cases}" && pwd)  # v11u300: CASES=<dir> grids another pass's cases
P=$1; L=$2; O=$3; shift 3
{ for d in $(cd $C && ls -d ${GRIDGLOB:-*/*/} | sed 's#/$##'); do for v in d e; do
    echo "$d $v pristine $P -"
    echo "$d $v law $L -"
    echo "$d $v law+R11U300_OFF $L R11U300_OFF"
    for sw in "$@"; do echo "$d $v law+$sw $L $sw"; done
  done; done; } | xargs -P 3 -L 1 bash -c 'if [ "$4" != - ]; then export $4=1; fi; echo "$0 $1 $2 $(bash '"$H"'/case.sh '"$C"'/$0 $3 $1 5)"' | sort > $O
wc -l < $O

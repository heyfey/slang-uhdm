# (r11u306: copied from r11u304repro/drivers, renamed to R11U306 / r11u306)
# (r11u306: copied from r11u302repro/drivers, renamed to R11U306 / r11u306)
#!/bin/bash
# r11u306 controls_list.sh <pristine bin> <law bin> <out> <list>: controls.sh over a LIST of case dirs (paths
# relative to tools/probe, one dut.sv dir per line, the list built from a path list filtered by $FENCED before
# any file was opened); both views, one line per case-view and binary.  Refuses a fenced line (fail-closed).
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "controls_list.sh: FENCED unset" >&2; exit 2; }
H=$(cd "$(dirname "$0")" && pwd); T=$(cd "$H/../.." && pwd)
P=$1; L=$2; O=$3; LST=$4
FR="\\b($(echo $FENCED | tr ' ' '|'))\\b"
grep -vP "$FR" "$LST" | sed 's#^\./##; s#/dut.sv$##' |
  while read -r d; do for v in d e; do echo "$d $v pristine $P"; echo "$d $v law $L"; done; done |
  xargs -P 3 -L 1 bash -c 'echo "$0 $1 $2 $(bash '"$H"'/case.sh '"$T"'/$0 $3 $1 5)"' | sort > $O
wc -l < $O

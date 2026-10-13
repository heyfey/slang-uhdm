# (r11u312: copied from r11u310repro/drivers, renamed to R11U312 / r11u312)
# (r11u310: copied from r11u308repro/drivers, renamed to R11U310 / r11u310)
# (r11u308: copied from r11u306repro/drivers, renamed to R11U308 / r11u308)
# (r11u308: copied from r11u304repro/drivers, renamed to R11U308 / r11u308)
# (r11u308: copied from r11u302repro/drivers, renamed to R11U308 / r11u308)
# (r11u308: copied from r11u300repro/drivers, renamed to R11U308 / r11u308)
# (r11u294: copied from r11u288repro/drivers)
#!/bin/bash
# (r11u286: copied from r11u284repro/drivers; R11U286_* switches, R11U286_TRACE)
# (r11u282: copied from r11u280repro/drivers)
# (r11u280: copied from r11u278repro/drivers)
# r11u280 awaygrid.sh <grid.txt | controls summary> <pristine bin> <law bin>: the chain-keyed away census
# (tools/probe/r11u272repro/drivers/awaychain.py, records of $SCX = strictcmp_x with the raw
# full name) on every mover (gridsum.py's MOVER lines of a grid, or the MOVER lines of a ctlsum.py
# summary): golden, pristine and law databases of the case-view.
# One line per mover (r11u282: CB=<dir> resolves the case paths from another root).  Needs $FENCED (fail-closed), $SCX, $S (record cache).
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "awaygrid.sh: FENCED unset" >&2; exit 2; }
[ -x "$SCX" ] && [ -n "$S" ] || { echo "awaygrid.sh: SCX/S unset" >&2; exit 2; }
G=$1; P=$2; L=$3; HERE=$(cd "$(dirname "$0")" && pwd); REPO=$(cd "$HERE/../../../.." && pwd)
AW=$HERE/awaychain.py  # r11u286: this pass's copy (from r11u287repro)
T=$S/awaygrid; mkdir -p $T
{ if grep -q '^MOVER' $G; then cat $G; else python3 $HERE/gridsum.py $G; fi; } | grep '^MOVER' | while read -r _ c v _; do
  v=${v%:}; d=${CB:-$HERE/../cases}/$c  # r11u282: CB=<tools/probe> for the control movers
  rm -f $T/p.uhdm $T/l.uhdm
  KEEP=$T/p.uhdm $HERE/case.sh $d $P $v > /dev/null; KEEP=$T/l.uhdm $HERE/case.sh $d $L $v > /dev/null
  h=$( (cd $d && find . -maxdepth 1 -type f \( -name '*.sv' -o -name '*.svh' -o -name '*.v' \) | sort | xargs cat) | md5sum | cut -c1-16)$v
  g=${R312_GOLD:-/tmp/r11u312_gold}/$h/g.uhdm
  echo "$c $v $(python3 $AW $g $T/p.uhdm $T/l.uhdm | head -1)"
done

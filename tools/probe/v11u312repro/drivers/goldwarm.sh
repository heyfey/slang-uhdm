#!/bin/bash
# v11u312 goldwarm.sh <case dir>...: build each case-view's Surelog golden into the case.sh cache (both views),
# with case.sh's key and arguments.  Fail-closed on $FENCED.
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "goldwarm: FENCED unset" >&2; exit 2; }
[ -x "$SURELOG" ] || { echo "goldwarm: SURELOG" >&2; exit 2; }
G=${R312_GOLD:-/tmp/v11u312_gold}
for d0 in "$@"; do d=$(realpath "$d0"); [ -f "$d/dut.sv" ] || continue
  for n in $FENCED; do echo "$d" | grep -qw "$n" && { echo "fenced path refused" >&2; exit 2; }; done
  for v in d e; do
    h=$( (cd $d && find . -maxdepth 1 -type f \( -name '*.sv' -o -name '*.svh' -o -name '*.v' \) | sort | xargs cat) | md5sum | cut -c1-16)$v
    gd=$G/$h; [ -s $gd/g.uhdm ] && continue
    t=$gd.tmp.$$; rm -rf $t; mkdir -p $t/o; ex=""; [ $v = e ] && ex="-elabuhdm"
    (cd $d && $SURELOG -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 $ex -o $t/o >/dev/null 2>&1 </dev/null)
    f=$(find $t/o -name '*.uhdm' | head -1); [ -n "$f" ] && cp $f $t/g.uhdm
    if [ -s $t/g.uhdm ]; then mkdir -p $gd; mv $t/g.uhdm $gd/g.uhdm.$$ && mv $gd/g.uhdm.$$ $gd/g.uhdm; fi
    rm -rf $t
  done
done

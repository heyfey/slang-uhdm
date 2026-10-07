#!/bin/bash
# v11u280 recdiff.sh <case dir> <view> <P> <L>: the raw strictcmp_x records ($SCX) that differ between the pristine
# and the law database of one case-view, each marked IN_GOLDEN / NOT_IN_GOLDEN (used on the movers whose away
# census read toward 0 away 0).  Fresh case dirs only; fail-closed on $FENCED.
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "recdiff.sh: FENCED unset" >&2; exit 2; }
for n in $FENCED; do echo "$1" | grep -qw "$n" && { echo "recdiff.sh: fenced path refused" >&2; exit 2; }; done
[ -x "$SCX" ] || { echo "recdiff.sh: SCX not executable" >&2; exit 2; }

d=$(realpath $1); v=$2; P=$3; L=$4; T=${V280_OUT:-/tmp/v11u280_caseout}/rd_$$; mkdir -p $T
C=$(dirname $(realpath $0))/case.sh
KEEP=$T/p.uhdm $C $d $P $v >/dev/null; KEEP=$T/l.uhdm $C $d $L $v >/dev/null
h=$( (cd $d && find . -maxdepth 1 -type f \( -name '*.sv' -o -name '*.svh' -o -name '*.v' \) | sort | xargs cat) | md5sum | cut -c1-16)$v
g=${V280_GOLD:-/tmp/v11u280_gold}/$h/g.uhdm
for x in p l; do $SCX --max 0 --dump-a $T/$x.rec --dump-b /dev/null $T/$x.uhdm $T/$x.uhdm >/dev/null 2>&1; done
$SCX --max 0 --dump-a $T/g.rec --dump-b /dev/null $g $g >/dev/null 2>&1
cut -f1-14 $T/p.rec > $T/p.c; cut -f1-14 $T/l.rec > $T/l.c; cut -f1-14 $T/g.rec > $T/g.c
diff $T/p.c $T/l.c | head -${N:-40}
echo "--- golden lines matching law-only records:"
diff $T/p.c $T/l.c | grep '^>' | cut -c3- | while IFS= read -r line; do grep -qxF "$line" $T/g.c && echo "IN_GOLDEN: $line" || echo "NOT_IN_GOLDEN: $line"; done | head -${N:-40}
echo "--- golden lines matching pristine-only records:"
diff $T/p.c $T/l.c | grep '^<' | cut -c3- | while IFS= read -r line; do grep -qxF "$line" $T/g.c && echo "IN_GOLDEN: $line" || echo "NOT_IN_GOLDEN: $line"; done | head -${N:-40}
[ -n "$KEEPDIR" ] && cp $T/*.c $KEEPDIR/
rm -rf $T

#!/bin/bash
# (r11u269: copied from r11u267repro/drivers)
# (r11u267: copied from r11u265repro/drivers)
# (r11u265: copied from r11u263repro/drivers)
# (r11u263: copied from r11u261repro/drivers)
# (r11u261: copied from r11u259repro/drivers)
# r11u261 rowhead.sh <row dir> [max]: the strict records of one sweep row-mode directory (<workdir>/<mode>/<Test>-<h>),
# golden read from its cmds.txt cache line. Fail-closed on $FENCED; a fenced row dir is refused.
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "rowhead.sh: FENCED unset" >&2; exit 2; }
[ -x "$STRICT_CMP" ] || { echo "rowhead.sh: STRICT_CMP not executable" >&2; exit 2; }
d=$1; m=${2:-20}
for n in $FENCED; do echo "$d" | grep -qw "$n" && { echo "rowhead.sh: fenced row refused" >&2; exit 2; }; done
g=$(grep -o 'golden cache hit [^)]*' $d/cmds.txt | sed 's/golden cache hit //'); g=$(ls $g/*.uhdm 2>/dev/null | head -1)
[ -s "$g" ] || { echo "rowhead.sh: no golden for $d" >&2; exit 2; }
$STRICT_CMP --max $m --dump-a $d/a.rec --dump-b $d/b.rec $g $d/slang.uhdm

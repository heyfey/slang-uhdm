#!/bin/bash
# (r11u227: copied from r11u224repro/drivers)
# dumpdelta.sh <case-view dir under $S/g> <tagA> <tagB>: the uhdm-dump lines (path-normalised, ids dropped) that differ
# between two binaries' databases, scored against golden's dump as MULTISETS: per line, toward = the gain in
# min(count, golden count) from A to B, away = its loss (r11u224; a line A holds more often than golden and B holds
# exactly golden's count reads toward, never away; the weaklyReferenced tail, unreachable to the judge, is cut). Fence: $S/g holds only case goldens (never a corpus database).
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
d=$1; a=$2; b=$3
for n in $FENCED; do echo "$d" | grep -qw "$n" && { echo "fenced path refused" >&2; exit 2; }; done
g=$(ls $d/gold_*/golden.uhdm | head -1)
norm() { "$UHDM_DUMP" "$1" 2>/dev/null | sed 1d | awk '/weaklyReferenced:$/{exit} {print}' | sed 's/id:[0-9]*//g; s#file:[^,]*/##'; }
norm $g > $d/.g.s; norm $d/$a.uhdm > $d/.a.s; norm $d/$b.uhdm > $d/.b.s
python3 - "$d" <<'PY'
import sys, collections
d = sys.argv[1]
G, A, B = (collections.Counter(open(f'{d}/{x}').read().splitlines()) for x in ('.g.s', '.a.s', '.b.s'))
tw = aw = 0
for k in set(A) | set(B):
    if A[k] == B[k]: continue
    da = min(A[k], G[k]); db = min(B[k], G[k])
    if db > da: tw += db - da
    elif da > db: aw += da - db
print(f"{d} onlyA={sum((A-B).values())} onlyB={sum((B-A).values())} toward={tw} away={aw}")
PY

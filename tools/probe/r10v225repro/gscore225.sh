#!/bin/bash
# r10uvm225 — score a grid run's ARRAY_NET census against golden, arm by arm.
#
#   usage: bash gscore225.sh <griddir> [outprefix]
#
# Prints, per arm: MISSING (golden has the cell, we do not), EXTRA (we have it,
# golden does not) and DIFF (both have it, fields differ), then the totals.
# A cell is keyed on its vpiFullName; the FIELDS are what `anetcen225.py`
# records, which includes the inner element net's `vpiNetType` (r10v224 R-C).
set -u
G=${1:?griddir}
HERE=$(cd "$(dirname "$0")" && pwd)
tm=0; te=0; td=0; ts=0
for d in "$G"/*/; do
    n=$(basename "$d")
    [ -f "$d/golden.dump" ] || { echo "ARM $n  NO GOLDEN DUMP"; continue; }
    [ -f "$d/ours.dump" ]   || { echo "ARM $n  NO OURS DUMP";  continue; }
    python3 "$HERE/anetcen225.py" "$d/golden.dump" > "$d/anet.golden.txt"
    python3 "$HERE/anetcen225.py" "$d/ours.dump"   > "$d/anet.ours.txt"
    read -r m e f s < <(python3 - "$d/anet.golden.txt" "$d/anet.ours.txt" "$d/anet.score.txt" <<'PY'
import sys
def load(p):
    o = {}
    for ln in open(p):
        if not ln.startswith('CELL '):
            continue
        k, _, v = ln[5:].rstrip('\n').partition(' | ')
        o[k] = v
    return o
g = load(sys.argv[1]); o = load(sys.argv[2])
miss = sorted(set(g) - set(o)); extra = sorted(set(o) - set(g))
diff = sorted(k for k in set(g) & set(o) if g[k] != o[k])
same = sorted(k for k in set(g) & set(o) if g[k] == o[k])
with open(sys.argv[3], 'w') as fh:
    for k in miss:
        fh.write('MISSING %s\n  G %s\n' % (k, g[k]))
    for k in extra:
        fh.write('EXTRA   %s\n  O %s\n' % (k, o[k]))
    for k in diff:
        fh.write('DIFF    %s\n  G %s\n  O %s\n' % (k, g[k], o[k]))
    for k in same:
        fh.write('SAME    %s\n' % k)
print(len(miss), len(extra), len(diff), len(same))
PY
)
    echo "ARM $n  golden=$(( m + f + s ))  MISSING=$m EXTRA=$e DIFF=$f SAME=$s"
    tm=$((tm+m)); te=$((te+e)); td=$((td+f)); ts=$((ts+s))
done
echo "TOTAL  MISSING=$tm EXTRA=$te DIFF=$td SAME=$ts"

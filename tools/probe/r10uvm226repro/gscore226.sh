#!/bin/bash
# r10uvm226 — GOLDEN-vs-OURS per grid arm, on the PROCESS census.
# Positional (the way interface_inst::Compare reads the vector):
#   MISSING = a golden cell with no cell of ours at that position
#   EXTRA   = a cell of ours at a position golden does not fill
#   DIFF    = both present, payloads differ
#   SAME    = both present, payloads identical
#   usage: bash gscore226.sh <griddir> [armname]
set -u
D=$(cd "$(dirname "$0")" && pwd)
G=${1:?griddir}
ONLY=${2:-}
tot_m=0; tot_e=0; tot_d=0; tot_s=0
for a in "$G"/*/; do
    n=$(basename "$a")
    [ -n "$ONLY" ] && [ "$n" != "$ONLY" ] && continue
    [ -f "$a/golden.dump" ] || { echo "ARM $n  NO-GOLDEN-DUMP"; continue; }
    [ -f "$a/ours.dump" ]   || { echo "ARM $n  NO-OURS-DUMP";   continue; }
    python3 "$D/proccen226.py" "$a/golden.dump" | sort > "$a/g.proc"
    python3 "$D/proccen226.py" "$a/ours.dump"   | sort > "$a/o.proc"
    python3 - "$a/g.proc" "$a/o.proc" "$n" <<'PY'
import sys
def load(p):
    d = {}
    for line in open(p):
        if not line.startswith('CELL '):
            continue
        k, _, v = line[5:].partition(' | ')
        d[k.strip()] = v.strip()
    return d
g, o = load(sys.argv[1]), load(sys.argv[2])
miss = sorted(k for k in g if k not in o and g[k] != 'NO-PROCESS')
extra = sorted(k for k in o if k not in g and o[k] != 'NO-PROCESS')
diff = sorted(k for k in g if k in o and g[k] != o[k])
same = sorted(k for k in g if k in o and g[k] == o[k])
print('ARM %-16s MISSING %-4d EXTRA %-4d DIFF %-4d SAME %-4d' %
      (sys.argv[3], len(miss), len(extra), len(diff), len(same)))
for k in miss:
    print('   MISSING  %s' % k)
for k in extra:
    print('   EXTRA    %s' % k)
for k in diff:
    print('   DIFF     %s' % k)
print('TOTALS %d %d %d %d' % (len(miss), len(extra), len(diff), len(same)))
PY
done | tee /dev/stderr | awk '/^TOTALS/{m+=$2;e+=$3;d+=$4;s+=$5}
    END{printf "GSCORE  MISSING %d  EXTRA %d  DIFF %d  SAME %d\n", m, e, d, s}' \
    2>/dev/null

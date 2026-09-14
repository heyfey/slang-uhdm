#!/usr/bin/env bash
# Per-LINE directional census over a grid arm's normalized sorted dumps.
# ADDED lines (patched, not pristine): GOOD when golden has >= as many.
# REMOVED lines: GOOD when golden did not have them.  Every AWAY key printed.
#   usage: [G=<grid root>] dirline20.sh a1 a2 ...
set -u
G=${G:-$(cd "$(dirname "$0")" && pwd)}
T=$(mktemp -d /tmp/r11u20_dl.XXXXXX)
trap 'rm -rf "$T"' EXIT
for d in "$@"; do
  for f in gold pris pat; do
    [ -f "$G/$d/$f.dump" ] || continue 2
    sed 's#/tmp/[^ ,)]*##g; s/^ *//' "$G/$d/$f.dump" | sort > "$T/$f"
  done
  python3 - "$d" "$T" <<'PY'
import sys, collections
d, T = sys.argv[1], sys.argv[2]
def mc(p):
    c = collections.Counter()
    for l in open(p, errors='replace'): c[l.rstrip('\n')] += 1
    return c
g, p, q = mc(T+'/gold'), mc(T+'/pris'), mc(T+'/pat')
to = away = 0; away_l = []
for k in set(g) | set(p) | set(q):
    gp, gq = abs(g[k]-p[k]), abs(g[k]-q[k])
    if gq < gp: to += 1
    elif gq > gp: away += 1; away_l.append((k, g[k], p[k], q[k]))
print("%-6s LINEKEYS TO-GOLDEN=%d AWAY-GOLDEN=%d" % (d, to, away))
for k, a, b, c in away_l[:20]:
    print("   AWAY g=%d pris=%d pat=%d | %s" % (a, b, c, k[:120]))
PY
done

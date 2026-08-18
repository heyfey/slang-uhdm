#!/usr/bin/env bash
# r10buvm19repro/gridcen19.sh — the THREE-WAY grid table: golden / pristine /
# patched, one row per (foreach site, package VIEW), with verdicts
# CONVERTED / OVER-FIRE / MOVED-STILL-WRONG / residue / same.
#
# The census here reads the uhdm-dump TEXT (grid19.sv is 260 lines, so the
# tree walk is cheap and the dump keeps the DEF/ELAB listing split visible as
# the `|uhdmallPackages:` / `|uhdmtopPackages:` section headers).  The corpus
# census uses the C++ instrument (r10buvm19cen.cpp) instead.
#
# usage: gridcen19.sh <golden.uhdm> <pristine.uhdm> <patched.uhdm> [workdir]
set -u
D=$(cd "$(dirname "$0")" && pwd)
G=$1; P=$2; Q=${3:-}; W=${4:-/tmp/r10buvm19_grid}
mkdir -p "$W"
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
"$DUMP" "$G" > "$W/gold.dump" 2>/dev/null; python3 "$D/fecen19.py" "$W/gold.dump" "$W/gold.json" >/dev/null
"$DUMP" "$P" > "$W/pris.dump" 2>/dev/null; python3 "$D/fecen19.py" "$W/pris.dump" "$W/pris.json" >/dev/null
if [ -n "$Q" ]; then "$DUMP" "$Q" > "$W/pat.dump" 2>/dev/null; python3 "$D/fecen19.py" "$W/pat.dump" "$W/pat.json" >/dev/null; fi
W="$W" python3 - <<'PY'
import json, os
W = os.environ['W']
def load(p):
    p = os.path.join(W, p)
    if not os.path.exists(p): return None
    x = {}
    for v, fn, loc, kind, nm, ts, act in json.load(open(p)):
        x.setdefault((fn, loc), {})[v] = (kind, ts, act)
    return x
G, O, P = load('gold.json'), load('pris.json'), load('pat.json')
ks = sorted(set(G) | set(O), key=lambda k: (int(k[1].split(':')[1]), k[0]))
n = same = conv = over = res = msw = 0
for k in ks:
    for view in ('uhdmallPackages', 'uhdmtopPackages'):
        gv = G.get(k, {}).get(view); ov = O.get(k, {}).get(view)
        pv = P.get(k, {}).get(view) if P else None
        if not (gv or ov): continue
        n += 1
        if P is None:
            verdict = 'same' if gv == ov else 'DIFF'
        elif gv == ov == pv:      verdict = 'same';              same += 1
        elif gv != ov and gv == pv: verdict = 'CONVERTED';       conv += 1
        elif gv == ov and gv != pv: verdict = 'OVER-FIRE';       over += 1
        elif gv != ov and ov == pv: verdict = 'residue';         res  += 1
        else:                       verdict = 'MOVED-STILL-WRONG'; msw += 1
        print('%-18s %-46s %-12s %-11s G=%-34s O=%-34s P=%s'
              % (verdict, k[0], k[1], view[4:], str(gv), str(ov), str(pv)))
print('-- CELLS %d  same %d  CONVERTED %d  OVER-FIRE %d  MOVED-STILL-WRONG %d  residue %d'
      % (n, same, conv, over, msw, res))
PY

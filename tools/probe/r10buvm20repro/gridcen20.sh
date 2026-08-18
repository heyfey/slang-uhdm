#!/usr/bin/env bash
# r10buvm20repro/gridcen20.sh — THE THREE-WAY GRID: golden / pristine /
# patched, one row per subroutine typespec SITE (return / formal / local var /
# class property / BODY-LOCAL return variable), with verdicts CONVERTED /
# OVER-FIRE / MOVED-STILL-WRONG / residue / same.
#
# MEASUREMENT ONLY.  LHS is ALWAYS golden.
#
# usage: gridcen20.sh <arm.sv> <pristine-bin> <patched-bin> [workdir]
set -u
D=$(cd "$(dirname "$0")" && pwd)
ARM=$1; PRIS=$2; PAT=${3:-}; W=${4:-/tmp/r10buvm20_grid}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CEN=${CEN:-/tmp/r10buvm20_cen}
rm -rf "$W"; mkdir -p "$W/g" "$W/p" "$W/q"
cp "$ARM" "$W/g/a.sv"; cp "$ARM" "$W/p/a.sv"; cp "$ARM" "$W/q/a.sv"
( cd "$W/g" && "$SURELOG" a.sv -parse -d coveruhdm -nocache -createcache \
      -noprecompiledcache -nowritecache -mt 0 -mp 0 -o w >sl.log 2>&1 ) </dev/null
( cd "$W/p" && "$PRIS" a.sv -o p.uhdm >p.log 2>&1 ) </dev/null
"$CEN" "$W/g/w/slpp_all/surelog.uhdm" G > "$W/g.txt" 2>&1
"$CEN" "$W/p/p.uhdm" O > "$W/o.txt" 2>&1
if [ -n "$PAT" ]; then
  ( cd "$W/q" && "$PAT" a.sv -o q.uhdm >q.log 2>&1 ) </dev/null
  "$CEN" "$W/q/q.uhdm" P > "$W/p.txt" 2>&1
fi
W="$W" python3 - <<'PY'
import os, collections
W = os.environ['W']
def load(f):
    p = os.path.join(W, f)
    if not os.path.exists(p): return None
    d = collections.defaultdict(list)
    for line in open(p):
        if not line.startswith('TS '): continue
        a = line.rstrip('\n').split(' ', 3)
        d[a[2][4:]].append(a[3])
    return {k: sorted(v) for k, v in d.items()}
G, O, P = load('g.txt'), load('o.txt'), load('p.txt')
ks = sorted(set(G) | set(O) | set(P or {}))
n = same = conv = over = res = msw = 0
for k in ks:
    g, o, p = G.get(k), O.get(k), P.get(k) if P else None
    n += 1
    if P is None:      v = 'same' if g == o else 'DIFF'
    elif g == o == p:  v = 'same'; same += 1
    elif g != o and g == p: v = 'CONVERTED'; conv += 1
    elif g == o and g != p: v = 'OVER-FIRE'; over += 1
    elif g != o and o == p: v = 'residue'; res += 1
    else:              v = 'MOVED-STILL-WRONG'; msw += 1
    if v == 'same': continue
    print('%-18s %s\n    G=%s\n    O=%s\n    P=%s' % (v, k, g, o, p))
print('-- CELLS %d  same %d  CONVERTED %d  OVER-FIRE %d  MOVED-STILL-WRONG %d  residue %d'
      % (n, same, conv, over, msw, res))
PY

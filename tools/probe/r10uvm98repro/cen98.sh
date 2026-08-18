#!/usr/bin/env bash
# r10uvm98 — MEASUREMENT ONLY.  Three-way class-typespec BIND census over a
# pair of verify_golden workdirs: golden (read out of each workdir's OWN
# cmds.txt, so the wrong golden can never be compared) vs PRISTINE vs PATCHED.
# LHS is ALWAYS golden.
#   ./cen98.sh <pristine wd> <patched wd> [name-regex]
set -u
B=${1:?pristine wd}; A=${2:?patched wd}; PAT=${3:-}
CEN=${CEN:-/tmp/r10uvm98_ct98cen}
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib:${LD_LIBRARY_PATH:-}
T=$(mktemp -d)
for d in "$B"/*/*/; do
  mode=$(basename "$(dirname "$d")"); test=$(basename "$d")
  case "$test" in *$PAT*) ;; *) continue ;; esac
  O="$d/slang.uhdm"; C="$d/cmds.txt"; Q="$A/$mode/$test/slang.uhdm"
  [ -f "$O" ] && [ -f "$C" ] && [ -f "$Q" ] || continue
  G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
  [ -n "$G" ] && [ -d "$G" ] || continue
  "$CEN" "$G/golden.uhdm" > "$T/g" 2>/dev/null
  "$CEN" "$O"             > "$T/p" 2>/dev/null
  "$CEN" "$Q"             > "$T/q" 2>/dev/null
  python3 - "$mode/$test" "$T/g" "$T/p" "$T/q" <<'PY'
import sys, collections
tag, gp, pp, qp = sys.argv[1:5]
def load(p, idx):
    m = collections.defaultdict(set)
    for line in open(p):
        c = line.rstrip('\n').split('\t')
        if len(c) != 6: continue
        m[(c[0], c[1])].add((c[2], c[3], c[4], c[5])[idx] if idx >= 0
                            else (c[2], c[3], c[4], c[5]))
    return m
out = []
for name, idx in (('DEFN', 1), ('ALL', -1)):
    G, P, Q = load(gp, idx), load(pp, idx), load(qp, idx)
    both = set(G) & set(P) & set(Q)
    t = collections.Counter()
    for k in both:
        g, p, q = G[k], P[k], Q[k]
        if p == g and q == g: t['OK'] += 1
        elif p != g and q == g: t['TO'] += 1
        elif p == g and q != g: t['AWAY'] += 1
        elif p != q: t['CHANGED-STILL'] += 1
        else: t['STILL'] += 1
    out.append('%-6s cells %5d OK %5d TO-GOLDEN %3d AWAY-GOLDEN %3d CHANGED-STILL %3d STILL %4d'
               % (name, len(both), t['OK'], t['TO'], t['AWAY'], t['CHANGED-STILL'], t['STILL']))
print('%-34s %s' % (tag, out[0]))
print('%-34s %s' % ('', out[1]))
PY
done
rm -rf "$T"

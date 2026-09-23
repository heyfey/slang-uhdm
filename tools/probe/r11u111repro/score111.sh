#!/bin/bash
# score111.sh <out-root> <tagA> <tagB>: per arm (every <arm>/gold.uhdm under out-root with both tags),
# (1) the cen111 per-face multiset distance to golden for A and B, (2) the CONTEXT-KEYED whole-dump
# distance (ctxdist111.py: ids + the arm path stripped, each line keyed by its owning header chain),
# (3) cmp lines/heads.  Prints only arms whose A and B bytes differ.  Verdict per arm:
# TO-GOLDEN (no face and no whole-dump distance grows, one shrinks), AWAY (any grows), LATERAL.
O=${1:?}; A=${2:?}; B=${3:?}; CEN=${CEN:-/tmp/r11u111_tools/cen111}; D=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
for g in $(find "$O" -name gold.uhdm | sort); do
  w=$(dirname "$g"); [ -f "$w/$A.uhdm" ] && [ -f "$w/$B.uhdm" ] || continue
  cmp -s "$w/$A.uhdm" "$w/$B.uhdm" && continue
  for t in gold $A $B; do
    [ -f "$w/$t.cen" ] || "$CEN" "$w/$t.uhdm" 2>/dev/null | sort > "$w/$t.cen"
    [ -f "$w/$t.dump" ] || timeout 600 "$D" "$w/$t.uhdm" 2>/dev/null | sed -E 's#'"$w"'##g' > "$w/$t.dump"
  done
  ctx=$(python3 "$(dirname "$0")/ctxdist111.py" "$w/gold.dump" "$w/$A.dump" "$w/$B.dump" 0 | tr '\n' ' ')
  python3 - "$w" "$A" "$B" "$ctx" <<'PY'
import sys, collections
w, a, b, ctx = sys.argv[1:5]
def ms(p): return collections.Counter(l.rstrip('\n') for l in open(p, errors='replace'))
def dist(x, y): return sum(((x - y) + (y - x)).values())
def face(c, f): return collections.Counter({k: v for k, v in c.items() if k.startswith(f)})
g, A, B = ms(f'{w}/gold.cen'), ms(f'{w}/{a}.cen'), ms(f'{w}/{b}.cen')
out, grow, shrink = [], False, False
for f in ('F1', 'F2', 'F3', 'F5', 'F6'):
    da, db = dist(face(g, f), face(A, f)), dist(face(g, f), face(B, f))
    if da != db:
        out.append(f'{f}:{da}->{db}'); grow |= db > da; shrink |= db < da
cw = ctx.split(); wa, wb, awayk = int(cw[1]), int(cw[2]), int(cw[-1])
grow |= wb > wa or awayk > 0; shrink |= wb < wa
def cmpc(t):
    try:
        L = open(f'{w}/{t}.cmp').read().splitlines(); return f'{len(L)}/{sum(1 for l in L if l.startswith("LHS:"))}'
    except Exception: return 'NA'
v = 'AWAY' if grow and not shrink else ('MIXED' if grow else ('TO-GOLDEN' if shrink else 'LATERAL'))
print(f'{w} cmp {cmpc(a)}->{cmpc(b)} ctxwhole {wa}->{wb} awaykeys={awayk} {" ".join(out)} {v}')
PY
done

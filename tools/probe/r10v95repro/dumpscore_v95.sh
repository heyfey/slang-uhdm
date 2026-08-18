#!/usr/bin/env bash
# r10v95 WHOLE-DUMP three-way mover scorer — MEASUREMENT ONLY.
# For an arm workdir built by three_v95.sh (golden slpp_all/surelog.uhdm +
# pris.uhdm + pat.uhdm), normalises every uhdm-dump line (object ids, absolute
# paths, work@ prefixes) and scores the PATCHED database against GOLDEN
# relative to PRISTINE, as line MULTISETS:
#   TO_GOLDEN  a normalised line-instance pristine got wrong and patched gets right
#   AWAY       a line-instance pristine got right and patched gets wrong   <- must be 0
#   dG(pris)   |pris symmetric-difference golden|   dG(pat)  |pat sym-diff golden|
set -u
D=${1:?armwd}
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib:${LD_LIBRARY_PATH:-}
norm() { sed -e 's/, id:[0-9]*//g' -e 's#/[A-Za-z0-9_./-]*/\([A-Za-z0-9_]*\.sv\)#\1#g' \
             -e 's/\bwork@//g' -e 's/^ *//' | sort ; }
for t in g pris pat; do
  case $t in g) f=$D/slpp_all/surelog.uhdm;; *) f=$D/$t.uhdm;; esac
  [ -f "$f" ] || { echo "$D MISSING $t"; exit 4; }
  "$DUMP" "$f" 2>/dev/null </dev/null | sed 1d | norm > "$D/$t.ndump"
done
python3 - "$D" <<'PY'
import sys, collections
d = sys.argv[1]
def ms(p):
    c = collections.Counter()
    for l in open(p):
        c[l.rstrip('\n')] += 1
    return c
G, P, Q = ms(d+'/g.ndump'), ms(d+'/pris.ndump'), ms(d+'/pat.ndump')
def sym(a, b):
    keys = set(a) | set(b)
    return sum(abs(a[k]-b[k]) for k in keys)
# per-line-instance movement
to_g = away = 0
for k in set(G) | set(P) | set(Q):
    dp, dq = abs(G[k]-P[k]), abs(G[k]-Q[k])
    if dq < dp: to_g += dp-dq
    elif dq > dp: away += dq-dp
print("%-46s dG(pris)=%-6d dG(pat)=%-6d TO_GOLDEN=%-5d AWAY=%d" % (
    d.split('/')[-1], sym(G,P), sym(G,Q), to_g, away))
PY

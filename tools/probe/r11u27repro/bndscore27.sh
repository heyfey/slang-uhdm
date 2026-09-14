#!/usr/bin/env bash
# r11u27: score every boundary mover CELL BY CELL against the REAL v1.87
# golden, MULTISET-AWARE (the same Lhs name at the same line recurs once per
# INSTANCE, so a list compare would read one instance's move as a whole-key
# move — the multiset trap).  Per (Lhs kind, name, line:col) key the score is
#   hits = how many of our cell objects are in GOLDEN's multiset for that key
#   TO-GOLDEN   hits(law) > hits(pris)
#   AWAY-GOLDEN hits(law) < hits(pris)     <- the class that must be ZERO
#   STILL-WRONG a cell wrong under BOTH binaries
# The OFFICIAL `uhdm-cmp` against the same golden (bndattr27.sh) is the
# whole-database arbiter beside it.
set -u
OUT=${OUT:-/tmp/r11u27_bndattr}
DUMP=${DUMP:-/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump}
CARHS=${CARHS:-/tmp/r11u27_carhs.py}
for d in $OUT/*/; do
  d=${d%/}
  [ -f $d/pris.uhdm ] && [ -f $d/law.uhdm ] || continue
  g=$d/slpp_all/surelog.uhdm; [ -f "$g" ] || { echo "$(basename $d) NOGOLD"; continue; }
  [ -f $d/g.cells ] || { $DUMP "$g" 2>/dev/null > $d/g.dump; python3 $CARHS $d/g.dump > $d/g.cells 2>/dev/null; }
  [ -f $d/p.cells ] || { $DUMP $d/pris.uhdm 2>/dev/null > $d/p.dump; python3 $CARHS $d/p.dump > $d/p.cells 2>/dev/null; }
  [ -f $d/l.cells ] || { $DUMP $d/law.uhdm 2>/dev/null > $d/l.dump; python3 $CARHS $d/l.dump > $d/l.cells 2>/dev/null; }
  python3 - "$d" <<'PY'
import sys,os,collections
d=sys.argv[1]
def load(f):
    m=collections.defaultdict(collections.Counter)
    for l in open(os.path.join(d,f),errors='replace'):
        t=' '.join(l.split())
        if not t: continue
        m[' '.join(t.split()[:3])][t]+=1
    return m
G,P,L=load('g.cells'),load('p.cells'),load('l.cells')
def hits(C,k):
    return sum(min(n,G[k][o]) for o,n in C[k].items())
to=aw=sw=same=tot=0
for k in sorted(set(G)|set(P)|set(L)):
    n=max(sum(P[k].values()),sum(L[k].values())); tot+=n
    hp,hl=hits(P,k),hits(L,k)
    if hl>hp: to+=hl-hp
    elif hl<hp: aw+=hp-hl
    if P[k]!=L[k] and hl==hp: sw+=1
print("%-50s CAcells=%d TO-GOLDEN=%d AWAY-GOLDEN=%d STILL-WRONG-CHANGED=%d"
      % (os.path.basename(d)[-46:], tot, to, aw, sw))
PY
done

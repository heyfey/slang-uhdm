#!/bin/bash
# r10v110 — three-way arm runner + VIEW-GENERAL order-blind whole-dump scorer.
# MEASUREMENT ONLY; the official uhdm-cmp verdict is printed too.
#   $1 = arm .sv (relative to this dir), rest = extra sources
# env: PRIS, SHIP (absolute, frozen binaries), SU (golden surelog)
set -u
ROOT=$(cd "$(dirname "$0")" && pwd)
SU=${SU:-$HOME/git-repos/Surelog/build/bin/surelog}
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
ARM=$1; shift
BASE=$(echo "$ARM" | sed 's#[/.]#_#g')
SRCS="$ARM $*"
for view in def elab; do
  W=$ROOT/vrun/$BASE.$view
  rm -rf "$W"; mkdir -p "$W"
  if [ "$view" = elab ]; then SUF="-elabuhdm"; SLF="--elabuhdm"; else SUF=""; SLF=""; fi
  ( cd "$ROOT" && $SU -parse $SUF $SRCS -mt 0 -mp 0 -o "$W" > "$W/su.log" 2>&1 ) </dev/null; surc=$?
  G=$(find "$W" -name 'surelog.uhdm' | head -1)
  [ -n "$G" ] && cp "$G" "$W/golden.uhdm"
  ( cd "$ROOT" && $PRIS $SRCS --single-unit $SLF -o "$W/pris.uhdm" > "$W/pris.log" 2>&1 ) </dev/null; prc=$?
  ( cd "$ROOT" && $SHIP $SRCS --single-unit $SLF -o "$W/ship.uhdm" > "$W/ship.log" 2>&1 ) </dev/null; src=$?
  echo "RC $BASE.$view surelog=$surc pris=$prc ship=$src golden=${G:-NONE}"
  [ -e "$W/golden.uhdm" ] || { echo "  NO GOLDEN"; continue; }
  for w in golden pris ship; do
    [ -e "$W/$w.uhdm" ] || continue
    $DUMP "$W/$w.uhdm" 2>/dev/null | sed -e "s#$W/##g" -e "s#$ROOT/##g" -e 's#/tmp/wt_v110[a-z]*/##g' \
      | sort > "$W/$w.norm"
  done
  pcl=$($CMP "$W/golden.uhdm" "$W/pris.uhdm" 2>&1 | grep -c . ; true)
  scl=$($CMP "$W/golden.uhdm" "$W/ship.uhdm" 2>&1 | grep -c . ; true)
  echo "  CMPLINES golden-vs-pris=$pcl golden-vs-ship=$scl"
  python3 - "$W" "$BASE.$view" <<'PY'
import sys, collections
W,tag=sys.argv[1],sys.argv[2]
def mc(p):
    try: return collections.Counter(open(p,errors='replace').read().splitlines())
    except IOError: return None
g,p,s=mc(W+'/golden.norm'),mc(W+'/pris.norm'),mc(W+'/ship.norm')
if None in (g,p,s): print('  DIFF-SKIP'); raise SystemExit
def dd(a,b):
    o=collections.Counter()
    for k,v in a.items():
        d=v-b.get(k,0)
        if d>0: o[k]=d
    return o
gp,pg=dd(g,p),dd(p,g)      # golden-only vs pris, pris-only
gs,sg=dd(g,s),dd(s,g)
print('  ORDERBLIND golden_only_vs_pris=%d pris_only=%d | golden_only_vs_ship=%d ship_only=%d'
      %(sum(gp.values()),sum(pg.values()),sum(gs.values()),sum(sg.values())))
# AWAY evidence: a line golden and pristine AGREED on that shipped lost,
# or a line shipped invented that pristine did not have and golden lacks.
lost=dd(collections.Counter({k:min(g[k],p.get(k,0)) for k in g}), s)
new =dd(sg, pg)
lost={k:v for k,v in lost.items() if v>0}
if lost: 
    print('  AWAY-LOST %d'%sum(lost.values()))
    for k,v in sorted(lost.items())[:40]: print('    -%d %s'%(v,k))
if new:
    print('  AWAY-NEW %d'%sum(new.values()))
    for k,v in sorted(new.items())[:40]: print('    +%d %s'%(v,k))
if not lost and not new: print('  AWAY-NONE')
PY
done

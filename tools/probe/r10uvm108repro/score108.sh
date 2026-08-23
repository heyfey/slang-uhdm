#!/bin/bash
# score108.sh <arm.sv> : run108 with SHIP, then score EVERY event-control cell
# three ways (golden / pristine / shipped) in BOTH views.  MEASUREMENT ONLY.
#   TO_GOLDEN  pristine != golden, shipped == golden
#   AWAY       pristine == golden, shipped != golden      (a regression)
#   LATERAL    both wrong, differently
#   STILL      both wrong, identically
set -u
ROOT=${ROOT:-$(cd "$(dirname "$0")" && pwd)}
CEN=${CEN:-$ROOT/cen108.py}
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
ARM=$1; shift
BASE=$(echo "$ARM" | sed 's#[/.]#_#g')
PRIS=${PRIS:?} SHIP=${SHIP:?} bash "$ROOT/run108.sh" "$ARM" "$@"
for view in def elab; do
  W=$ROOT/run/$BASE.$view
  for w in golden pris ship; do
    [ -e "$W/$w.uhdm" ] || continue
    $DUMP "$W/$w.uhdm" > "$W/$w.dump" 2>/dev/null
    PROJ=1 python3 "$CEN" "$W/$w.dump" > "$W/$w.cen"
  done
  python3 - "$W" "$BASE.$view" <<'PY'
import sys, collections
W,tag=sys.argv[1],sys.argv[2]
def load(p):
    d=collections.defaultdict(list)
    try:
        for ln in open(p):
            a=ln.rstrip('\n').split('\t')
            if len(a)==3: d[(a[0],a[1])].append(a[2])
    except IOError: return None
    return d
g,p,s=load(W+'/golden.cen'),load(W+'/pris.cen'),load(W+'/ship.cen')
if g is None or p is None or s is None:
    print('%s SCORE-SKIP (missing dump)'%tag); raise SystemExit
c=collections.Counter()
for k in sorted(set(g)|set(p)|set(s)):
    gv,pv,sv=sorted(g.get(k,[])),sorted(p.get(k,[])),sorted(s.get(k,[]))
    if pv==gv and sv==gv: c['SAME']+=1
    elif pv!=gv and sv==gv: c['TO_GOLDEN']+=1; print('  TO_GOLDEN %s %s'%k)
    elif pv==gv and sv!=gv: c['AWAY']+=1; print('  AWAY      %s %s\n    G %s\n    S %s'%(k+(gv,sv)))
    elif pv==sv: c['STILL']+=1
    else: c['LATERAL']+=1; print('  LATERAL   %s %s\n    G %s\n    P %s\n    S %s'%(k+(gv,pv,sv)))
print('%s SAME=%d TO_GOLDEN=%d AWAY=%d LATERAL=%d STILL=%d'%(tag,c['SAME'],c['TO_GOLDEN'],c['AWAY'],c['LATERAL'],c['STILL']))
PY
done

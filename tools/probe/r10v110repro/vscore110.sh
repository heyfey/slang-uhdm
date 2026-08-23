#!/bin/bash
# r10v110 arm scorer: TO_GOLDEN / AWAY / LATERAL / STILL per assignment cell,
# both views, from the databases vrun110.sh already built.  LHS is ALWAYS golden.
set -u
ROOT=$(cd "$(dirname "$0")" && pwd)
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
BASE=$(echo "$1" | sed 's#[/.]#_#g')
for view in def elab; do
  W=$ROOT/vrun/$BASE.$view
  [ -e "$W/golden.uhdm" ] || { echo "$BASE.$view NOGOLDEN"; continue; }
  for w in golden pris ship; do
    [ -e "$W/$w.uhdm" ] && { $DUMP "$W/$w.uhdm" > "$W/$w.dmp" 2>/dev/null; python3 "$ROOT/vcen110.py" "$W/$w.dmp" > "$W/$w.vcen"; }
  done
  python3 - "$W" "$BASE.$view" <<'PY'
import sys,collections
W,tag=sys.argv[1],sys.argv[2]
def load(p):
    d=collections.defaultdict(list)
    try:
        for ln in open(p):
            a=ln.rstrip('\n').split('\t')
            if len(a)==3: d[(a[0],a[1])].append(a[2])
    except IOError: return None
    return d
g,p,s=load(W+'/golden.vcen'),load(W+'/pris.vcen'),load(W+'/ship.vcen')
if None in (g,p,s): print(tag,'SKIP'); raise SystemExit
c=collections.Counter()
for k in sorted(set(g)|set(p)|set(s)):
    gv,pv,sv=sorted(g.get(k,[])),sorted(p.get(k,[])),sorted(s.get(k,[]))
    if pv==gv and sv==gv: c['SAME']+=1
    elif pv!=gv and sv==gv: c['TO_GOLDEN']+=1; print('  TO_GOLDEN %s %s'%k)
    elif pv==gv and sv!=gv:
        c['AWAY']+=1; print('  *** AWAY *** %s %s\n     G %s\n     S %s'%(k+(gv,sv)))
    elif pv==sv: c['STILL']+=1
    else:
        c['LATERAL']+=1; print('  LATERAL %s %s\n     G %s\n     P %s\n     S %s'%(k+(gv,pv,sv)))
print('%s SAME=%d TO_GOLDEN=%d AWAY=%d LATERAL=%d STILL=%d'%(tag,c['SAME'],c['TO_GOLDEN'],c['AWAY'],c['LATERAL'],c['STILL']))
PY
done

#!/usr/bin/env bash
# r10earl59 BOUNDARY VERIFIER — for ONE arm .sv, run Surelog (LHS golden) and
# BOTH binaries, then attribute every moved DUMP LINE and every moved
# cont_assign BINDING three ways:
#     TO-GOLDEN    pristine wrong -> patched right
#     AWAY-GOLDEN  pristine RIGHT -> patched WRONG   <== the only fatal bucket
#     STILL-WRONG  both wrong, differently
# A boundary arm that MOVES is not a failure; a boundary arm that moves AWAY is.
#
#   usage: SLANG_PAT=… SLANG_PRIS=… varm59.sh <arm.sv> <view: plain|elab> [wd]
set -u
SELFDIR=$(cd "$(dirname "$0")" && pwd)   # captured BEFORE the cd below
SUR=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
SRC=${1:?arm source}; VIEW=${2:-elab}
: "${SLANG_PAT:?}"; : "${SLANG_PRIS:?}"
case $VIEW in plain) SF=""; GF="-parse";; elab) SF="--elabuhdm"; GF="-parse -elabuhdm";; esac
B=$(basename "$SRC"); B=${B%.*}
D=${3:-/tmp/r10earl59_varm/${B}_$VIEW}
rm -rf "$D"; mkdir -p "$D" || exit 9
cp "$SRC" "$D/" || exit 9
S=$(basename "$SRC")
cd "$D" || exit 9
$SUR $GF -nocache -mt 0 -mp 0 "$S" >surelog.log 2>&1
[ -f slpp_all/surelog.uhdm ] || { echo "$B/$VIEW SURELOG_FAIL"; exit 5; }
"$DUMP" slpp_all/surelog.uhdm 2>/dev/null | sed '1d' | sed "s#$D#WD#g" > g.dump
for side in pris pat; do
  case $side in pris) BIN=$SLANG_PRIS;; pat) BIN=$SLANG_PAT;; esac
  "$BIN" $SF "$S" -o $side.uhdm >$side.log 2>&1
  [ -f $side.uhdm ] || { echo "$B/$VIEW NO_OUTPUT($side)"; exit 6; }
  "$DUMP" $side.uhdm 2>/dev/null | sed '1d' | sed "s#$D#WD#g" > $side.dump
done
CENSUS_DIR=$SELFDIR python3 - "$B/$VIEW" <<'PYEOF'
import sys, collections
tag=sys.argv[1]
# INDENTATION-INSENSITIVE on purpose.  A leading-whitespace-sensitive multiset
# makes DEPTH part of the key, and these boundary arms carry PRE-EXISTING depth
# differences vs golden -- which made the first run of this verifier report
# AWAY-GOLDEN for a line whose plain COUNT went 6 -> 7 against golden's 7, i.e.
# a cell that moved exactly ONTO golden.  Verified by hand on
# v58v2_earl58/elab: `\_logic_net: (work@v2_earl58.o) 6:39` g=7 pris=6 pat=7 and
# `|vpiActual:` g=165 pris=162 pat=163.  The keyed census below is the exact
# instrument for the binding question; this multiset is the wide net.
def ms(p): return collections.Counter(l.strip() for l in open(p).read().split('\n'))
g,pr,pa=ms('g.dump'),ms('pris.dump'),ms('pat.dump')
to=away=still=0
rows=[]
for k in set(pr)|set(pa):
    d=pa[k]-pr[k]
    if d==0: continue
    # a line count moving toward golden's count is TO-GOLDEN, away is AWAY
    if abs(pa[k]-g[k]) < abs(pr[k]-g[k]): to+=abs(d); rows.append(('TO',k[:110]))
    elif abs(pa[k]-g[k]) > abs(pr[k]-g[k]): away+=abs(d); rows.append(('AWAY',k[:110]))
    else: still+=abs(d); rows.append(('STILL',k[:110]))
print('%-34s LINE-MOVERS TO-GOLDEN=%-4d AWAY-GOLDEN=%-4d STILL-WRONG=%-4d  (diff-vs-golden %d -> %d)'
      % (tag,to,away,still,
         sum(abs(pr[k]-g[k]) for k in set(g)|set(pr)),
         sum(abs(pa[k]-g[k]) for k in set(g)|set(pa))))
for t,k in rows[:8]:
    if t=='AWAY': print('    AWAY-LINE: %s'%k)
# EXACT: the keyed cont_assign binding census, calibrated gold-vs-gold elsewhere
import importlib.util
# VERIFIER FIX: this line named the IMPLEMENTER'S OWN WORKTREE
# (/tmp/wt_r10earl59/...), so the shipped instrument could not run from a
# fresh checkout of this patch -- it would ImportError on any other machine
# or after that worktree was pruned.  Resolve next to THIS script instead.
import os
spec=importlib.util.spec_from_file_location('c',os.path.join(os.environ['CENSUS_DIR'],'census59.py'))
mm=importlib.util.module_from_spec(spec); spec.loader.exec_module(mm)
G,P,Q=mm.scan('g.dump'),mm.scan('pris.dump'),mm.scan('pat.dump')
t2=collections.Counter(); det=[]
for k in set(G)|set(P)|set(Q):
    gv,pv,qv=G.get(k,'NO'),P.get(k,'NO'),Q.get(k,'NO')
    if pv==qv: continue
    tg='TO-GOLDEN' if qv==gv else ('AWAY-GOLDEN' if pv==gv else 'STILL-WRONG')
    t2[tg]+=1
    if tg!='TO-GOLDEN': det.append((tg,k,gv,pv,qv))
print('%-34s BIND-CELLS  TO-GOLDEN=%-4d AWAY-GOLDEN=%-4d STILL-WRONG=%-4d'
      % (tag,t2['TO-GOLDEN'],t2['AWAY-GOLDEN'],t2['STILL-WRONG']))
for d in det[:8]: print('    %s %s G=%s P=%s Q=%s'%d)
PYEOF

#!/usr/bin/env bash
# verifier arm runner: golden(Surelog) vs pristine vs patched, whole-dump line
# multiset + keyed param_assign census. LHS is ALWAYS golden.
set -u
SUR=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
PACENSUS=${PACENSUS:-/tmp/v60_s/pacensus60}
SELFDIR=$(cd "$(dirname "$0")" && pwd)
SRC=${1:?arm}; VIEW=${2:-elab}
: "${SLANG_PAT:?}"; : "${SLANG_PRIS:?}"
case $VIEW in plain) SF=""; GF="-parse";; elab) SF="--elabuhdm"; GF="-parse -elabuhdm";; esac
B=$(basename "$SRC"); B=${B%.*}
D=${3:-/tmp/v60_run/${B}_$VIEW}
rm -rf "$D"; mkdir -p "$D" || exit 9
cp "$SRC" "$D/" || exit 9
S=$(basename "$SRC")
cd "$D" || exit 9
$SUR $GF -nocache -mt 0 -mp 0 "$S" >surelog.log 2>&1
[ -f slpp_all/surelog.uhdm ] || { echo "$B/$VIEW SURELOG_FAIL"; exit 5; }
"$DUMP" slpp_all/surelog.uhdm 2>/dev/null | sed '1d' | sed "s#$D#WD#g" > g.dump
for side in pris pat; do
  case $side in pris) BIN=$SLANG_PRIS;; pat) BIN=$SLANG_PAT;; esac
  "$BIN" $SF "$S" -o $side.uhdm >$side.log 2>&1; rc=$?
  [ -f $side.uhdm ] || { echo "$B/$VIEW NO_OUTPUT($side) rc=$rc"; sed -n '1,10p' $side.log; exit 6; }
  "$DUMP" $side.uhdm 2>/dev/null | sed '1d' | sed "s#$D#WD#g" > $side.dump
done
python3 - "$B/$VIEW" <<'PYEOF'
import sys, collections
tag=sys.argv[1]
def ms(p): return collections.Counter(l.strip() for l in open(p).read().split('\n'))
g,pr,pa=ms('g.dump'),ms('pris.dump'),ms('pat.dump')
to=away=still=0; rows=[]
for k in set(pr)|set(pa):
    d=pa[k]-pr[k]
    if d==0: continue
    if abs(pa[k]-g[k]) < abs(pr[k]-g[k]): to+=abs(d); rows.append(('TO',k[:130]))
    elif abs(pa[k]-g[k]) > abs(pr[k]-g[k]): away+=abs(d); rows.append(('AWAY',k[:130]))
    else: still+=abs(d); rows.append(('STILL',k[:130]))
print('%-30s LINE TO=%-4d AWAY=%-4d STILL=%-4d  (dist %d -> %d)'
      % (tag,to,away,still,
         sum(abs(pr[k]-g[k]) for k in set(g)|set(pr)),
         sum(abs(pa[k]-g[k]) for k in set(g)|set(pa))))
for t,k in rows[:12]:
    if t!='TO': print('    %s-LINE: %s'%(t,k))
PYEOF
if [ -x "$PACENSUS" ]; then
  "$PACENSUS" slpp_all/surelog.uhdm g.pa >/dev/null 2>&1
  "$PACENSUS" pris.uhdm pris.pa >/dev/null 2>&1
  "$PACENSUS" pat.uhdm pat.pa  >/dev/null 2>&1
  echo -n "  keyed pa census: "
  python3 $SELFDIR/attrv60.py g.pa pris.pa pat.pa 2>/dev/null | head -30
fi

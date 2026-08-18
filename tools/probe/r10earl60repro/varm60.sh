#!/usr/bin/env bash
# r10earl60 BOUNDARY VERIFIER — for ONE arm .sv, run Surelog (LHS golden) and
# BOTH binaries, then attribute the move three ways, on TWO instruments:
#   (a) the whole-dump line MULTISET (the wide net), and
#   (b) the EXACT keyed param_assign census (pacensus60 + attr60.py), which is
#       the slot this pass's law touches.
#     TO-GOLDEN    pristine wrong -> patched right
#     AWAY-GOLDEN  pristine RIGHT -> patched WRONG   <== the only fatal bucket
#     STILL-WRONG  both wrong, differently
# A boundary arm that MOVES is not a failure; a boundary arm that moves AWAY is.
#
#   usage: SLANG_PAT=… SLANG_PRIS=… varm60.sh <arm.sv> <view: plain|elab> [wd]
#
# The line multiset is INDENTATION-INSENSITIVE on purpose: raw leading
# whitespace makes TREE DEPTH part of the key, and boundary arms carry
# PRE-EXISTING depth differences vs golden -- that is what made r10earl59's
# first verifier report AWAY-GOLDEN for a line whose count moved exactly ONTO
# golden's.
set -u
SELFDIR=$(cd "$(dirname "$0")" && pwd)
SUR=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
PACENSUS=${PACENSUS:-/tmp/r10earl60_s/pacensus60}
SRC=${1:?arm source}; VIEW=${2:-elab}
: "${SLANG_PAT:?}"; : "${SLANG_PRIS:?}"
case $VIEW in plain) SF=""; GF="-parse";; elab) SF="--elabuhdm"; GF="-parse -elabuhdm";; esac
B=$(basename "$SRC"); B=${B%.*}
D=${3:-/tmp/r10earl60_varm/${B}_$VIEW}
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
python3 - "$B/$VIEW" <<'PYEOF'
import sys, collections
tag=sys.argv[1]
def ms(p): return collections.Counter(l.strip() for l in open(p).read().split('\n'))
g,pr,pa=ms('g.dump'),ms('pris.dump'),ms('pat.dump')
to=away=still=0; rows=[]
for k in set(pr)|set(pa):
    d=pa[k]-pr[k]
    if d==0: continue
    if abs(pa[k]-g[k]) < abs(pr[k]-g[k]): to+=abs(d); rows.append(('TO',k[:110]))
    elif abs(pa[k]-g[k]) > abs(pr[k]-g[k]): away+=abs(d); rows.append(('AWAY',k[:110]))
    else: still+=abs(d); rows.append(('STILL',k[:110]))
print('%-34s LINE-MOVERS TO=%-4d AWAY=%-4d STILL=%-4d  (dist-to-golden %d -> %d)'
      % (tag,to,away,still,
         sum(abs(pr[k]-g[k]) for k in set(g)|set(pr)),
         sum(abs(pa[k]-g[k]) for k in set(g)|set(pa))))
for t,k in rows[:8]:
    if t=='AWAY': print('    AWAY-LINE: %s'%k)
PYEOF
if [ -x "$PACENSUS" ]; then
  "$PACENSUS" slpp_all/surelog.uhdm g.pa >/dev/null 2>&1
  "$PACENSUS" pris.uhdm pris.pa >/dev/null 2>&1
  "$PACENSUS" pat.uhdm pat.pa  >/dev/null 2>&1
  echo -n "  keyed param_assign census: "
  python3 "$SELFDIR/attr60.py" g.pa pris.pa pat.pa 2>/dev/null | head -1
fi

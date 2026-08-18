#!/usr/bin/env bash
# r10earl61 BOUNDARY ATTRIBUTOR — for ONE arm .sv, run Surelog (LHS golden) and
# BOTH binaries, then attribute the move three ways on the whole-dump line
# MULTISET, indentation-stripped and path-normalised:
#   TO-GOLDEN    pristine wrong -> patched right
#   AWAY-GOLDEN  pristine RIGHT -> patched WRONG   <== the only fatal bucket
#   STILL-WRONG  both wrong, differently
# An arm that MOVES is not a failure; an arm that moves AWAY is.
#
#   usage: SLANG_PAT=… SLANG_PRIS=… varm61.sh <arm.sv> <plain|elab> [wd]
set -u
SUR=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
SRC=${1:?arm source}; VIEW=${2:-plain}
: "${SLANG_PAT:?}"; : "${SLANG_PRIS:?}"
case $VIEW in plain) SF=""; GF="-parse";; elab) SF="--elabuhdm"; GF="-parse -elabuhdm";; esac
B=$(basename "$SRC"); B=${B%.*}
D=${3:-/tmp/r10earl61_varm/${B}_$VIEW}
rm -rf "$D"; mkdir -p "$D" || exit 9
cp "$SRC" "$D/" || exit 9
S=$(basename "$SRC")
cd "$D" || exit 9
$SUR $GF -nocache -mt 0 -mp 0 "$S" >surelog.log 2>&1 </dev/null
[ -f slpp_all/surelog.uhdm ] || { echo "$B/$VIEW SURELOG_FAIL"; exit 5; }
"$DUMP" slpp_all/surelog.uhdm 2>/dev/null | sed '1d' | sed "s#$D#WD#g" > g.dump
for side in pris pat; do
  case $side in pris) BIN=$SLANG_PRIS;; pat) BIN=$SLANG_PAT;; esac
  "$BIN" $SF "$S" -o $side.uhdm >$side.log 2>&1 </dev/null
  [ -f $side.uhdm ] || { echo "$B/$VIEW NO_OUTPUT($side)"; exit 6; }
  "$DUMP" $side.uhdm 2>/dev/null | sed '1d' | sed "s#$D#WD#g" > $side.dump
done
python3 - g.dump pris.dump pat.dump "$B/$VIEW" <<'PY'
import sys, collections
def load(p):
    c = collections.Counter()
    for l in open(p, errors='replace'):
        c[l.strip()] += 1
    return c
g, p, q = (load(a) for a in sys.argv[1:4])
to = away = still = 0; rows = []
for k in set(g) | set(p) | set(q):
    a, b, c = g[k], p[k], q[k]
    if b == c: continue
    if b != a and c == a:   to += 1;   rows.append(('TO-GOLDEN', k, a, b, c))
    elif b == a and c != a: away += 1; rows.append(('AWAY-GOLDEN', k, a, b, c))
    else:                   still += 1;rows.append(('STILL-WRONG', k, a, b, c))
print('%s  TO-GOLDEN=%d AWAY-GOLDEN=%d STILL-WRONG=%d' % (sys.argv[4], to, away, still))
rows.sort(key=lambda r: (r[0] != 'AWAY-GOLDEN', r[0]))
for r in rows[:40]:
    print('   %-12s golden=%-4d pristine=%-4d patched=%-4d  %s' % (r[0], r[2], r[3], r[4], r[1][:110]))
PY

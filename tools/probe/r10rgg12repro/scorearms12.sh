#!/usr/bin/env bash
# r10rgg12/scorearms12.sh — AN ARM THAT MOVES IS NOT ENOUGH, IT HAS TO MOVE
# TOWARD GOLDEN.  For each named source arm this rebuilds the GOLDEN database
# with Surelog and classifies every RANGE-bound census row OK / FIXED / BROKEN /
# STILL.
#
#   usage: scorearms12.sh <base-bin> <pat-bin> <outfile> <src> [<src> ...]
set -u
A=${1:?base bin}; B=${2:?pat bin}; OUT=${3:?outfile}; shift 3
SL=$HOME/git-repos/Surelog/build/bin/surelog
CEN=/tmp/r10rgg12_rcensus
[ -x "$CEN" ] || { echo "FATAL: no $CEN"; exit 3; }
ok=0; fx=0; bk=0; st=0; arms=0; nogold=0
{
for f in "$@"; do
  [ -f "$f" ] || { echo "MISSING $f"; continue; }
  d=$(dirname "$f"); b=$(basename "$f")
  w=$(mktemp -d /tmp/r10rgg12_arm.XXXXXX)
  ( cd "$d" && rm -rf slpp_all && "$SL" -parse -mt 0 -mp 0 "$b" > "$w/sl.log" 2>&1
    [ -f slpp_all/surelog.uhdm ] && cp slpp_all/surelog.uhdm "$w/golden.uhdm"
    "$A" "$b" --single-unit -o "$w/a.uhdm" > /dev/null 2>&1
    "$B" "$b" --single-unit -o "$w/b.uhdm" > /dev/null 2>&1
    rm -rf slpp_all )   # Surelog's byproduct must never be left in the tree:
                        # a stray slpp_all/lib/work/<src>.sv is a COPY of the
                        # arm and shows up as a second, phantom boundary mover.
  if [ ! -f "$w/golden.uhdm" ] || [ ! -f "$w/a.uhdm" ] || [ ! -f "$w/b.uhdm" ]; then
    echo "NOGOLD $f"; nogold=$((nogold+1)); rm -rf "$w"; continue
  fi
  arms=$((arms+1))
  "$CEN" "$w/golden.uhdm" 2>/dev/null | grep '|RANGE|' | LC_ALL=C sort > "$w/g"
  "$CEN" "$w/a.uhdm"      2>/dev/null | grep '|RANGE|' | LC_ALL=C sort > "$w/a"
  "$CEN" "$w/b.uhdm"      2>/dev/null | grep '|RANGE|' | LC_ALL=C sort > "$w/b"
  eval "$(python3 - "$w/g" "$w/a" "$w/b" "$f" <<'PY'
import sys, collections
def load(p):
    d = collections.defaultdict(list)
    for l in open(p, errors='replace'):
        k, _, v = l.rstrip('\n').partition('\t'); d[k].append(v)
    return {k: sorted(v) for k, v in d.items()}
g, a, b = load(sys.argv[1]), load(sys.argv[2]), load(sys.argv[3])
c = collections.Counter()
for k in set(g) | set(a) | set(b):
    G, A, B = g.get(k), a.get(k), b.get(k)
    if A == B: c['OK' if A == G else 'STILL'] += 1
    elif A != G and B == G: c['FIXED'] += 1; print('# FIXED %s %s' % (sys.argv[4], k))
    elif A == G and B != G: c['BROKEN'] += 1; print('# BROKEN %s %s' % (sys.argv[4], k))
    else: c['STILL'] += 1; print('# MOVED-STILL-WRONG %s %s' % (sys.argv[4], k))
print('_ok=%d;_fx=%d;_bk=%d;_st=%d' % (c['OK'], c['FIXED'], c['BROKEN'], c['STILL']))
PY
)"
  echo "ARM $f OK=$_ok FIXED=$_fx BROKEN=$_bk STILL=$_st"
  ok=$((ok+_ok)); fx=$((fx+_fx)); bk=$((bk+_bk)); st=$((st+_st))
  rm -rf "$w"
done
echo "-- arms=$arms NOGOLD=$nogold OK=$ok FIXED=$fx BROKEN=$bk STILL=$st"
} > "$OUT" 2>&1

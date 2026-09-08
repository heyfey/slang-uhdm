#!/usr/bin/env bash
# r10uvm218 — RE-SCORE EVERY BOUNDARY MOVER AGAINST A REAL SURELOG GOLDEN.
# MEASUREMENT ONLY.  A moved arm is not a regression and not an improvement
# until a golden says which; this is the script that asks.
#
# For each arm path handed in, builds ONE REAL Surelog golden in the given view
# and runs `cen218.py` (the reference-actual census) against BOTH binaries'
# databases, with the golden-vs-golden CALIBRATION run FIRST.  Reports, per
# arm-view: TO-GOLDEN (a MISSING-OURS cell the patched binary closed),
# AWAY-GOLDEN (an EXTRA-OURS or OTHER cell it created) and STILL-WRONG.
#
# Surelog and both binaries run in the SAME directory (buvm8's `bndarms` trap);
# every rc is recorded; a missing database prints NO-DATABASE and is COUNTED.
#
#   usage: armscore218.sh <tree> <scratch> <out> <binA> <binB> <armlist-file>
#          armlist lines: "<relpath> <view>"   view = def|elab
set -u
TREE=${1:?tree}; SCR=${2:?scratch}; OUT=${3:?out}
A=${4:?pristine}; B=${5:?patched}; LIST=${6:?armlist}
HERE=$(cd "$(dirname "$0")" && pwd)
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
for t in "$A" "$B" "$SURELOG" "$DUMP"; do
  [ -x "$t" ] || { echo "FATAL: no $t"; exit 3; }
done
[ -f "$LIST" ] || { echo "FATAL: no armlist $LIST"; exit 3; }
mkdir -p "$SCR" || exit 1
: > "$OUT"
n=0; nog=0; calib=0; tog=0; away=0; still=0
while read -r rel view <&3; do
  n=$((n+1))
  key=$(echo "$rel" | sed 's|^\./||; s|/|__|g; s|\.sv$||')
  d=$SCR/$key.$view
  rm -rf "$d"; mkdir -p "$d" || exit 1
  cp "$TREE/$rel" "$d/" || exit 1
  bn=$(basename "$rel")
  ex=""; sx=""; [ "$view" = elab ] && { ex="-elabuhdm"; sx="--elabuhdm"; }
  ( cd "$d" && timeout 300 "$SURELOG" -parse -d coveruhdm -nobuiltin -nocache $ex "$bn" > sl.log 2>&1 </dev/null ); grc=$?
  ( cd "$d" && timeout 300 "$A" $sx "$bn" -o a.uhdm > a.log 2>&1 </dev/null ); arc=$?
  ( cd "$d" && timeout 300 "$B" $sx "$bn" -o b.uhdm > b.log 2>&1 </dev/null ); brc=$?
  g=$d/slpp_all/surelog.uhdm
  if [ ! -f "$g" ] || [ ! -f "$d/a.uhdm" ] || [ ! -f "$d/b.uhdm" ]; then
    echo "ARM $rel $view rc_sl=$grc rc_a=$arc rc_b=$brc VERDICT=NO-DATABASE" >> "$OUT"
    nog=$((nog+1)); continue
  fi
  "$DUMP" "$g" > "$d/g.dump" 2>&1
  "$DUMP" "$d/a.uhdm" > "$d/a.dump" 2>&1
  "$DUMP" "$d/b.uhdm" > "$d/b.dump" 2>&1
  cal=$(python3 "$HERE/cen218.py" "$d/g.dump" "$d/g.dump" work@ --quiet | tail -1)
  case "$cal" in *"MISSING-OURS=0 EXTRA-OURS=0 OTHER=0") : ;; *) calib=$((calib+1)) ;; esac
  pa=$(python3 "$HERE/cen218.py" "$d/g.dump" "$d/a.dump" work@ --quiet | tail -1)
  pb=$(python3 "$HERE/cen218.py" "$d/g.dump" "$d/b.dump" work@ --quiet | tail -1)
  ma=$(echo "$pa" | sed -n 's/.*MISSING-OURS=\([0-9]*\).*/\1/p')
  mb=$(echo "$pb" | sed -n 's/.*MISSING-OURS=\([0-9]*\).*/\1/p')
  ea=$(echo "$pa" | sed -n 's/.*EXTRA-OURS=\([0-9]*\).*/\1/p')
  eb=$(echo "$pb" | sed -n 's/.*EXTRA-OURS=\([0-9]*\).*/\1/p')
  oa=$(echo "$pa" | sed -n 's/.*OTHER=\([0-9]*\).*/\1/p')
  ob=$(echo "$pb" | sed -n 's/.*OTHER=\([0-9]*\).*/\1/p')
  t=$((ma-mb)); [ "$t" -lt 0 ] && t=0
  aw=$(( (eb-ea) + (ob-oa) )); [ "$aw" -lt 0 ] && aw=0
  [ "$mb" -gt "$ma" ] && aw=$((aw + mb - ma))
  tog=$((tog+t)); away=$((away+aw)); still=$((still+mb))
  echo "ARM $rel $view rc_sl=$grc rc_a=$arc rc_b=$brc CALIB[$cal]" >> "$OUT"
  echo "  PRIS $pa" >> "$OUT"
  echo "  PAT  $pb" >> "$OUT"
  echo "  SCORE TO-GOLDEN=$t AWAY-GOLDEN=$aw STILL-WRONG=$mb" >> "$OUT"
  diff <(python3 "$HERE/cen218.py" "$d/g.dump" "$d/a.dump" work@) \
       <(python3 "$HERE/cen218.py" "$d/g.dump" "$d/b.dump" work@) \
       | sed "s|^|  CELLDIFF $rel $view |" >> "$OUT"
done 3< "$LIST"
echo "-- ARM-VIEWS=$n NO-DATABASE=$nog CALIB non-null=$calib TO-GOLDEN=$tog AWAY-GOLDEN=$away STILL-WRONG=$still" >> "$OUT"
tail -1 "$OUT"

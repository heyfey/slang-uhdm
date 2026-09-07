#!/usr/bin/env bash
# r10earl113 -- GOLDEN-vs-GOLDEN CALIBRATION.  MEASUREMENT ONLY.
#
# RESUME.md section 9: "Calibrate golden-vs-golden FIRST."  A census that
# reports differences between a database and ITSELF is measuring its own
# instability, not the emitter.  This runs cen113 TWICE on each arm's golden
# (two independent Restore + walk passes, not a file copy) and scores the pair
# with score113.py: the only verdict allowed is SAME_AGREE.
#
#   usage: calib113.sh <griddir>
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
CEN=${CEN_BIN:-$HERE/cen113}
G=${1:?griddir}
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib
tmp=$(mktemp -d /tmp/r10earl113_calib.XXXXXX) || exit 1
n=0; bad=0
for d in "$G"/*/; do
  arm=$(basename "$d")
  gold=$(find "$d/sl" -name '*.uhdm' 2>/dev/null | head -1)
  [ -n "$gold" ] && [ -f "$gold" ] || { echo "SKIP-NOGOLD $arm"; bad=$((bad+1)); continue; }
  o="$tmp/$arm"; mkdir -p "$o"
  "$CEN" "$gold" "$arm" > "$o/cen.gold.txt"  2>&1; r1=$?
  "$CEN" "$gold" "$arm" > "$o/cen.pris.txt"  2>&1; r2=$?
  "$CEN" "$gold" "$arm" > "$o/cen.patch.txt" 2>&1; r3=$?
  if [ "$r1$r2$r3" != "000" ]; then
    echo "CENRC-BAD $arm $r1/$r2/$r3"; bad=$((bad+1)); continue
  fi
  n=$((n+1))
done
echo "-- calibrated arms=$n  problems=$bad"
python3 "$HERE/score113.py" "$tmp"/*/
echo "(the ONLY verdict allowed above is SAME_AGREE / NOGOLD_UNMOVED / ONESIDED;"
echo " any TOGOLD, AWAY, MOVEDWRONG or STILLWRONG is instrument instability)"
rm -rf "$tmp"

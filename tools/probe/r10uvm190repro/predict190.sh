#!/usr/bin/env bash
# r10uvm190repro/predict190.sh — NAME THE MOVER SET FROM PRISTINE DATABASES
# ALONE, before the patched sweep runs.  MEASUREMENT ONLY.
#
# § enumBaseTdCloneDanglingRange190 fires on exactly one shape: the typespec an
# `enum_typespec` names as its `Base_typespec`, when that typespec carries a
# `Typedef_alias` (i.e. it is a per-declaration clone of a typedef) AND its
# packed range holds a reference that is BOUND.  `ct190cen`'s `TDCE` rows are
# that population exactly — reached FROM the enum, so the clone POSITION is
# known and not guessed from a fan-in count — so this script is a grep over the
# census and not a model of the patch.
#
# It also reports the WIDER `TDC` population (a bound reference inside ANY
# typedef-alias clone, whatever its position).  That is the UPPER BOUND on what
# a wrongly-scoped version of this law could touch; the patch writes only the
# `TDCE` half, and any byte mover outside it would be a fence failure.
#
# The four slang-fenced test names are REDACTED to `FENCED-<hash>` in the
# output.  This script does not SPELL them: it reads the fence list out of
# `canaudit.sh`'s own `FENCED=` line (earl111's `widerun111.sh` precedent), so
# the only file in this directory that names them is the auditor itself.
# Nothing here dispatches a test — it reads databases an already-finished sweep
# left behind.
#
#   usage: CEN=<ct190cen> predict190.sh <pristine workdir> <out file>
#
# A database that is missing on either side is COUNTED and NAMED, never
# silently skipped.
set -u
WD=${1:?pristine workdir}
OUT=${2:?out file}
CEN=${CEN:?path to ct190cen}
[ -x "$CEN" ] || { echo "FATAL: no ct190cen at $CEN"; exit 3; }
[ -d "$WD" ] || { echo "FATAL: no workdir $WD"; exit 3; }
HERE=$(cd "$(dirname "$0")" && pwd)
FENCED=$(sed -n 's/^FENCED="\(.*\)"$/\1/p' "$HERE/canaudit.sh")
[ -n "$FENCED" ] || { echo "FATAL: no fence list in canaudit.sh"; exit 3; }
: > "$OUT"
seen=0; noo=0; hits=0; wider=0
for mode in default testflags; do
  [ -d "$WD/$mode" ] || continue
  for d in "$WD/$mode"/*/; do
    [ -d "$d" ] || continue
    seen=$((seen+1))
    t=$(basename "$d")
    if [ ! -f "$d/slang.uhdm" ]; then
      echo "NO-DB $mode/$t" >> "$OUT"; noo=$((noo+1)); continue
    fi
    C=$("$CEN" "$d/slang.uhdm" "$mode/$t" 2>/dev/null)
    n=$(printf '%s\n' "$C" | grep -c '\bTDCE\b.*ref([^,]*,BOUND' || true)
    w=$(printf '%s\n' "$C" | grep -c '\bTDC\b.*ref([^,]*,BOUND' || true)
    [ -z "$n" ] && n=0
    [ -z "$w" ] && w=0
    nm=$t
    for fn in $FENCED; do
      case $t in "$fn"-*) nm=FENCED-${t##*-} ;; esac
    done
    if [ "$n" -gt 0 ]; then
      echo "PREDICT-MOVER $mode/$nm enumbase-bound-cells=$n any-clone-bound-cells=$w" >> "$OUT"
      hits=$((hits+1))
    elif [ "$w" -gt 0 ]; then
      echo "NOT-A-MOVER   $mode/$nm enumbase-bound-cells=0 any-clone-bound-cells=$w" >> "$OUT"
      wider=$((wider+1))
    fi
  done
done
echo "-- dirs=$seen no-ours=$noo PREDICTED MOVERS=$hits  wider-TDC-only(no move expected)=$wider" | tee -a "$OUT"

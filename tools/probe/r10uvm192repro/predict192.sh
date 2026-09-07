#!/usr/bin/env bash
# r10uvm192repro/predict192.sh — NAME THE MOVER SET FROM PRISTINE DATABASES
# ALONE, before the patched sweep runs.  MEASUREMENT ONLY; the official
# uhdm-cmp is the judge.
#
# § pkgTfBodyCmViewClone192's fence is transcribed into `ct192cen`'s PRED
# section, term for term, straight off the production code:
#   (1) a func_call/task_call ALREADY bound to a CLASS_DEFN-parented method,
#   (2) whose written VpiName holds `::`,
#   (3) sitting in the body of a subroutine whose own parent is a package,
#   (4) where THAT package's own Task_funcs holds an entry of the call's kind
#       named EXACTLY the written name.
# A row clearing (1)-(3) but failing (4) prints as WIDE-NO-ENTRY: it is the
# upper bound a wrongly-scoped version of this law could touch, and it must NOT
# move.  So this script is a grep over the census, not a model of the patch.
#
# The four slang-fenced test names are REDACTED to `FENCED-<hash>` in the
# output.  This script does not SPELL them: it reads the fence list out of
# `canaudit.sh`'s own `FENCED=` line.  Nothing here dispatches a test — it
# reads databases an already-finished sweep left behind.
#
#   usage: CEN=<ct192cen> predict192.sh <pristine workdir> <out file>
#
# A database missing on either side is COUNTED and NAMED, never silently
# skipped.
set -u
WD=${1:?pristine workdir}
OUT=${2:?out file}
CEN=${CEN:?path to ct192cen}
[ -x "$CEN" ] || { echo "FATAL: no ct192cen at $CEN"; exit 3; }
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
    nm=$t
    for fn in $FENCED; do
      case $t in "$fn"-*) nm=FENCED-${t##*-} ;; esac
    done
    if [ ! -f "$d/slang.uhdm" ]; then
      echo "NO-DB $mode/$nm" >> "$OUT"; noo=$((noo+1)); continue
    fi
    C=$("$CEN" "$d/slang.uhdm" "$mode/$nm" 2>/dev/null)
    n=$(printf '%s\n' "$C" | grep -ac '^PRED	.*	MOVE	' || true)
    w=$(printf '%s\n' "$C" | grep -ac '^PRED	.*	WIDE-NO-ENTRY	' || true)
    [ -z "$n" ] && n=0
    [ -z "$w" ] && w=0
    if [ "$n" -gt 0 ]; then
      echo "PREDICT-MOVER $mode/$nm move-cells=$n wide-no-entry=$w" >> "$OUT"
      printf '%s\n' "$C" | grep -a '^PRED	.*	MOVE	' >> "$OUT"
      hits=$((hits+1))
    elif [ "$w" -gt 0 ]; then
      echo "NOT-A-MOVER   $mode/$nm move-cells=0 wide-no-entry=$w" >> "$OUT"
      wider=$((wider+1))
    fi
  done
done
echo "-- dirs=$seen no-ours=$noo PREDICTED MOVERS=$hits  wide-only(no move expected)=$wider" | tee -a "$OUT"

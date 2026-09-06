#!/usr/bin/env bash
# r10uvm175 — GOLDEN-vs-GOLDEN CALIBRATION of the census instrument
# (RESUME.md §9: "Calibrate golden-vs-golden FIRST").  Builds each arm's
# Surelog golden TWICE, in two DIFFERENT directories, and scores one against
# the other with the SAME cells175.py/score175.py the grid uses.  A census that
# cannot read 0 DIFF on two runs of the same producer cannot be trusted to read
# a real one.  MEASUREMENT ONLY.
#
#   calib175.sh [<scratch>]
set -u
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
WD=${1:-/tmp/r10uvm175_calib}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
rm -rf "$WD"; mkdir -p "$WD"
LIST=$WD/arms.txt
(cd "$HERE" && ls g175_*.sv | sort) > "$LIST"
listed=$(wc -l < "$LIST"); proc=0
exec 3< "$LIST"
while IFS= read -r rel <&3; do
  b=${rel%.sv}
  for view in def elab; do
    if [ "$view" = elab ]; then SLX=-elabuhdm; else SLX=; fi
    for run in r1 r2; do
      o=$WD/$b.$view.$run; mkdir -p "$o"; cp "$HERE/$rel" "$o/"
      ( cd "$o" && "$SURELOG" -parse $SLX "$rel" -d uhdm -nobuiltin -mt 0 -mp 0 \
          -o g > sl.log 2>&1 </dev/null ); echo "rc_sl=$?" >> "$o/rcs"
      "$DUMP" "$o/g/slpp_all/surelog.uhdm" 2>/dev/null </dev/null > "$o/g.dump"
      python3 "$HERE/cells175.py" "$o/g.dump" > "$o/g.cells" 2>/dev/null
    done
    python3 "$HERE/score175.py" "$WD/$b.$view.r1/g.cells" \
        "$WD/$b.$view.r2/g.cells" "" "CALIB $b.$view" | head -1
  done
  proc=$((proc+1))
done
exec 3<&-
echo "LISTED=$listed PROCESSED=$proc"
[ "$proc" -eq "$listed" ] || { echo PROCESSED-ASSERT-FAILED; exit 6; }
echo PROCESSED-ASSERT-OK

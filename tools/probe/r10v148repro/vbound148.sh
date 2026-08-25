#!/usr/bin/env bash
# r10v148 (VERIFIER) BOUNDARY — run the PRISTINE and PATCHED binaries over a
# list of arm sources in BOTH views and report which ones MOVE.
# MEASUREMENT ONLY.  Ops traps paid: subdirectory arms, list on fd 3, children
# </dev/null, PROCESSED asserted, scratch keyed on the RELATIVE path, every rc
# recorded, dump paths normalised before the diff.
#   PRI=<pris> PAT=<pat> ROOT=<dir> [WD=<scratch>] [CTRL=1] vbound148.sh
set -u
PRI=${PRI:?}; PAT=${PAT:?}; ROOT=${ROOT:?}
WD=${WD:-/tmp/v148_bound}
CTRL=${CTRL:-0}
rm -rf "$WD"; mkdir -p "$WD"
LIST=$WD/files.txt
(cd "$ROOT" && find . \( -name '*.sv' -o -name '*.v' -o -name '*.svh' \) -type f | sed 's|^\./||' | sort) > "$LIST"
listed=$(wc -l < "$LIST"); proc=0; moved=0; rcmis=0
: > "$WD/MOVED.txt"
exec 3< "$LIST"
while IFS= read -r rel <&3; do
  key=${rel//\//__}
  for view in def elab; do
    o=$WD/$key.$view; mkdir -p "$o"
    cp "$ROOT/$rel" "$o/src.sv"
    if [ "$view" = elab ]; then SUX=--elabuhdm; else SUX=; fi
    ( cd "$o" && "$PRI" src.sv --single-unit $SUX -o a.uhdm > a.log 2>&1 </dev/null ); ra=$?
    ( cd "$o" && "$PAT" src.sv --single-unit $SUX -o b.uhdm > b.log 2>&1 </dev/null ); rb=$?
    echo "rc_pris=$ra rc_pat=$rb" > "$o/rcs"
    if [ "$ra" != "$rb" ]; then echo "RC-MISMATCH $rel $view $ra $rb" >> "$WD/MOVED.txt"; rcmis=$((rcmis+1)); continue; fi
    [ -f "$o/a.uhdm" ] && [ -f "$o/b.uhdm" ] || continue
    # normalise BOTH the workdir path AND the database filename: uhdm-dump
    # echoes "<db>: Restored design ..." and a bare path strip leaves a.uhdm
    # vs b.uhdm as a permanent 2-line phantom on EVERY arm.
    ~/.local/bin/uhdm-dump "$o/a.uhdm" 2>/dev/null | sed "s|$o/||g; s|^[ab][.]uhdm:|DB:|" > "$o/a.dmp"
    ~/.local/bin/uhdm-dump "$o/b.uhdm" 2>/dev/null | sed "s|$o/||g; s|^[ab][.]uhdm:|DB:|" > "$o/b.dmp"
    if [ "$CTRL" = 1 ]; then sed -i '1s/.*/POSITIVE-CONTROL-INJECTED/' "$o/b.dmp"; fi
    if ! cmp -s "$o/a.dmp" "$o/b.dmp"; then
      n=$(diff "$o/a.dmp" "$o/b.dmp" | grep -c '^[<>]'); n=${n:-0}
      echo "MOVED $rel $view lines=$n" >> "$WD/MOVED.txt"
      moved=$((moved+1))
    fi
  done
  proc=$((proc+1))
done
exec 3<&-
echo "LISTED=$listed PROCESSED=$proc MOVED=$moved RC-MISMATCH=$rcmis"
[ "$proc" -eq "$listed" ] || { echo PROCESSED-ASSERT-FAILED; exit 6; }
echo PROCESSED-ASSERT-OK
cat "$WD/MOVED.txt"

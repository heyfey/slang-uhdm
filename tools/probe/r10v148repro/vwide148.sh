#!/usr/bin/env bash
# r10v148 (VERIFIER) WIDE BOUNDARY — every committed probe-arm source in the
# tree, both views, pristine vs patched.  MEASUREMENT ONLY.
# Cheap first pass on the DATABASE BYTES; only a byte-differing pair is dumped
# and diffed (a byte difference with an identical dump is invisible to the
# judge and is reported as BYTE-ONLY, never as MOVED).
#   PRI= PAT= ROOT= LIST= [WD=] [CTRL=1] vwide148.sh
set -u
PRI=${PRI:?}; PAT=${PAT:?}; ROOT=${ROOT:?}; LIST=${LIST:?}
WD=${WD:-/tmp/v148_wide}; CTRL=${CTRL:-0}
rm -rf "$WD"; mkdir -p "$WD"
listed=$(wc -l < "$LIST"); proc=0; moved=0; byteonly=0; rcmis=0
: > "$WD/MOVED.txt"
exec 3< "$LIST"
while IFS= read -r rel <&3; do
  key=${rel//\//__}
  for view in def elab; do
    o=$WD/$key.$view; mkdir -p "$o"
    cp "$ROOT/$rel" "$o/src.sv" 2>/dev/null || { proc=$((proc)); continue; }
    if [ "$view" = elab ]; then SUX=--elabuhdm; else SUX=; fi
    ( cd "$o" && "$PRI" src.sv --single-unit $SUX -o a.uhdm > a.log 2>&1 </dev/null ); ra=$?
    ( cd "$o" && "$PAT" src.sv --single-unit $SUX -o b.uhdm > b.log 2>&1 </dev/null ); rb=$?
    echo "rc_pris=$ra rc_pat=$rb" > "$o/rcs"
    if [ "$ra" != "$rb" ]; then echo "RC-MISMATCH $rel $view $ra $rb" >> "$WD/MOVED.txt"; rcmis=$((rcmis+1)); rm -rf "$o"/*.uhdm; continue; fi
    if [ ! -f "$o/a.uhdm" ] || [ ! -f "$o/b.uhdm" ]; then rm -rf "$o"/*.uhdm; continue; fi
    # POSITIVE CONTROL: CTRL=1 forces the byte pass AND the dump pass to see a
    # deliberate difference, so a green run proves the gate is not blind.  (A
    # control that only perturbs the BYTES proves the cheap pass only and leaves
    # the dump comparison untested — it reads BYTE-ONLY, never MOVED.)
    if [ "$CTRL" = 1 ]; then printf 'X' >> "$o/b.uhdm"; fi
    if cmp -s "$o/a.uhdm" "$o/b.uhdm"; then rm -f "$o/a.uhdm" "$o/b.uhdm"; continue; fi
    ~/.local/bin/uhdm-dump "$o/a.uhdm" 2>/dev/null | sed "s|$o/||g; s|^[ab][.]uhdm:|DB:|" > "$o/a.dmp"
    ~/.local/bin/uhdm-dump "$o/b.uhdm" 2>/dev/null | sed "s|$o/||g; s|^[ab][.]uhdm:|DB:|" > "$o/b.dmp"
    if [ "$CTRL" = 1 ]; then sed -i '1s/.*/POSITIVE-CONTROL-INJECTED/' "$o/b.dmp"; fi
    if cmp -s "$o/a.dmp" "$o/b.dmp"; then
      echo "BYTE-ONLY $rel $view" >> "$WD/MOVED.txt"; byteonly=$((byteonly+1))
    else
      n=$(diff "$o/a.dmp" "$o/b.dmp" | grep -c '^[<>]'); n=${n:-0}
      echo "MOVED $rel $view lines=$n" >> "$WD/MOVED.txt"; moved=$((moved+1))
    fi
    rm -f "$o/a.uhdm" "$o/b.uhdm"
  done
  proc=$((proc+1))
done
exec 3<&-
echo "LISTED=$listed PROCESSED=$proc MOVED=$moved BYTE-ONLY=$byteonly RC-MISMATCH=$rcmis"
[ "$proc" -eq "$listed" ] || { echo PROCESSED-ASSERT-FAILED; exit 6; }
echo PROCESSED-ASSERT-OK

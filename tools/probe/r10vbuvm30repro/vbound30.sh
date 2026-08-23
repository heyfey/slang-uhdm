#!/usr/bin/env bash
# r10vbuvm30 (VERIFIER) WIDE boundary gate.  EVERY .sv/.v under a COPY of
# tools/probe (no path filter, both suffixes, recursive so subdirectory arms
# run), both binaries, DEF and ELAB; fd-3 list, children </dev/null, PROCESSED
# asserted, rc recorded per cell.  Every MOVED arm is then SCORED against a
# REBUILT Surelog golden with the view-general cell census, so a mover is
# reported as TOWARD or AWAY from golden rather than merely "different".
#   PRI=<pristine> PAT=<candidate> ROOT=<copy of tools/probe> [BWD=<scratch>]
set -u
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PRI=${PRI:?}; PAT=${PAT:?}; ROOT=${ROOT:?}
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
SL=$HOME/git-repos/Surelog/build/bin/surelog
WD=${BWD:-/tmp/vbuvm30_bound}
rm -rf "$WD"; mkdir -p "$WD" || exit 9
LIST=$WD/sources.txt
find "$ROOT" \( -name '*.sv' -o -name '*.v' \) | sort > "$LIST"
listed=$(wc -l < "$LIST")
[ "$listed" -gt 0 ] || { echo "EMPTY-LIST"; exit 4; }
# The four slang-fenced test names are NEVER dispatched and NEVER spelled in a
# probe artifact; supply them from outside as an extended regex if needed.
n=0; moved=0; noout=0; fenced=0; proc=0
exec 3< "$LIST"
while IFS= read -r src <&3; do
  n=$((n+1))
  if [ -n "${FENCE_RE:-}" ] && printf '%s' "$(basename "$src")" | grep -qE "$FENCE_RE"; then
    fenced=$((fenced+1)); continue
  fi
  rel=${src#$ROOT/}
  b=$(printf "%04d_%s" "$n" "$(echo "$rel" | sed 's#[^A-Za-z0-9._-]#_#g')")
  o=$WD/$b; mkdir -p "$o"; cp "$src" "$o/" || continue
  leaf=$(basename "$src")
  proc=$((proc+1))
  for m in def elab; do
    fl=""; [ $m = elab ] && fl="-elabuhdm"
    ( cd "$o" && "$PRI" $fl "$leaf" -o pris_$m.uhdm >pris_$m.log 2>&1 </dev/null; echo "rc=$?" >> pris_$m.log )
    ( cd "$o" && "$PAT" $fl "$leaf" -o pat_$m.uhdm  >pat_$m.log  2>&1 </dev/null; echo "rc=$?" >> pat_$m.log )
    rcp=$(sed -n 's/^rc=//p' "$o/pris_$m.log" | tail -1)
    rcq=$(sed -n 's/^rc=//p' "$o/pat_$m.log" | tail -1)
    [ "$rcp" = "$rcq" ] || { echo "RC_MISMATCH $b/$m $rcp vs $rcq"; moved=$((moved+1)); }
    if [ ! -f "$o/pris_$m.uhdm" ] || [ ! -f "$o/pat_$m.uhdm" ]; then
      if [ -f "$o/pris_$m.uhdm" ] || [ -f "$o/pat_$m.uhdm" ]; then
        echo "ASYMMETRIC_OUTPUT $b/$m"; moved=$((moved+1))
      else noout=$((noout+1)); fi
      continue
    fi
    "$DUMP" "$o/pris_$m.uhdm" 2>/dev/null </dev/null | sed 1d > "$o/pris_$m.dump"
    "$DUMP" "$o/pat_$m.uhdm"  2>/dev/null </dev/null | sed 1d > "$o/pat_$m.dump"
    cmp -s "$o/pris_$m.dump" "$o/pat_$m.dump" && continue
    echo "MOVED $b/$m $(diff "$o/pris_$m.dump" "$o/pat_$m.dump" | grep -cE '^[<>]'; true) lines"
    moved=$((moved+1))
    # SCORE the mover against a rebuilt golden.
    ( cd "$o" && $SL -parse "$leaf" -d uhdm -nobuiltin -mt 0 -mp 0 $fl -o g_$m >sl_$m.log 2>&1 </dev/null )
    gu=$o/g_$m/slpp_all/surelog.uhdm
    if [ -f "$gu" ]; then
      "$DUMP" "$gu" 2>/dev/null </dev/null | sed "s#$o##g" > "$o/g_$m.dump"
      for t in g pris pat; do
        python3 "$HERE/vcells30.py" "$o/${t}_$m.dump" > "$o/${t}_$m.cells" 2>/dev/null || : > "$o/${t}_$m.cells"
      done
      python3 "$HERE/vscore30.py" "$o/g_$m.cells" "$o/pris_$m.cells" "$o/pat_$m.cells" "  SCORE $b/$m"
    else
      echo "  SCORE $b/$m NO-GOLDEN"
    fi
  done
done
exec 3<&-
echo "LISTED=$listed FENCED_SKIPPED=$fenced PROCESSED=$proc MOVED=$moved NO_OUTPUT_PAIRS=$noout"
[ $((proc+fenced)) -eq "$listed" ] || { echo "PROCESSED-ASSERT-FAILED"; exit 6; }
echo "PROCESSED-ASSERT-OK"

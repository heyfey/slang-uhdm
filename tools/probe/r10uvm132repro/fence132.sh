#!/bin/bash
# r10uvm132/fence132.sh — MEASUREMENT ONLY.  A fence arm that SURELOG CANNOT
# COMPILE has no golden, so it is scored the only honest way left: the two
# frozen binaries' own dumps must be BYTE-IDENTICAL, in BOTH views.
#
#   usage: PRI=<pristine> PAT=<patched> fence132.sh <arm .sv> [...]
#
# GUARDS: both binaries are named and PRINTED with their md5; each child gets
# </dev/null and its rc is RECORDED (a segfault otherwise reads as "no rows
# moved"); a MISSING dump on either side is reported, never counted as equal;
# any `.svh` beside the source is carried along (these arms keep their macro
# DEFINITIONS in a separate header on purpose).
set -u
PRI=${PRI:?pristine binary}; PAT=${PAT:?patched binary}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
WD=${FWD:-/tmp/r10uvm132_fence}
echo "PRI $(md5sum "$PRI" | cut -c1-32)  PAT $(md5sum "$PAT" | cut -c1-32)"
rc_all=0
for ARM in "$@"; do
  d=$WD/$(basename "$ARM" .sv); rm -rf "$d"; mkdir -p "$d" || exit 9
  cp "$ARM" "$d"/ || exit 9
  cp "$(dirname "$ARM")"/*.svh "$d"/ 2>/dev/null
  leaf=$(basename "$ARM")
  for m in def elab; do
    fl=""; [ $m = elab ] && fl="-elabuhdm"
    ( cd "$d" && "$PRI" $fl "$leaf" -o pris_$m.uhdm >pris_$m.log 2>&1 </dev/null ); p=$?
    ( cd "$d" && "$PAT" $fl "$leaf" -o pat_$m.uhdm  >pat_$m.log  2>&1 </dev/null ); q=$?
    if [ ! -f "$d/pris_$m.uhdm" ] || [ ! -f "$d/pat_$m.uhdm" ]; then
      echo "  $leaf $m: MISSING DATABASE (pris rc=$p pat rc=$q)"; rc_all=1; continue
    fi
    "$DUMP" "$d/pris_$m.uhdm" 2>/dev/null </dev/null | sed 1d > "$d/pris_$m.dump"
    "$DUMP" "$d/pat_$m.uhdm"  2>/dev/null </dev/null | sed 1d > "$d/pat_$m.dump"
    if cmp -s "$d/pris_$m.dump" "$d/pat_$m.dump"; then
      echo "  $leaf $m: BYTE-IDENTICAL (pris rc=$p pat rc=$q)"
    else
      echo "  $leaf $m: MOVED $(diff "$d/pris_$m.dump" "$d/pat_$m.dump" | grep -cE '^[<>]'; true) lines (pris rc=$p pat rc=$q)"
      rc_all=1
    fi
  done
done
[ $rc_all -eq 0 ] && echo "FENCE PASS" || echo "FENCE FAIL"
exit $rc_all

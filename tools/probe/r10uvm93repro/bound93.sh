#!/usr/bin/env bash
# r10uvm93 — THE BOUNDARY GATE (uvm77-92, buvm3-16, sd8-12).
# fences (uvm77-87, buvm3-9, sd8-12, and uvm82's parameterized-class /
# type_parameter arms by name) with BOTH binaries and reports every source whose
# UHDM DUMP MOVED.  MEASUREMENT-ONLY.
#
#   PRI=<pristine> PAT=<patched> ./bound93.sh [extra dirs...]
#
# GUARDS this campaign has paid for:
#   * RECURSIVE glob (`find -name '*.sv'`): r10sd8..12 keep their arms in
#     SUBDIRECTORIES (grid6/, grid7/, grid7v/), and a top-level `*.sv` glob
#     reports "0 sources, 0 movers" — a gate that reaches nothing must never
#     read as green, so the SOURCE COUNT is printed and a count of 0 is exit 4.
#   * a source that FAILS TO COMPILE on either binary is reported as
#     NO_OUTPUT and COUNTED, never silently skipped.
#   * each source is compiled in its OWN scratch dir with the SAME absolute
#     path for both binaries, because uhdm-dump embeds paths.
set -u
PRI=${PRI:?pristine binary}
PAT=${PAT:?patched binary}
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
ROOT=${ROOT:?probe root of YOUR worktree, e.g. /tmp/wt_r10uvm93/tools/probe}
DIRS=${DIRS:-"r10uvm77repro r10uvm78repro r10uvm79repro r10uvm80repro
r10uvm81repro r10uvm82repro r10uvm83repro r10uvm84repro r10uvm85repro
r10uvm86repro r10uvm87repro r10uvm88repro r10uvm89repro r10uvm90repro r10uvm91repro r10uvm92repro r10buvm3repro r10buvm4repro r10buvm5repro r10buvm6repro
r10buvm7repro r10buvm8repro r10buvm9repro r10buvm10repro r10buvm11repro r10buvm12repro r10buvm13repro r10buvm14repro r10buvm15repro r10buvm16repro r10sd8repro r10sd9repro
r10sd10repro r10sd11repro r10sd12repro"}
WD=${BWD:-/tmp/r10uvm93_bound}
rm -rf "$WD"; mkdir -p "$WD" || exit 9
# THE LIST IS BUILT FIRST AND READ ON FD 3, and every child gets `</dev/null`.
# A compiler that inherits the loop's stdin eats the rest of the file list and
# the gate silently stops after the first source -- which is the shape a
# "0 movers" reading is indistinguishable from.  LISTED is asserted against
# PROCESSED at the end.
LIST=$WD/sources.txt
: > "$LIST"
for d in $DIRS "$@"; do
  [ -d "$ROOT/$d" ] || { echo "MISSING-DIR $d"; continue; }
  find "$ROOT/$d" -name '*.sv' | sort >> "$LIST"
done
listed=$(wc -l < "$LIST")
n=0; moved=0; noout=0
exec 3< "$LIST"
while IFS= read -r src <&3; do
    n=$((n+1))
    b=$(printf "%03d_%s_%s" "$n" "$(basename "$(dirname "$src")")" "$(basename "$src" .sv)")
    o=$WD/$b; mkdir -p "$o"; cp "$src" "$o/" || continue
    leaf=$(basename "$src")
    ( cd "$o" && "$PRI" "$leaf" -o pris.uhdm >pris.log 2>&1 </dev/null )
    ( cd "$o" && "$PAT" "$leaf" -o pat.uhdm  >pat.log  2>&1 </dev/null )
    if [ ! -f "$o/pris.uhdm" ] || [ ! -f "$o/pat.uhdm" ]; then
      echo "NO_OUTPUT $b"; noout=$((noout+1)); continue
    fi
    "$DUMP" "$o/pris.uhdm" 2>/dev/null </dev/null | sed 1d > "$o/pris.dump"
    "$DUMP" "$o/pat.uhdm"  2>/dev/null </dev/null | sed 1d > "$o/pat.dump"
    if ! cmp -s "$o/pris.dump" "$o/pat.dump"; then
      echo "MOVED $b  $(diff "$o/pris.dump" "$o/pat.dump" | grep -cE '^[<>]'; true) dump lines"
      moved=$((moved+1))
    fi
done
exec 3<&-
echo "---- boundary LISTED=$listed PROCESSED=$n  MOVED=$moved  NO_OUTPUT=$noout"
[ "$n" -gt 0 ] || { echo "REFUSING TO REPORT: compiled 0 sources"; exit 4; }
[ "$n" = "$listed" ] || { echo "REFUSING TO REPORT: PROCESSED != LISTED"; exit 4; }

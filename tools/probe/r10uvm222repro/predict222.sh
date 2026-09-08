#!/usr/bin/env bash
# r10uvm222 — THE A-PRIORI PREDICTOR / POPULATION CENSUS (questions 2 and 5).
# MEASUREMENT ONLY.  Written and RUN from PRISTINE databases alone, BEFORE the
# patched binary is let near either corpus.
#
# § ifaceOwnCallCalleeFormRoutes222 narrows ONE arm — ExprEmit.cpp's
# "INTERFACE method calls through a port" arm — which is the ONLY producer in
# this emitter of a `method_func_call` whose `vpiPrefix` ref_obj is named from
# a RAW TEXT SLICE.  The pristine arm cuts that slice at the statement's LAST
# '.', so whenever the dot it found lies inside the ARGUMENT LIST the prefix
# name necessarily contains the callee's own '(' — the character can reach a
# reference name by NO OTHER ROAD in this emitter.
#
# THE SIGNATURE IS THEREFORE EXACT AND DATABASE-SIDE:
#     a `ref_obj` whose name contains '('  <=>  this arm mis-routed a call.
# Golden never holds one (measured: zero over every grid arm and over every
# golden database this script reads).
#
# Stage 1 prunes on the SOURCE (the arm can only be reached when a compiled
# file declares an `interface`); stage 2 is the authority and re-reads the
# DATABASE, because `include`d files are not listed in cmds.txt.
#
#   usage: predict222.sh <verify_golden-workdir> <out> [jobs]
#
# GUARDS: a workdir that resolves to nothing is FATAL (a predictor that reads
# nothing must never print "no movers"); `grep -c` never gates a `set -e`
# chain; every database that is MISSING is listed, never silently skipped.
set -u
WD=${1:?workdir}; OUT=${2:?out}; J=${3:-4}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
[ -d "$WD" ] || { echo "FATAL: no workdir $WD"; exit 3; }
[ -x "$DUMP" ] || { echo "FATAL: no uhdm-dump $DUMP"; exit 3; }

scan_one() {
  d=$(dirname "$1")
  if [ ! -f "$d/slang.uhdm" ]; then
    echo "NODB $d"
    return 0
  fi
  n=$("$DUMP" "$d/slang.uhdm" 2>/dev/null \
        | grep -oE '\\_ref_obj: \([^)]*\(' | wc -l); true
  if [ "$n" -gt 0 ]; then
    echo "HIT $n $d"
    "$DUMP" "$d/slang.uhdm" 2>/dev/null \
      | grep -oE '\\_ref_obj: \([^)]*\(.*' | sed 's/, id:[0-9]*//' | sort -u \
      | sed "s#^#CELL $d #"
  else
    echo "CLEAN $d"
  fi
}
export -f scan_one
export DUMP

find "$WD" -name cmds.txt | sort | xargs -P "$J" -I{} bash -c 'scan_one "$@"' _ {} > "$OUT.raw"
sort "$OUT.raw" > "$OUT"
echo "-- databases scanned: $(grep -c '^HIT\|^CLEAN' "$OUT"; true)"
echo "-- databases MISSING: $(grep -c '^NODB' "$OUT"; true)"
echo "-- row-modes HIT    : $(grep -c '^HIT' "$OUT"; true)"
echo "-- cells (distinct) : $(grep -c '^CELL' "$OUT"; true)"
grep '^HIT' "$OUT" | awk '{print "   PREDICTED MOVER: " $3 "  cells=" $2}'; true

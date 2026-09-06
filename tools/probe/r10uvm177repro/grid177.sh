#!/usr/bin/env bash
# r10uvm177repro/grid177.sh — the grid driver.  MEASUREMENT ONLY; the official
# ~/git-repos/UHDM/build/bin/uhdm-cmp is the sole judge.  Descended from
# r10uvm174repro/grid174.sh.
#   grid177.sh <file.sv> <binA:pristine> <binB:patched> <workdir>
#
# Builds the GOLDEN (Surelog) and BOTH binaries' databases in BOTH views,
# echoing every command WITH ITS BINARY PATH into <workdir>/cmds.txt and
# recording every rc — an rc=139 SEGFAULT must never read as a result
# (RESUME.md §9).  The per-view instrument is ct177cen (one row per FUNCTION
# RETURN position, keyed by listing x home x fn x span), so the three sides are
# directly line-comparable, and the OFFICIAL cmp is run on each view as the
# judge.
#
# NOTE ON VIEWS: `--elabuhdm` / `-elabuhdm` decide which listings the database
# carries.  BOTH views are built because the law IS a DEF/ELAB listing split
# and a single view cannot see it.
set -u
SV=$(readlink -f "$1"); A=$2; B=$3; W=$4
CEN=${CT177CEN:-/tmp/r10uvm177_ct177cen}
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
SL=$HOME/git-repos/Surelog/build/bin/surelog
[ -x "$CEN" ] || { echo "FATAL: no ct177cen at $CEN"; exit 3; }
[ -x "$CMP" ] || { echo "FATAL: no uhdm-cmp at $CMP"; exit 3; }
[ -x "$A" ] || { echo "FATAL: no binary A at $A"; exit 3; }
[ -x "$B" ] || { echo "FATAL: no binary B at $B"; exit 3; }
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib
mkdir -p "$W"; : > "$W/cmds.txt"
run() { echo "CMD $*" >> "$W/cmds.txt"; "$@" > /dev/null 2>&1 </dev/null; echo "rc=$? $*" >> "$W/cmds.txt"; }
for v in def elab; do
  EF=""; SF=""
  [ "$v" = elab ] && { EF="--elabuhdm"; SF="-elabuhdm"; }
  ( cd "$W" && run "$SL" -parse -nocache -nowritecache -noprecompiledcache -d coveruhdm $SF -o "$W/g_$v" "$SV" )
  run "$A" "$SV" $EF -o "$W/a_$v.uhdm"
  run "$B" "$SV" $EF -o "$W/b_$v.uhdm"
  G="$W/g_$v/slpp_all/surelog.uhdm"
  for pair in "$G:g.$v" "$W/a_$v.uhdm:a.$v" "$W/b_$v.uhdm:b.$v"; do
    f=${pair%%:*}; tg=${pair#*:}
    if [ -f "$f" ]; then
      "$CEN" "$f" 2>>"$W/cen.err" > "$W/cen.$tg.txt"
      echo "cen rc=$? $f" >> "$W/cmds.txt"
    else
      : > "$W/cen.$tg.txt"; echo "cen MISSING $f" >> "$W/cmds.txt"
    fi
  done
  for s in a b; do
    if [ -f "$G" ] && [ -f "$W/${s}_$v.uhdm" ]; then
      "$CMP" "$G" "$W/${s}_$v.uhdm" > "$W/cmp.$s.$v.txt" 2>&1
      echo "cmp rc=$? $s $v lines=$(wc -l < "$W/cmp.$s.$v.txt") heads=$(grep -c '^LHS:' "$W/cmp.$s.$v.txt" ; true)" >> "$W/cmds.txt"
    else
      echo "cmp SKIP-NOFILE $s $v" >> "$W/cmds.txt"
    fi
  done
done
echo "-- per-view RETURN-row counts (an arm whose golden lists NO return tests nothing):"
for t in g.def a.def b.def g.elab a.elab b.elab; do
  printf "   %-8s ROWS=%s\n" "$t" "$(($(wc -l < "$W/cen.$t.txt")-1))"
done
echo "-- Surelog units compiled (an arm that compiles to NOTHING reads green while testing nothing):"
grep -hoE 'Compile (package|class|module) "[^"]+"' "$W"/g_def/slpp_all/*.log 2>/dev/null | sort -u | head -40
echo "-- official cmp, LHS is ALWAYS golden:"
grep '^cmp ' "$W/cmds.txt"
echo "-- rc census:"; grep -c '^rc=0' "$W/cmds.txt"; grep -v '^rc=0' "$W/cmds.txt" | grep '^rc=' ; true

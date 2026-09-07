#!/usr/bin/env bash
# r10uvm185 GRID DRIVER — scores every arm cell on the field the law owns.
#
# MEASUREMENT ONLY.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#
#   usage: PRIS=<pristine> PATCHED=<patched> CEN=<ct185cen> \
#          ./ct185grid.sh [arm.sv ...]      (default: every grid185/*.sv)
#
# THE CELL is one `function` object, keyed on (vpiFullName, the function's START
# line:col, hasStmt) — the axes `ct185cen`'s header defends.  THE FIELD is the
# `Return` variable's VARIABLE CLASS, which is what `task_func::Compare`'s
# `Return` edge reads through `BaseClass::Compare`'s VpiType line.  The return
# variable's SPAN is printed but NOT scored: no generated Compare reads a line
# or a column, and this law deliberately does not move it (R1).
#
# Every cell is scored in BOTH VIEWS (`-parse` / `-elabuhdm` for Surelog, plain
# / `--elabuhdm` for ours), because the listing axis is where the neighbouring
# return-var laws split.
#
# VERDICTS, per cell:
#   TOWARD       pristine != golden, patched == golden
#   AWAY         pristine == golden, patched != golden        <- must be 0
#   MOVED-WRONG  pristine != golden, patched != golden, and the two differ
#                (the cell moved but not onto golden)          <- must be 0
#   STAY-BAD     pristine == patched != golden (not this law's cell)
#   AGREE        pristine == patched == golden
#   G-ONLY/O-ONLY a key on one side only (reported, never skipped)
#
# TRAPS ENCODED: Surelog synthesizes `builtin.sv` in the CWD, so each cell runs
# in its own scratch dir on the RELATIVE path; `uhdm-cmp` exits 0 on a MISSING
# input, so every file is guarded; `grep -c` with no match kills `set -e`, so
# every count is `; true`-guarded.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
PRIS=${PRIS:?set PRIS to the pristine binary}
PATCHED=${PATCHED:?set PATCHED to the patched binary}
CEN=${CEN:?set CEN to the ct185cen binary}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
STAGE=${STAGE:-/tmp/r10uvm185_grid}
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}:$HOME/.local/lib64:$HOME/.local/lib
ARMS=${*:-}
if [ -z "$ARMS" ]; then ARMS=$(cd "$HERE/grid185" && ls *.sv); fi
mkdir -p "$STAGE"
for a in $ARMS; do
  b=${a%.sv}
  for view in plain elab; do
    d="$STAGE/${b}_$view"
    rm -rf "$d"; mkdir -p "$d"
    cp "$HERE/grid185/$a" "$d/" || { echo "NO_ARM $a"; continue; }
    # Surelog needs the full no-cache set plus `-d coveruhdm` for the
    # ELABORATED view (grid170.sh's flag set, carried forward); `-parse` alone
    # writes no `slpp_all/surelog.uhdm` for `-elabuhdm`.
    case $view in
      plain) SLFLAG="";           OURFLAG="";;
      elab)  SLFLAG="-elabuhdm";  OURFLAG="--elabuhdm";;
    esac
    ( cd "$d" && "$SURELOG" -parse -nocache -nowritecache -noprecompiledcache \
        -d coveruhdm $SLFLAG "$a" >surelog.log 2>&1 </dev/null )
    ( cd "$d" && "$PRIS"    $OURFLAG "$a" -o pris.uhdm >pris.log 2>&1 </dev/null )
    ( cd "$d" && "$PATCHED" $OURFLAG "$a" -o pat.uhdm  >pat.log  2>&1 </dev/null )
    g="$d/slpp_all/surelog.uhdm"
    if [ ! -f "$g" ] || [ ! -f "$d/pris.uhdm" ] || [ ! -f "$d/pat.uhdm" ]; then
      echo "== $b/$view  SKIP (g=$( [ -f "$g" ] && echo y || echo n)" \
           "pris=$( [ -f "$d/pris.uhdm" ] && echo y || echo n)" \
           "pat=$( [ -f "$d/pat.uhdm" ] && echo y || echo n))"
      continue
    fi
    "$CEN" "$g"           > "$d/g.tsv"
    "$CEN" "$d/pris.uhdm" > "$d/pris.tsv"
    "$CEN" "$d/pat.uhdm"  > "$d/pat.tsv"
    echo "== $b/$view"
    python3 "$HERE/score185.py" "$d/g.tsv" "$d/pris.tsv" "$d/pat.tsv"
  done
done

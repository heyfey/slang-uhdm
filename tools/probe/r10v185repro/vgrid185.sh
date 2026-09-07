#!/usr/bin/env bash
# r10v185 VERIFIER grid driver — this verifier's OWN arms, its OWN scratch.
#
# MEASUREMENT ONLY.  The official `uhdm-cmp` is the judge; this scores the ONE
# field the head's failing edge reads.  LHS is ALWAYS golden (Surelog); RHS is
# ALWAYS ours.  It reuses r10uvm185repro's `ct185cen` census probe and
# `score185.py` scorer unchanged (same cell, same field, same verdicts), so the
# verifier's arms and the pass's arms are scored by the SAME instrument.
#
#   usage: PRIS=<pristine> PATCHED=<patched> CEN=<ct185cen binary> \
#          [ARMS_DIR=<dir>] [STAGE=<dir>] ./vgrid185.sh [arm.sv ...]
#
# Build the census probe first (its own header says how):
#   g++ -O2 -std=c++17 ../r10uvm185repro/ct185cen.cpp -I ~/.local/include \
#       -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/<yours>
#
# TRAPS ENCODED: Surelog synthesizes `builtin.sv` in the CWD, so each cell runs
# in its own scratch dir; every child gets `</dev/null`; every arm's three rcs
# are recorded and printed, because `verify_golden.py` records an rc=139
# SEGFAULT as a REJECT wearing the last warning (RESUME.md §9).
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
ARMS_DIR=${ARMS_DIR:-$HERE/arms185v}
PRIS=${PRIS:?set PRIS to the pristine binary}
PATCHED=${PATCHED:?set PATCHED to the binary under test}
CEN=${CEN:?set CEN to the ct185cen binary}
SCORE=${SCORE:-$HERE/../r10uvm185repro/score185.py}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
STAGE=${STAGE:?set STAGE to your own scratch directory}
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}:$HOME/.local/lib64:$HOME/.local/lib
ARMS=${*:-}
if [ -z "$ARMS" ]; then ARMS=$(cd "$ARMS_DIR" && ls *.sv); fi
mkdir -p "$STAGE"
for a in $ARMS; do
  b=${a%.sv}
  for view in plain elab; do
    d="$STAGE/${b}_$view"
    rm -rf "$d"; mkdir -p "$d"
    cp "$ARMS_DIR/$a" "$d/" || { echo "NO_ARM $a"; continue; }
    case $view in
      plain) SLFLAG="";           OURFLAG="";;
      elab)  SLFLAG="-elabuhdm";  OURFLAG="--elabuhdm";;
    esac
    ( cd "$d" && "$SURELOG" -parse -nocache -nowritecache -noprecompiledcache \
        -d coveruhdm $SLFLAG "$a" >surelog.log 2>&1 </dev/null ); echo "SLRC=$? $b/$view" > "$d/rc.txt"
    ( cd "$d" && "$PRIS"    $OURFLAG "$a" -o pris.uhdm >pris.log 2>&1 </dev/null ); echo "PRISRC=$?" >> "$d/rc.txt"
    ( cd "$d" && "$PATCHED" $OURFLAG "$a" -o pat.uhdm  >pat.log  2>&1 </dev/null ); echo "PATRC=$?" >> "$d/rc.txt"
    g="$d/slpp_all/surelog.uhdm"
    if [ ! -f "$g" ] || [ ! -f "$d/pris.uhdm" ] || [ ! -f "$d/pat.uhdm" ]; then
      echo "== $b/$view  SKIP (g=$( [ -f "$g" ] && echo y || echo n)" \
           "pris=$( [ -f "$d/pris.uhdm" ] && echo y || echo n)" \
           "pat=$( [ -f "$d/pat.uhdm" ] && echo y || echo n)) $(cat "$d/rc.txt" | tr '\n' ' ')"
      continue
    fi
    "$CEN" "$g"           > "$d/g.tsv"
    "$CEN" "$d/pris.uhdm" > "$d/pris.tsv"
    "$CEN" "$d/pat.uhdm"  > "$d/pat.tsv"
    echo "== $b/$view  $(tr '\n' ' ' < "$d/rc.txt")"
    python3 "$SCORE" "$d/g.tsv" "$d/pris.tsv" "$d/pat.tsv"
  done
done

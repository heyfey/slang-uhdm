#!/usr/bin/env bash
# r10v177repro/vgrid177.sh — the VERIFIER's own grid driver.  MEASUREMENT ONLY;
# ~/git-repos/UHDM/build/bin/uhdm-cmp is the sole judge.
#
#   vgrid177.sh <file.sv> <binPRIS> <binPAT> <workdir>
#
# Independent of r10uvm177's grid177.sh: the per-cell instrument here is
# `retcen177v.py`, which reads `uhdm-dump` TEXT, so it shares no code with
# `ct177cen`.  Every command is echoed WITH ITS BINARY PATH into
# <workdir>/cmds.txt together with its rc — an rc=139 segfault must never read
# as a result (RESUME §9).  BOTH views are built: this law IS a listing split.
set -u
SV=$(readlink -f "$1"); A=$2; B=$3; W=$4
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
SL=$HOME/git-repos/Surelog/build/bin/surelog
CEN=$(dirname "$(readlink -f "$0")")/retcen177v.py
for x in "$CMP" "$SL" "$A" "$B"; do
  [ -x "$x" ] || { echo "FATAL: not executable: $x"; exit 3; }
done
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib
mkdir -p "$W"; : > "$W/cmds.txt"
run() { echo "CMD $*" >> "$W/cmds.txt"; "$@" > /dev/null 2>&1 </dev/null;
        echo "rc=$? $*" >> "$W/cmds.txt"; }
for v in def elab; do
  EF=""; SF=""
  [ "$v" = elab ] && { EF="--elabuhdm"; SF="-elabuhdm"; }
  mkdir -p "$W/sl_$v"
  ( cd "$W/sl_$v" && run "$SL" -parse -nocache -nowritecache \
        -noprecompiledcache -d coveruhdm $SF -o "$W/g_$v" "$SV" )
  run "$A" "$SV" $EF -o "$W/a_$v.uhdm"
  run "$B" "$SV" $EF -o "$W/b_$v.uhdm"
  G="$W/g_$v/slpp_all/surelog.uhdm"
  for pair in "$G:g.$v" "$W/a_$v.uhdm:a.$v" "$W/b_$v.uhdm:b.$v"; do
    f=${pair%%:*}; tg=${pair#*:}
    if [ -f "$f" ]; then
      python3 "$CEN" "$f" > "$W/cen.$tg.txt" 2>>"$W/cen.err"
      echo "cen rc=$? rows=$(wc -l < "$W/cen.$tg.txt") $f" >> "$W/cmds.txt"
    else
      : > "$W/cen.$tg.txt"; echo "cen MISSING $f" >> "$W/cmds.txt"
    fi
  done
  for s in a b; do
    if [ -f "$G" ] && [ -f "$W/${s}_$v.uhdm" ]; then
      "$CMP" "$G" "$W/${s}_$v.uhdm" > "$W/cmp.$s.$v.txt" 2>&1
      echo "cmp rc=$? $s $v lines=$(wc -l < "$W/cmp.$s.$v.txt") heads=$(grep -c '^LHS:' "$W/cmp.$s.$v.txt"; true)" >> "$W/cmds.txt"
    else
      echo "cmp SKIP-NOFILE $s $v" >> "$W/cmds.txt"
    fi
  done
done
echo "== $SV"
echo "-- Surelog compiled these units (an arm compiling to nothing tests nothing):"
grep -hoE 'Compile (package|class|module|interface|program) "[^"]+"' \
     "$W"/g_def/slpp_all/*.log 2>/dev/null | sort -u | head -40
echo "-- official cmp (LHS is ALWAYS golden):"; grep '^cmp ' "$W/cmds.txt"
echo "-- non-zero rcs:"; grep '^rc=' "$W/cmds.txt" | grep -v '^rc=0 ' ; true

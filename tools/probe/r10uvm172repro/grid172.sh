#!/usr/bin/env bash
# r10uvm172repro/grid172.sh — one arm, Surelog golden + both binaries, BOTH
# views, every rc recorded.  MEASUREMENT ONLY; the official uhdm-cmp is the
# only judge.  Descended from r10uvm171repro/grid171.sh.
#   grid172.sh <file.sv> <binA:pristine> <binB:patched> <workdir>
# The DEF and ELAB listings are kept in SEPARATE files and never merged
# (r10uvm166 §6 / r10v169's listcheck law).
set -u
SV=$(readlink -f "$1"); A=$2; B=$3; W=$4
LST=${CT172LIST:-/tmp/r10uvm172_ct172list}
SL=$HOME/git-repos/Surelog/build/bin/surelog
[ -x "$LST" ] || { echo "FATAL: no ct172list at $LST"; exit 3; }
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib
mkdir -p "$W"; : > "$W/cmds.txt"
run() { echo "CMD $*" >> "$W/cmds.txt"; "$@" > /dev/null 2>&1 </dev/null; echo "rc=$? $*" >> "$W/cmds.txt"; }
for v in def elab; do
  EF=""; SF=""
  [ "$v" = elab ] && { EF="--elabuhdm"; SF="-elabuhdm"; }
  ( cd "$W" && run "$SL" -parse -nocache -nowritecache -noprecompiledcache -d coveruhdm $SF -o "$W/g_$v" "$SV" )
  run "$A" "$SV" $EF -o "$W/a_$v.uhdm"
  run "$B" "$SV" $EF -o "$W/b_$v.uhdm"
  for pair in "g_$v/slpp_all/surelog.uhdm:g.$v" "a_$v.uhdm:a.$v" "b_$v.uhdm:b.$v"; do
    f=${pair%%:*}; tg=${pair#*:}
    if [ -f "$W/$f" ]; then
      "$LST" "$W/$f" 2>>"$W/list.err" > "$W/list.$tg.txt"
      echo "list rc=$? $f" >> "$W/cmds.txt"
    else
      : > "$W/list.$tg.txt"; echo "list MISSING $f" >> "$W/cmds.txt"
    fi
  done
done
echo "-- per-view row counts (an arm whose GOLDEN holds nothing tests nothing):"
for t in g.def a.def b.def g.elab a.elab b.elab; do
  printf "   %-8s %s\n" "$t" "$(wc -l < "$W/list.$t.txt")"
done
echo "-- Surelog units compiled:"
grep -hoE 'Compile (package|class|module) "[^"]+"' "$W"/g_def/slpp_all/*.log 2>/dev/null | sort -u | head -40
echo "-- rc census:"; grep -c '^rc=0' "$W/cmds.txt"; grep -v '^rc=0' "$W/cmds.txt" | grep '^rc=' ; true

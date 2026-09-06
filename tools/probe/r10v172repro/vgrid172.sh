#!/usr/bin/env bash
# r10v172repro/vgrid172.sh — the VERIFIER's arm runner.  One arm, Surelog
# golden + both binaries, BOTH views, every rc recorded, and the OFFICIAL
# uhdm-cmp run on each (golden, ours) pair.  MEASUREMENT ONLY; uhdm-cmp is the
# only judge.  Derived from r10uvm172repro/grid172.sh.
#   vgrid172.sh <file.sv> <binA:pristine> <binB:patched> <workdir>
# The DEF and ELAB listings are kept in SEPARATE files and never merged.
set -u
SV=$(readlink -f "$1"); A=$2; B=$3; W=$4
LST=${V172LIST:-/tmp/v172_ct172list}
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
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
  # the OFFICIAL judge, both binaries, this view
  for s in a b; do
    if [ -f "$W/g_$v/slpp_all/surelog.uhdm" ] && [ -f "$W/$s"_"$v.uhdm" ]; then
      "$CMP" "$W/g_$v/slpp_all/surelog.uhdm" "$W/$s"_"$v.uhdm" > "$W/cmp.$s.$v.out" 2> "$W/cmp.$s.$v.err"
      echo "cmp rc=$? $s $v" >> "$W/cmds.txt"
    fi
  done
done
echo "-- per-view row counts (an arm whose GOLDEN holds nothing tests nothing):"
for t in g.def a.def b.def g.elab a.elab b.elab; do
  printf "   %-8s %s\n" "$t" "$(wc -l < "$W/list.$t.txt")"
done
echo "-- official uhdm-cmp head lines (LHS=golden):"
for v in def elab; do for s in a b; do
  n=$(grep -c '^LHS:' "$W/cmp.$s.$v.err" 2>/dev/null; true)
  l=$(wc -l < "$W/cmp.$s.$v.err" 2>/dev/null || echo NA)
  printf "   %s %-4s heads=%s errlines=%s %s\n" "$s" "$v" "$n" "$l" \
    "$(grep -c 'Design compare done. Design are equivalent' "$W/cmp.$s.$v.out" 2>/dev/null; true)"
done; done
echo "-- rc census:"; grep -c '^rc=0' "$W/cmds.txt"; grep -v '^rc=0' "$W/cmds.txt" | grep '^rc=' ; true

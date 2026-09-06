#!/usr/bin/env bash
# r10uvm171repro/grid171.sh — the grid driver.  MEASUREMENT ONLY; the official
# ~/git-repos/UHDM/build/bin/uhdm-cmp is the sole judge.  Descended from
# r10uvm169repro/grid169.sh.
#   grid171.sh <file.sv> <binA:pristine> <binB:patched> <workdir>
#
# Builds the GOLDEN (Surelog) and BOTH binaries' databases in BOTH views,
# echoing every command WITH ITS BINARY PATH into <workdir>/cmds.txt and
# recording every rc — an rc=139 SEGFAULT must never read as a result
# (RESUME.md §9).  The DEF and ELAB listings are kept in SEPARATE files and the
# view is part of every row: merging the two views into one multiset
# manufactures phantom cells (r10uvm166 §6, r10v169's listcheck law).
#
# The per-view instrument is ct171pred (one database, one row per return-name
# select/method-receiver), so the three sides are directly line-comparable.
set -u
SV=$(readlink -f "$1"); A=$2; B=$3; W=$4
PRED=${CT171PRED:-/tmp/r10uvm171_ct171pred}
SL=$HOME/git-repos/Surelog/build/bin/surelog
[ -x "$PRED" ] || { echo "FATAL: no ct171pred at $PRED"; exit 3; }
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
      "$PRED" "$W/$f" 2>>"$W/pred.err" | sed "s/^/[$tg] /" > "$W/pred.$tg.txt"
      echo "pred rc=$? $f" >> "$W/cmds.txt"
    else
      : > "$W/pred.$tg.txt"; echo "pred MISSING $f" >> "$W/cmds.txt"
    fi
  done
done
echo "-- per-view candidate counts (an arm whose golden holds NOTHING tests nothing):"
for t in g.def a.def b.def g.elab a.elab b.elab; do
  printf "   %-8s %s\n" "$t" "$(grep -c 'BOUND\|BARE' "$W/pred.$t.txt" ; true)"
done
echo "-- Surelog units compiled (an arm that compiles to NOTHING reads green while testing nothing):"
grep -hoE 'Compile (package|class|module) "[^"]+"' "$W"/g_def/slpp_all/*.log 2>/dev/null | sort -u | head -40
echo "-- rc census:"; grep -c '^rc=0' "$W/cmds.txt"; grep -v '^rc=0' "$W/cmds.txt" | grep '^rc=' ; true

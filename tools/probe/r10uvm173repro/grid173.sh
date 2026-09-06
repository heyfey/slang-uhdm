#!/usr/bin/env bash
# r10uvm173repro/grid173.sh — the grid driver.  MEASUREMENT ONLY; the official
# ~/git-repos/UHDM/build/bin/uhdm-cmp is the sole judge.  Descended from
# r10uvm171repro/grid171.sh.
#   grid173.sh <file.sv> <binA:pristine> <binB:patched> <workdir>
#
# Builds the GOLDEN (Surelog) and BOTH binaries' databases in BOTH views,
# echoing every command WITH ITS BINARY PATH into <workdir>/cmds.txt and
# recording every rc — an rc=139 SEGFAULT must never read as a result
# (RESUME.md §9).  The per-view instrument is ct173bind (one row per BOUND
# call: the listing the CALL lives in -> the listing the CALLEE lives in), so
# the three sides are directly line-comparable, and the OFFICIAL cmp is run on
# each view as the judge.
#
# NOTE ON VIEWS: `--elabuhdm` / `-elabuhdm` decide which listings the database
# carries.  BOTH views are built because the law is a DEF/ELAB split and a
# single view cannot see it.
set -u
SV=$(readlink -f "$1"); A=$2; B=$3; W=$4
BIND=${CT173BIND:-/tmp/r10uvm173_scratch/ct173bind}
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
SL=$HOME/git-repos/Surelog/build/bin/surelog
[ -x "$BIND" ] || { echo "FATAL: no ct173bind at $BIND"; exit 3; }
[ -x "$CMP" ]  || { echo "FATAL: no uhdm-cmp at $CMP"; exit 3; }
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
      "$BIND" "$f" --rows 2>>"$W/bind.err" | sed "s/^/[$tg] /" > "$W/bind.$tg.txt"
      echo "bind rc=$? $f" >> "$W/cmds.txt"
    else
      : > "$W/bind.$tg.txt"; echo "bind MISSING $f" >> "$W/cmds.txt"
    fi
  done
  # THE JUDGE, per view, per binary.  A missing side must never read as a pass:
  # uhdm-cmp EXITS 0 on a missing input, so both files are existence-checked.
  for s in a b; do
    if [ -f "$G" ] && [ -f "$W/${s}_$v.uhdm" ]; then
      "$CMP" "$G" "$W/${s}_$v.uhdm" > "$W/cmp.$s.$v.txt" 2>&1
      echo "cmp rc=$? $s $v lines=$(wc -l < "$W/cmp.$s.$v.txt") heads=$(grep -c '^LHS:' "$W/cmp.$s.$v.txt" ; true)" >> "$W/cmds.txt"
    else
      echo "cmp SKIP-NOFILE $s $v" >> "$W/cmds.txt"
    fi
  done
done
echo "-- per-view BOUND-call counts (an arm whose golden binds NOTHING tests nothing):"
for t in g.def a.def b.def g.elab a.elab b.elab; do
  printf "   %-8s %s\n" "$t" "$(grep -c '^\[' "$W/bind.$t.txt" ; true)"
done
echo "-- Surelog units compiled (an arm that compiles to NOTHING reads green while testing nothing):"
grep -hoE 'Compile (package|class|module) "[^"]+"' "$W"/g_def/slpp_all/*.log 2>/dev/null | sort -u | head -40
echo "-- official cmp, LHS is ALWAYS golden:"
grep '^cmp ' "$W/cmds.txt"
echo "-- rc census:"; grep -c '^rc=0' "$W/cmds.txt"; grep -v '^rc=0' "$W/cmds.txt" | grep '^rc=' ; true

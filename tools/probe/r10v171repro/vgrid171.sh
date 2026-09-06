#!/usr/bin/env bash
# r10v171repro/vgrid171.sh — the VERIFIER's grid driver.  MEASUREMENT ONLY;
# the official ~/git-repos/UHDM/build/bin/uhdm-cmp is the sole judge.
#
#   vgrid171.sh <file.sv> <binA:pristine> <binB:patched> <workdir>
#
# Builds the Surelog GOLDEN and BOTH binaries' databases in BOTH views,
# echoes every command WITH ITS BINARY PATH into <workdir>/cmds.txt and
# records every rc (an rc=139 SEGFAULT must never read as a result,
# RESUME.md §9).  DEF and ELAB listings stay in SEPARATE files and the view is
# part of every row — merging the two views manufactures phantom cells.
#
# Scores TWO ways:
#   (a) ct171pred listing diff-lines vs golden, per view  (the law's cells)
#   (b) the OFFICIAL uhdm-cmp: cmp line count and '^LHS:' head count, per view
set -u
SV=$(readlink -f "$1"); A=$2; B=$3; W=$4
PRED=${CT171PRED:-/tmp/v171_ct171pred}
SL=$HOME/git-repos/Surelog/build/bin/surelog
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
[ -x "$PRED" ] || { echo "FATAL: no ct171pred at $PRED"; exit 3; }
[ -x "$CMP"  ] || { echo "FATAL: no uhdm-cmp at $CMP"; exit 3; }
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib
mkdir -p "$W"; : > "$W/cmds.txt"
run() { echo "CMD $*" >> "$W/cmds.txt"; "$@" > /dev/null 2>&1 </dev/null; echo "rc=$? $*" >> "$W/cmds.txt"; }
BN=$(basename "$SV")
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
      "$PRED" "$f" 2>>"$W/pred.err" | sed "s/^/[$tg] /" > "$W/pred.$tg.txt"
    else
      : > "$W/pred.$tg.txt"; echo "pred MISSING $f" >> "$W/cmds.txt"
    fi
  done
  # the official judge, per side (uhdm-cmp writes the head to STDERR)
  for side in a b; do
    if [ -f "$G" ] && [ -f "$W/${side}_$v.uhdm" ]; then
      "$CMP" "$G" "$W/${side}_$v.uhdm" > "$W/cmp.$side.$v.txt" 2> "$W/cmp.$side.$v.err"
      echo "rc=$? cmp $side $v" >> "$W/cmds.txt"
    else
      : > "$W/cmp.$side.$v.txt"; : > "$W/cmp.$side.$v.err"
    fi
  done
done
echo "== ARM $BN"
printf "%-6s %-7s %-7s %-7s | %-9s %-9s | %-9s %-9s\n" \
   VIEW gCELL aCELL bCELL A-DIFF B-DIFF A-CMP/HD B-CMP/HD
for v in def elab; do
  gc=$(grep -c 'BOUND\|BARE' "$W/pred.g.$v.txt" ; true)
  ac=$(grep -c 'BOUND\|BARE' "$W/pred.a.$v.txt" ; true)
  bc=$(grep -c 'BOUND\|BARE' "$W/pred.b.$v.txt" ; true)
  ad=$(diff <(sed 's/^\[[^]]*\] //' "$W/pred.g.$v.txt") <(sed 's/^\[[^]]*\] //' "$W/pred.a.$v.txt") | grep -c '^[<>]' ; true)
  bd=$(diff <(sed 's/^\[[^]]*\] //' "$W/pred.g.$v.txt") <(sed 's/^\[[^]]*\] //' "$W/pred.b.$v.txt") | grep -c '^[<>]' ; true)
  al=$(wc -l < "$W/cmp.a.$v.txt"); ah=$(grep -c '^LHS:' "$W/cmp.a.$v.err" ; true)
  bl=$(wc -l < "$W/cmp.b.$v.txt"); bh=$(grep -c '^LHS:' "$W/cmp.b.$v.err" ; true)
  printf "%-6s %-7s %-7s %-7s | %-9s %-9s | %-9s %-9s\n" \
     "$v" "$gc" "$ac" "$bc" "$ad" "$bd" "$al/$ah" "$bl/$bh"
done
echo "-- Surelog units compiled (an arm that compiles to NOTHING reads green while testing nothing):"
grep -hoE 'Compile (package|class|module|interface) "[^"]+"' "$W"/g_def/slpp_all/*.log 2>/dev/null | sort -u | head -40
echo "-- rc census: rc=0 count $(grep -c '^rc=0' "$W/cmds.txt" ; true)"
grep '^rc=' "$W/cmds.txt" | grep -v '^rc=0' ; true
echo "-- binaries audited: A=$A B=$B"
grep -c "$A" "$W/cmds.txt" ; grep -c "$B" "$W/cmds.txt" ; true

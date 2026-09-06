#!/usr/bin/env bash
# r10v174repro/vgrid174.sh — the VERIFIER's independent arm driver.
# MEASUREMENT ONLY; the official ~/git-repos/UHDM/build/bin/uhdm-cmp is the judge.
#   vgrid174.sh <file.sv> <binA:pristine> <binB:patched> <workdir>
# Builds the Surelog GOLDEN and BOTH binaries in BOTH views, echoes every
# command WITH ITS BINARY PATH into <workdir>/cmds.txt, records EVERY rc
# (an rc=139 segfault must never read as a result), and runs the official cmp
# per view per binary with both inputs existence-checked (uhdm-cmp exits 0 on
# a missing input).  Scratch is keyed on the RELATIVE path of the arm.
set -u
SV=$(readlink -f "$1"); A=$2; B=$3; W=$4
CEN=${CT174CEN:-/tmp/v174_bin/ct174cen}
CMP=${UHDM_CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
SL=$HOME/git-repos/Surelog/build/bin/surelog
for t in "$CEN" "$CMP" "$SL" "$A" "$B"; do
  [ -x "$t" ] || { echo "FATAL: missing $t"; exit 3; }
done
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
echo "== $(basename "$SV")"
echo "-- per-view KEPT type-query counts (an arm keeping/folding nothing tests nothing):"
for t in g.def a.def b.def g.elab a.elab b.elab; do
  printf "   %-8s KEEP=%s CONST=%s\n" "$t" \
    "$(grep -c '^KEEP' "$W/cen.$t.txt" ; true)" "$(grep -c '^CONST' "$W/cen.$t.txt" ; true)"
done
echo "-- Surelog units compiled:"
grep -hoE 'Compile (package|class|module|interface|program) \"[^\"]+\"' "$W"/g_def/slpp_all/*.log 2>/dev/null | sort -u | head -40
echo "-- official cmp, LHS is ALWAYS golden:"
grep '^cmp ' "$W/cmds.txt"
echo "-- rc census: rc=0 count / any non-zero:"
grep -c '^rc=0' "$W/cmds.txt"; grep '^rc=' "$W/cmds.txt" | grep -v '^rc=0' ; true
echo "-- binaries seen in cmds.txt:"
grep -oE '(/tmp/v174_bin/[a-z]+\.bin|'"$HOME"'/git-repos/Surelog/build/bin/surelog)' "$W/cmds.txt" | sort | uniq -c

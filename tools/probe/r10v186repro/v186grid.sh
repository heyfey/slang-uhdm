#!/usr/bin/env bash
# r10v186repro/v186grid.sh — the VERIFIER's arm driver.  MEASUREMENT ONLY;
# the official `uhdm-cmp` is the sole judge.
#   CTV=<ct186v> CTN=<ct186new> v186grid.sh <file.sv> <pris.bin> <pat.bin> <workdir>
# Builds ONE REAL SURELOG GOLDEN and BOTH binaries' databases in BOTH views,
# echoes every command WITH ITS BINARY PATH into <workdir>/cmds.txt and records
# EVERY rc — an rc=139 SEGFAULT must never read as a result (RESUME §9).
# Runs TWO censuses per database: ct186new (the implementer's DIRECT-argument
# census) and ct186v (the verifier's WHOLE-WINDOW census, which also carries
# every NESTED face inside the `new[...]` argument list).
set -u
SV=$(readlink -f "$1"); A=$2; B=$3; W=$4
CTV=${CTV:?set CTV to the built ct186v}
CTN=${CTN:?set CTN to the built ct186new}
SL=$HOME/git-repos/Surelog/build/bin/surelog
CMP=${UHDM_CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
mkdir -p "$W"; : > "$W/cmds.txt"; : > "$W/md5.txt"
run() { echo "CMD $*" >> "$W/cmds.txt"; "$@" > /dev/null 2>&1; echo "rc=$? $*" >> "$W/cmds.txt"; }
for v in def elab; do
  EF=""; SF=""
  [ "$v" = elab ] && { EF="--elabuhdm"; SF="-elabuhdm"; }
  ( cd "$W" && run "$SL" -parse -nocache -nowritecache -noprecompiledcache -d coveruhdm $SF -o "$W/g_$v" "$SV" )
  run "$A" "$SV" $EF -o "$W/a_$v.uhdm"
  run "$B" "$SV" $EF -o "$W/b_$v.uhdm"
  for pair in "g_$v/slpp_all/surelog.uhdm:g.$v" "a_$v.uhdm:a.$v" "b_$v.uhdm:b.$v"; do
    f=${pair%%:*}; tag=${pair#*:}
    if [ -f "$W/$f" ]; then
      "$CTV" "$W/$f" > "$W/win.$tag.txt" 2>>"$W/cen.err"
      echo "ctv rc=$? $f rows=$(wc -l < "$W/win.$tag.txt")" >> "$W/cmds.txt"
      "$CTN" "$W/$f" > "$W/mfc.$tag.txt" 2>>"$W/cen.err"
      echo "ctn rc=$? $f rows=$(wc -l < "$W/mfc.$tag.txt")" >> "$W/cmds.txt"
      "$DUMP" "$W/$f" 2>/dev/null | sed -e "s#$W##g" -e 's#, id:[0-9]*##g' \
        -e 's#\bid:[0-9]*##g' > "$W/dump.$tag.txt"
      echo "dump rc=$? $f lines=$(wc -l < "$W/dump.$tag.txt")" >> "$W/cmds.txt"
    else
      : > "$W/win.$tag.txt"; : > "$W/mfc.$tag.txt"; : > "$W/dump.$tag.txt"
      echo "MISSING $f" >> "$W/cmds.txt"
    fi
  done
  for s in a b; do
    if [ -s "$W/g_$v/slpp_all/surelog.uhdm" ] && [ -s "$W/${s}_$v.uhdm" ]; then
      "$CMP" "$W/g_$v/slpp_all/surelog.uhdm" "$W/${s}_$v.uhdm" > "$W/cmp.$s.$v.txt" 2>&1
      echo "cmp rc=$? $s $v lines=$(wc -l < "$W/cmp.$s.$v.txt") heads=$(grep -c '^LHS:' "$W/cmp.$s.$v.txt"; true)" >> "$W/cmds.txt"
    else
      echo "cmp MISSING $s $v" >> "$W/cmds.txt"
    fi
  done
  for s in a b; do
    [ -f "$W/${s}_$v.uhdm" ] && md5sum "$W/${s}_$v.uhdm" >> "$W/md5.txt"
  done
  # the ORDER-BLIND whole-dump diff between the two binaries
  sort "$W/dump.a.$v.txt" > "$W/dump.a.$v.sorted"
  sort "$W/dump.b.$v.txt" > "$W/dump.b.$v.sorted"
  diff "$W/dump.a.$v.sorted" "$W/dump.b.$v.sorted" > "$W/obdiff.$v.txt"; true
done
echo "--- rcs:"; grep '^rc=' "$W/cmds.txt" | sort | uniq -c
echo "--- NONZERO rcs (must be empty):"; grep '^rc=' "$W/cmds.txt" | grep -v '^rc=0 ' ; true
echo "--- cmp:"; grep '^cmp ' "$W/cmds.txt"; true
echo "--- census rows:"; grep -E '^(ctv|ctn) ' "$W/cmds.txt"; true
for v in def elab; do
  echo "--- $v order-blind pris-vs-pat dump diff: $(grep -c '^[<>]' "$W/obdiff.$v.txt"; true) lines, of which vpiActual: $(grep -c 'vpiActual' "$W/obdiff.$v.txt"; true)"
done
echo "--- byte identity a vs b (per view):"
for v in def elab; do
  if [ -f "$W/a_$v.uhdm" ] && [ -f "$W/b_$v.uhdm" ]; then
    if cmp -s "$W/a_$v.uhdm" "$W/b_$v.uhdm"; then echo "$v IDENTICAL"; else echo "$v DIFFER"; fi
  fi
done

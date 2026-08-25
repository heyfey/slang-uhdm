#!/usr/bin/env bash
# r10uvm150 — run the call-chain census over the NINE UVM databases (five row
# families x both modes, minus Scoreboard/testflags which SLANG-REJECTS) for
# GOLDEN, PRISTINE and PATCHED, and join the three multisets per site.
# GOLDEN-VS-GOLDEN IS CALIBRATED FIRST: the same golden read twice must give a
# 0-row join.  usage: corpcen150.sh <pris-workdir> <pat-workdir> <outdir>
set -u
CEN=${CEN:?set CEN to the built ct150cen}
P=${1:?pris wd}; Q=${2:?pat wd}; O=${3:?out}; mkdir -p "$O"
for n in SeqDriver SimpleUVM Scoreboard MiniAmiq BuildUVMPkg; do
  for m in default testflags; do
    for d in "$P/$m/$n"-*/; do
      [ -d "$d" ] || continue
      [ -f "$d/slang.uhdm" ] || continue
      G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" | head -1)
      [ -n "$G" ] && [ -d "$G" ] || { echo "SKIP-NOGOLD $n/$m"; continue; }
      qd=$(echo "$Q/$m/$n"-*/); [ -f "$qd/slang.uhdm" ] || { echo "SKIP-NOPAT $n/$m"; continue; }
      "$CEN" "$G/golden.uhdm"  --all > "$O/$n.$m.g"  2>"$O/$n.$m.g.err"
      "$CEN" "$d/slang.uhdm"   --all > "$O/$n.$m.o"  2>"$O/$n.$m.o.err"
      "$CEN" "$qd/slang.uhdm"  --all > "$O/$n.$m.q"  2>"$O/$n.$m.q.err"
      echo "CENSUSED $n/$m g=$(wc -l < "$O/$n.$m.g") o=$(wc -l < "$O/$n.$m.o") q=$(wc -l < "$O/$n.$m.q")"
    done
  done
done

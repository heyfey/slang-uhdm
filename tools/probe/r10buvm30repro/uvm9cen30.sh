#!/usr/bin/env bash
# r10buvm30 — census the NINE UVM databases (the five UVM tests x both modes,
# minus the one with no golden) three ways: GOLDEN, our PRISTINE, our PATCHED.
#   PRISW=<pristine workdir>/sl  PATW=<patched workdir>/sl  OUT=<prefix> uvm9cen30.sh
set -u
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
AWKF="$HERE/negcen30.awk"
DUMP=${DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
PRISW=${PRISW:?}; PATW=${PATW:?}; OUT=${OUT:?}
: > "$OUT.golden.tsv"; : > "$OUT.pris.tsv"; : > "$OUT.pat.tsv"; : > "$OUT.dbs.txt"
n=0
for M in default testflags; do
  for T in BuildUVMPkg MiniAmiq Scoreboard SeqDriver SimpleUVM; do
    D=$(ls -d "$PRISW/$M/$T"-* 2>/dev/null | head -1); [ -n "$D" ] || continue
    G=$(grep -o 'golden cache hit [^)]*' "$D/cmds.txt" | sed 's/golden cache hit //')
    [ -n "$G" ] && [ -f "$G/golden.uhdm" ] || continue
    P=$(ls -d "$PATW/$M/$T"-* 2>/dev/null | head -1)
    n=$((n+1)); printf '%s\t%s\n' "$T" "$M" >> "$OUT.dbs.txt"
    "$DUMP" "$G/golden.uhdm" 2>/dev/null </dev/null | awk -v TEST="$T" -v MODE="$M" -f "$AWKF" >> "$OUT.golden.tsv"
    [ -f "$D/slang.uhdm" ] && "$DUMP" "$D/slang.uhdm" 2>/dev/null </dev/null | awk -v TEST="$T" -v MODE="$M" -f "$AWKF" >> "$OUT.pris.tsv"
    [ -n "$P" ] && [ -f "$P/slang.uhdm" ] && "$DUMP" "$P/slang.uhdm" 2>/dev/null </dev/null | awk -v TEST="$T" -v MODE="$M" -f "$AWKF" >> "$OUT.pat.tsv"
  done
done
echo "DATABASES=$n"
wc -l "$OUT.golden.tsv" "$OUT.pris.tsv" "$OUT.pat.tsv"

#!/usr/bin/env bash
# r11u27: run the CELL TRACE on one surelog-suite row, in its OWN source dir
# (the directory holding the row's `<Name>.sl`), with the sweep's exact
# command line, and summarise the law's reach.  Both traces are computed
# OUTSIDE the A/B switch, so the pristine binary prints the same rows.
set -u
BIN=${BIN:-/tmp/r11u27_bin/law2.bin}
WD=${WD:-/tmp/r11u27_wdp/sl}
SLROOT=${SLROOT:-/home/heyfey/git-repos/Surelog}
for spec in "$@"; do
  mode=${spec%%/*}; row=${spec#*/}
  d=$(ls -d $WD/$mode/${row}-* 2>/dev/null | head -1)
  [ -n "$d" ] || { echo "$spec NOWD"; continue; }
  args=$(grep '^slang:' $d/cmds.txt | sed 's/^slang: *[^ ]* //; s# -o .*##')
  sl=$(find $SLROOT/tests $SLROOT/third_party/tests -maxdepth 3 -name "$row.sl" 2>/dev/null | head -1)
  [ -n "$sl" ] || { echo "$spec NOSL"; continue; }
  src=$(dirname "$sl")
  out=$(cd "$src" && R11U27_CELLDBG=1 timeout 900 $BIN $args -o /tmp/r11u27_tr.uhdm 2>&1 | grep -E '^R11U27(CELL|GEN)')
  printf '%s cells=%s bnd=%s enc=%s ct7=%s | gen=%s bvf0=%s genenc=%s genval=%s\n' \
    "$spec" \
    "$(printf '%s' "$out" | grep -c '^R11U27CELL'; true)" \
    "$(printf '%s' "$out" | grep '^R11U27CELL' | grep -c 'bnd=1'; true)" \
    "$(printf '%s' "$out" | grep '^R11U27CELL' | grep -c 'enc=1'; true)" \
    "$(printf '%s' "$out" | grep '^R11U27CELL' | grep -c 'ct=7'; true)" \
    "$(printf '%s' "$out" | grep -c '^R11U27GEN'; true)" \
    "$(printf '%s' "$out" | grep '^R11U27GEN' | grep -c 'bvf=0'; true)" \
    "$(printf '%s' "$out" | grep '^R11U27GEN' | grep -c 'enc=1'; true)" \
    "$(printf '%s' "$out" | grep '^R11U27GEN' | grep -c 'val=1'; true)"
done

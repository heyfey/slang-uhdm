#!/usr/bin/env bash
# r11u27: run the CELL TRACE over one corpus test dir, with the sweep's own
# slang command line, and summarise the law's reach.
set -u
BIN=${BIN:-/tmp/r11u27_bin/law.bin}
WD=${WD:-/tmp/r11u27_wdp/u2r}
CORPUS=${CORPUS:-/home/heyfey/git-repos/uhdm2rtlil/test}
for spec in "$@"; do
  mode=${spec%%/*}; row=${spec#*/}
  d=$(ls -d $WD/$mode/${row}-* 2>/dev/null | head -1)
  [ -n "$d" ] || { echo "$spec NOWD"; continue; }
  args=$(grep '^slang:' $d/cmds.txt | sed 's/^slang: *[^ ]* //; s# -o .*##')
  src=$CORPUS/$row
  [ -d "$src" ] || { echo "$spec NOSRC"; continue; }
  out=$(cd $src && R11U27_CELLDBG=1 $BIN $args -o /tmp/r11u27_tr.uhdm 2>&1 | grep R11U27CELL)
  n=$(printf '%s' "$out" | grep -c 'R11U27CELL'; true)
  e=$(printf '%s' "$out" | grep -c 'enc=1'; true)
  c7=$(printf '%s' "$out" | grep -c 'ct=7'; true)
  b=$(printf '%s' "$out" | grep -c 'bnd=1'; true)
  echo "$spec cells=$n bnd=$b enc=$e ct7=$c7"
done

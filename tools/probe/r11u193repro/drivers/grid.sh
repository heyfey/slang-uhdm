#!/bin/bash
# r11u193: judge every case dir under cases/<grids...> with two binaries (names in $R193_BIN), one line per case:
# `<case> <binA verdict> | <binB verdict>`.  usage: grid.sh <binA> <binB> <grid>...  (env.sh fence: refuses fenced paths)
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 3
A=$1; B=$2; shift 2
for g in "$@"; do for c in $(ls -d "$D/../cases/$g"/*/ 2>/dev/null); do c=${c%/}; n=$g/$(basename $c)
  ra=$(SLANG_UHDM=$R193_BIN/$A bash "$D/case.sh" "$c" /tmp/r11u193_grid/$A/$n 2>&1 | sed 's/ out=.*//')
  rb=$(SLANG_UHDM=$R193_BIN/$B bash "$D/case.sh" "$c" /tmp/r11u193_grid/$B/$n 2>&1 | sed 's/ out=.*//')
  echo "$n | $A: $ra | $B: $rb"; done; done

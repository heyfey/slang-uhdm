#!/bin/bash
# r11u196: judge every case dir under the given grid dirs with two binaries (names in $R196_BIN), one line per case:
# `<case> | <binA verdict> | <binB verdict>`.  usage: grid.sh <binA> <binB> <grid dir>...  (EL=1: the elaborated view)
# env prefixes: ENVA / ENVB (e.g. ENVB="R11U196_OFF=1").  env.sh fence: refuses fenced paths.
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 3
A=$1; B=$2; shift 2
for g in "$@"; do g=$(cd "$g" && pwd); for c in $(find "$g" -name 'dut.sv' -o -name args -o -name files | xargs -n1 dirname | sort -u); do
  n=${c#$R196_REPO/tools/probe/}
  ra=$(env ${ENVA:-} SLANG_UHDM=$R196_BIN/$A bash "$D/case.sh" "$c" /tmp/r11u196_grid/$A${ENVA:+_x}${EL:+_el}/$n 2>&1 | sed 's/ out=.*//')
  rb=$(env ${ENVB:-} SLANG_UHDM=$R196_BIN/$B bash "$D/case.sh" "$c" /tmp/r11u196_grid/$B${ENVB:+_x}${EL:+_el}/$n 2>&1 | sed 's/ out=.*//')
  echo "$n | $A: $ra | $B: $rb"; done; done

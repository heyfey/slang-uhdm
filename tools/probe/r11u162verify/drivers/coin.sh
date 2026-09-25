#!/bin/bash
# coin.sh <wdA> <wdB> <corpus/mode/test-hash>...: order-blind, path-normalised uhdm-dump line diff of the two
# sweeps' databases (the UVM coin reads 0 or 4 lines, UINT / vpiDecompile).  Fail-closed on $FENCED.
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "coin.sh: export FENCED" >&2; exit 2; }
A=$1; B=$2; shift 2; fre=$(echo $FENCED | sed 's/ /|/g')
T=$(mktemp -d /tmp/r11u162_coin.XXXX)
for r in "$@"; do
  echo "$r" | grep -Eqw "$fre" && { echo "$r FENCED-SKIP"; continue; }
  $UHDM_DUMP $A/$r/slang.uhdm 2>/dev/null | sed -E 's#/tmp/r11u162_sw[A-Z]/##g; s#id:[0-9]+##g' | sort > $T/a
  $UHDM_DUMP $B/$r/slang.uhdm 2>/dev/null | sed -E 's#/tmp/r11u162_sw[A-Z]/##g; s#id:[0-9]+##g' | sort > $T/b
  n=$(diff $T/a $T/b | grep -c '^[<>]')
  echo "$r orderblind_lines=$n $(diff $T/a $T/b | grep '^[<>]' | sed -E 's/^([<>]) *\|?([A-Za-z]+):.*/\1\2/' | sort | uniq -c | tr '\n' ' ')"
done
rm -rf $T

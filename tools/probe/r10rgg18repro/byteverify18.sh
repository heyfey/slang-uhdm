#!/usr/bin/env bash
# r10rgg18repro/byteverify18.sh — byte-compare every `slang.uhdm` of two
# verify_golden workdirs, plus a SELFCHECK that the comparator can SEE a
# difference (SELFCHECK=1 flips one byte of a copy and expects a mover).
#   usage: byteverify18.sh <workdir_a> <workdir_b>
set -u
A=${1:?a}; B=${2:?b}
mv=0; same=0; only=0; sc_ok=0; sc_n=0
for mode in default testflags; do
  [ -d "$A/$mode" ] || continue
  for d in "$A/$mode"/*/; do
    n=$(basename "$d")
    fa="$d/slang.uhdm"; fb="$B/$mode/$n/slang.uhdm"
    if [ ! -f "$fa" ] || [ ! -f "$fb" ]; then only=$((only+1)); continue; fi
    if cmp -s "$fa" "$fb"; then same=$((same+1)); else mv=$((mv+1)); echo "MOVER $mode/$n"; fi
    if [ "${SELFCHECK:-0}" = 1 ]; then
      sc_n=$((sc_n+1))
      t=$(mktemp /tmp/r10rgg18_sc.XXXXXX)
      cp "$fa" "$t"; printf '\xff' | dd of="$t" bs=1 seek=64 conv=notrunc status=none
      cmp -s "$t" "$fa" || sc_ok=$((sc_ok+1))
      rm -f "$t"
    fi
  done
done
echo "-- MOVERS $mv / $((mv+same)) identical=$same missing-a-side=$only selfcheck=$sc_ok/$sc_n"

#!/usr/bin/env bash
# r11u88 CENSUS POSITIVE CONTROL — the same trace, the same binary, on the
# GRID, so the corpus zeros are readings and not a dead instrument.
# usage: GRID=<dir> cen88grid.sh <binary>
set -u
BIN=${1:?binary}; GRID=${GRID:?set GRID}
printf '%-18s %5s %5s %5s %5s %5s %5s\n' arm NDA MINT FOLD NAME BOTH DECL
for a in $(ls -d $GRID/*/ | xargs -n1 basename | sort -V); do
  d=$GRID/$a; [ -f "$d/dut.sv" ] || continue
  err=$( cd $d && R11U88_CELLDBG=1 $BIN dut.sv --single-unit --nobuiltin \
           -o /dev/null 2>&1 >/dev/null )
  nda=$(printf '%s\n' "$err" | grep -c '^R11U88NDA '; true)
  mint=$(printf '%s\n' "$err" | grep -c '^R11U88NDA .* mint=1'; true)
  fold=$(printf '%s\n' "$err" | grep -c '^R11U88NDAFOLD'; true)
  nm=$(printf '%s\n' "$err" | grep -c '^R11U88NDAFOLD .* name=1'; true)
  both=$(printf '%s\n' "$err" | grep -c '^R11U88BOTH'; true)
  decl=$(printf '%s\n' "$err" | grep -c '^R11U88BOTH .*declined=1'; true)
  mnda=$(printf '%s\n' "$err" | grep -c '^R11U88MODNDA'; true)
  mstr=$(printf '%s\n' "$err" | grep -c '^R11U88MODNDA .* str=1'; true)
  [ "$nda$mint$fold$nm$both$decl$mnda$mstr" = "00000000" ] && continue
  printf '%-18s %5s %5s %5s %5s %5s %5s   MODNDA=%s/%s\n' \
    "$a" "$nda" "$mint" "$fold" "$nm" "$both" "$decl" "$mstr" "$mnda"
done

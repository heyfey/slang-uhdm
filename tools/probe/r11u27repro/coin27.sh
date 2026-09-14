#!/usr/bin/env bash
# r11u27: convict the surelog byte movers as the PROVEN UVM COIN — run the
# PRISTINE binary a SECOND time on the same row and show the same order-blind
# line-number-class delta reappears against its own first run.
set -u
BIN=${BIN:-/tmp/r11u27_bin/pris.bin}
WDP=${WDP:-/tmp/r11u27_wdp/sl}
SLROOT=${SLROOT:-/home/heyfey/git-repos/Surelog}
DUMP=${DUMP:-/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump}
T=${T:-/tmp/r11u27_coin}
mkdir -p $T
for spec in "$@"; do
  mode=${spec%%/*}; row=${spec#*/}
  d=$(ls -d $WDP/$mode/${row}-* 2>/dev/null | head -1)
  [ -n "$d" ] || { echo "$spec NOWD"; continue; }
  args=$(grep '^slang:' $d/cmds.txt | sed 's/^slang: *[^ ]* //; s# -o .*##')
  sl=$(find $SLROOT/tests $SLROOT/third_party/tests -maxdepth 3 -name "$row.sl" 2>/dev/null | head -1)
  [ -n "$sl" ] || { echo "$spec NOSL"; continue; }
  ( cd $(dirname "$sl") && timeout 900 $BIN $args -o $T/$row.$mode.second.uhdm >/dev/null 2>&1 )
  $DUMP $d/slang.uhdm 2>/dev/null | sed "s#$d/##g; s#, id:[0-9]*##g; s#[^ ]*\.uhdm#X.uhdm#g" | sort > $T/$row.$mode.first.norm
  $DUMP $T/$row.$mode.second.uhdm 2>/dev/null | sed "s#$T/##g; s#, id:[0-9]*##g; s#[^ ]*\.uhdm#X.uhdm#g" | sort > $T/$row.$mode.second.norm
  n=$(diff $T/$row.$mode.first.norm $T/$row.$mode.second.norm | grep -c '^[<>]'; true)
  h=$(md5sum $T/$row.$mode.second.uhdm | cut -c1-12)
  echo "$spec PRISTINE-vs-PRISTINE order-blind delta=$n second_md5=$h"
  diff $T/$row.$mode.first.norm $T/$row.$mode.second.norm | grep '^[<>]' | head -4
done

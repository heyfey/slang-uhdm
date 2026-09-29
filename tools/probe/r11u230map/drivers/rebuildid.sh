#!/bin/bash
# r11u222map (map 13 driver, paths from env.sh): the rebuild-identity control (pass 206's R1: law queueTwinKeepsElem204v's orphan clone part with an
# uninitialised value). Every binary in $BINS runs r11u196repro/cases/V191/qr01 (and the other listed cases) $N
# times with the probe command line; per binary: distinct md5s; across binaries: md5, raw uhdm-dump identity (paths
# normalised) and the first differing byte offset.  usage: rebuildid.sh <out dir> <case dir>...
. "$(dirname "$0")/env.sh"
O=$1; shift; mkdir -p $O; N=${N:-3}
[ -x "$UHDM_DUMP" ] || { echo "rebuildid.sh: UHDM_DUMP not executable" >&2; exit 2; }
BINS=${BINS:-"slang-uhdm slang-uhdm.rebuild2"}
for c in "$@"; do
  echo "$c" | grep -Pq "$FENCERE" && { echo "FENCED refused"; continue; }
  t=$(echo $c | tr '/' '_'); echo "== $c"
  for b in $BINS; do
    [ -x "$B/$b" ] || { echo "rebuildid.sh: $B/$b not executable" >&2; exit 2; }
    hs=""
    for i in $(seq 1 $N); do o=$O/${t}_${b}_$i.uhdm; rm -f $o; (cd $REPO/$c && $B/$b dut.sv --single-unit --nobuiltin -o $o > /dev/null 2>&1); hs="$hs $(md5sum < $o | cut -c1-12)"; done
    $UHDM_DUMP $O/${t}_${b}_1.uhdm 2>/dev/null | sed "s#$O/${t}_${b}_1.uhdm#DB#g" > $O/${t}_${b}.dump
    echo "  $b md5(bin)=$(md5sum < $B/$b | cut -c1-12) runs:$hs"
  done
  set -- $BINS; ref=$1
  for b in $BINS; do
    [ $b = $ref ] && continue
    if cmp -s $O/${t}_${ref}_1.uhdm $O/${t}_${b}_1.uhdm; then bs=IDENTICAL; else bs="DIFFER at byte $(cmp $O/${t}_${ref}_1.uhdm $O/${t}_${b}_1.uhdm | awk '{print $5}' | tr -d ,)"; fi
    dd=$(diff $O/${t}_${ref}.dump $O/${t}_${b}.dump | grep -c '^[<>]')
    echo "  $ref vs $b: bytes $bs; dump lines differing $dd"
  done
done

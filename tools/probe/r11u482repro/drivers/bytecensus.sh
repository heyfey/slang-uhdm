#!/bin/bash
# bytecensus.sh <listfile> <outfile> <binA> <binB>: for each case DIRECTORY in <listfile>, run both
# binaries (dut.sv --single-unit --nobuiltin, every other .sv of the dir is not passed) and print
# "<dir> rcA rcB md5A md5B SAME|MOVED".  Outputs under /tmp/r11u482_bc/<full path>.  3 jobs.
L=$1; O=$2; A=$3; B=$4
[ -x "$A" ] && [ -x "$B" ] || { echo "binaries?"; exit 1; }
one() {
  c=$1; A=$2; B=$3
  [ -d "$c" ] || { echo "$c skip"; return; }
  W=/tmp/r11u482_bc$c; mkdir -p "$W"
  rm -f "$W/a.uhdm" "$W/b.uhdm"
  (cd "$c" && timeout 120 "$A" dut.sv --single-unit --nobuiltin -o "$W/a.uhdm" >/dev/null 2>&1 </dev/null); ra=$?
  (cd "$c" && timeout 120 "$B" dut.sv --single-unit --nobuiltin -o "$W/b.uhdm" >/dev/null 2>&1 </dev/null); rb=$?
  ma=$(md5sum < "$W/a.uhdm" 2>/dev/null | cut -c1-12); mb=$(md5sum < "$W/b.uhdm" 2>/dev/null | cut -c1-12)
  s=SAME; [ "$ma" != "$mb" -o "$ra" != "$rb" ] && s=MOVED
  echo "$c $ra $rb $ma $mb $s"
}
export -f one
xargs -a "$L" -P 3 -I{} bash -c 'one "$@"' _ {} "$A" "$B" > "$O"

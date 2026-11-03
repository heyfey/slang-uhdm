#!/bin/bash
# away.sh <pristine> <law> <listfile> <out>: for every case dir in <listfile> (absolute paths, fence-filtered
# by the caller), run both binaries (ours only, FILES list honoured) and print rc + md5 per binary
P=$1; L=$2; LST=$3; OUT=$4
[ -x "$P" ] && [ -x "$L" ] || { echo "missing binary"; exit 1; }
one(){ c=$1; k=$(echo "$c" | md5sum | cut -c1-12); F=dut.sv; [ -f "$c/FILES" ] && F=$(cat "$c/FILES")
  r=""; for B in $P $L; do o=/tmp/r11u474_away_$k.uhdm; rm -f $o; (cd "$c" && timeout 300 $B $F --single-unit --nobuiltin -o $o >/dev/null 2>&1 </dev/null); rc=$?; r="$r $rc:$(md5sum < $o 2>/dev/null | cut -c1-8)"; rm -f $o; done; echo "$c$r"; }
export -f one; export P L
xargs -a "$LST" -P 3 -I{} bash -c 'one "$@"' _ {} > "$OUT"

#!/bin/bash
# swcheck.sh <pristine> <law> <dir>...: per case dir (dut.sv --single-unit --nobuiltin
# from the dir) md5 of pristine, the law, the law with R11U479_OFF, and the law with
# each law switch alone; prints which switch restores pristine's bytes.
A=$1; B=$2; shift 2
SW="R11U479_PKGVIFTD_OFF R11U479_VIFLOCALCOPY_OFF R11U479_VIFLOCALREFVAR_OFF R11U479_PARENCALLEE_OFF"
O=/tmp/r11u479_sw.uhdm
m(){ rm -f $O; (cd "$1" && env $2 "$3" dut.sv --single-unit --nobuiltin -o $O >/dev/null 2>&1 </dev/null); echo "$? $( [ -f $O ] && md5sum < $O | cut -c1-8)"; }
for d in "$@"; do
  p=$(m "$d" "" "$A"); l=$(m "$d" "" "$B"); off=$(m "$d" "R11U479_OFF=1" "$B")
  line="$d pristine=[$p] law=[$l] OFF=$([ "$off" = "$p" ] && echo pristine || echo DIFF)"
  for s in $SW; do x=$(m "$d" "$s=1" "$B"); [ "$x" != "$l" ] && line="$line ${s#R11U479_}:$([ "$x" = "$p" ] && echo restores || echo moves)"; done
  echo "$line"
done

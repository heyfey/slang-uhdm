#!/bin/bash
# lawsw.sh <law> <casedir>...: for each law switch, the dirs whose bytes move when that switch alone is set
L=$1; shift
[ -x "$L" ] || exit 1
for c in "$@"; do
  c=$(realpath "$c"); W=/tmp/r11u477_lsw$c; mkdir -p "$W"; rm -f "$W"/*.uhdm
  (cd "$c" && "$L" dut.sv --single-unit --nobuiltin -o "$W/on.uhdm" >/dev/null 2>&1 </dev/null)
  mv=""
  for sw in R11U477_PARENCALL_OFF R11U477_FILEPATH_OFF R11U477_ROOTFILE_OFF R11U477_CAADDLEAF_OFF; do
    (cd "$c" && env $sw=1 "$L" dut.sv --single-unit --nobuiltin -o "$W/$sw.uhdm" >/dev/null 2>&1 </dev/null)
    cmp -s "$W/on.uhdm" "$W/$sw.uhdm" || mv="$mv ${sw#R11U477_}"
  done
  echo "${c#*/cases/}:${mv:- none}"
done

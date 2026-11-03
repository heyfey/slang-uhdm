#!/bin/bash
# swcheck.sh <pristine> <law> <casedir>...: law binary under R11U477_OFF=1 vs pristine, bytes and rc per dir
P=$1; L=$2; shift 2
[ -x "$P" ] && [ -x "$L" ] || { echo "missing binary"; exit 1; }
for c in "$@"; do
  c=$(realpath "$c"); W=/tmp/r11u477_sw$c; mkdir -p "$W"; rm -f "$W/p.uhdm" "$W/o.uhdm"
  (cd "$c" && "$P" dut.sv --single-unit --nobuiltin -o "$W/p.uhdm" >/dev/null 2>&1 </dev/null); r1=$?
  (cd "$c" && R11U477_OFF=1 "$L" dut.sv --single-unit --nobuiltin -o "$W/o.uhdm" >/dev/null 2>&1 </dev/null); r2=$?
  cmp -s "$W/p.uhdm" "$W/o.uhdm" && s=same || s=DIFF
  echo "${c#*/cases/} rc=$r1/$r2 $s"
done

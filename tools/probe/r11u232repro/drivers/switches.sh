#!/bin/bash
# (r11u232) switches.sh <out file>: every case of cases/ in both views: pristine, the law binary, the law binary with
# R11U232_OFF (must write the pristine bytes) and with each law's own switch alone. One line per case-view:
# `<case> p=<md5> law=<md5> off=<md5> <SWITCH>=<md5> ...` plus the rc of every run. Needs drivers/env.sh ($B, $S).
set -u; HERE=$(cd "$(dirname "$0")" && pwd); cd "$HERE/.."
[ -n "${FENCED:-}" ] && [ -n "${B:-}" ] || { echo "switches.sh: source drivers/env.sh" >&2; exit 2; }
SW="R11U232_DEFAGGIMP_OFF R11U232_CAFORMALTS_OFF R11U232_NESTANNOT_OFF R11U232_OVRLEFTLOC_OFF R11U232_CLONERETMINT_OFF"
OUT=$1; : > $OUT
for v in 0 1; do for c in $(find cases -name dut.sv | sort | xargs -n1 dirname); do
  line="$c$([ $v = 1 ] && echo _el)"
  r=$(EL=$v bash drivers/case.sh $c p $B/pristine); line="$line p=$(echo $r | grep -o 'md5=[0-9a-f]*' | cut -d= -f2)/$(echo $r | grep -o 'rc=[0-9]*')"
  r=$(EL=$v bash drivers/case.sh $c law $B/law); line="$line law=$(echo $r | grep -o 'md5=[0-9a-f]*' | cut -d= -f2)/$(echo $r | grep -o 'rc=[0-9]*')"
  r=$(EL=$v bash drivers/case.sh $c off $B/law R11U232_OFF=1); line="$line off=$(echo $r | grep -o 'md5=[0-9a-f]*' | cut -d= -f2)/$(echo $r | grep -o 'rc=[0-9]*')"
  for s in $SW; do r=$(EL=$v bash drivers/case.sh $c sw_$s $B/law $s=1); line="$line $s=$(echo $r | grep -o 'md5=[0-9a-f]*' | cut -d= -f2)"; done
  echo "$line" >> $OUT
done; done

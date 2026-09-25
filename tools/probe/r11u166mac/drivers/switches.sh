#!/bin/bash
# switches.sh <pristine bin> <law bin> — per case: the law's bytes vs pristine, R11U166_OFF=1 vs pristine (must be
# identical), and which single switch brings the case back to pristine bytes / moves it off the law's bytes.
# Env as case.sh.  Prints: case | law!=pris | OFF==pris | switches whose run differs from the law's bytes.
set -u
here=$(cd "$(dirname "$0")" && pwd); cd "$here/../cases"
SW="R11U166_LINE_OFF R11U166_COL_OFF R11U166_ONELINE_OFF R11U166_FILE_OFF R11U166_INCL_OFF R11U166_INCL_REINC_OFF R11U166_COL_LIT_OFF R11U166_MACROCONN_OFF"
t=$(mktemp -d /tmp/r11u166_sw.XXXX)
find . -name dut.sv | sort | while read -r f; do
  d=$(dirname "$f")
  (cd "$d" && "$1" dut.sv --single-unit --nobuiltin -o "$t/p.uhdm" >/dev/null 2>&1)
  (cd "$d" && "$2" dut.sv --single-unit --nobuiltin -o "$t/l.uhdm" >/dev/null 2>&1)
  (cd "$d" && R11U166_OFF=1 "$2" dut.sv --single-unit --nobuiltin -o "$t/o.uhdm" >/dev/null 2>&1)
  mv=$(cmp -s "$t/p.uhdm" "$t/l.uhdm" && echo same || echo MOVED)
  off=$(cmp -s "$t/p.uhdm" "$t/o.uhdm" && echo pristine || echo DIFF)
  s=""
  for w in $SW; do
    rm -f "$t/s.uhdm"
    (cd "$d" && env "$w=1" "$2" dut.sv --single-unit --nobuiltin -o "$t/s.uhdm" >/dev/null 2>&1)
    cmp -s "$t/l.uhdm" "$t/s.uhdm" || s="$s ${w#R11U166_}"
  done
  echo "$d | law:$mv | OFF:$off |$s"
  rm -f "$t"/*.uhdm
done
rm -rf "$t"

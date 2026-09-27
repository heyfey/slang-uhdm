#!/bin/bash
# r11u183: pin one object of OUR database to its mint: gdb on the -g1 exporter, break on
# Serializer::Make<Type> with ignore <rank-1>, print the backtrace (frames in src/ only).
# usage: pin.sh <case dir> <Type as in Make<Type>, e.g. Logic_typespec> <rank>   (ONLY on r11u183 cases; never corpus)
set -u; D=$(cd "$1" && pwd); T=$2; R=$3; G1=${G1:-/tmp/r11u183_bin/slang-uhdm.g1}
case "$D" in /tmp/wt_r11u183/tools/probe/r11u183dec/cases/*|/tmp/r11u183_cases/*) ;; *) echo "pin.sh: only r11u183 cases" >&2; exit 3;; esac
cd "$D" && gdb -q -batch -ex 'set pagination off' -ex "break UHDM::Serializer::Make$T" -ex "ignore 1 $((R-1))" -ex run -ex 'bt 14' \
  --args "$G1" dut.sv --single-unit --nobuiltin -o /tmp/r11u183_pin_$$.uhdm 2>&1 | grep -E '^#' | sed -E 's/ \(.*\) at / at /' | grep -v 'Serializer::Make' | cut -c1-200
rm -f /tmp/r11u183_pin_$$.uhdm

#!/bin/bash
# switches.sh <pristine bin> <law bin> : per case, which switch settings reproduce pristine (P) or law (L) bytes.
# Every case is run from its own directory with its `files` list (default dut.sv); outputs under /tmp/r11u172_sw_*.
P=$1 L=$2; C=$(cd "$(dirname "$0")/../cases" && pwd); T=/tmp/r11u172_swt; mkdir -p $T
: "${FENCED:?FENCED unset}"
printf '%-34s %-6s %-6s %-6s %-6s %-6s %-6s\n' case ALLOFF VALUE FILE DEPTH SPAN none
for c in $C/*/*; do
  f=$( [ -f $c/files ] && cat $c/files || echo dut.sv ); k=$(echo $c | sed "s|$C/||; s|/|__|g")
  rm -f $T/p.uhdm; (cd $c && $P $f --single-unit --nobuiltin -o $T/p.uhdm >/dev/null 2>&1)
  rm -f $T/l.uhdm; (cd $c && $L $f --single-unit --nobuiltin -o $T/l.uhdm >/dev/null 2>&1)
  line="$(printf '%-34s' $k)"
  for sw in R11U172_OFF R11U172_VALUE_OFF R11U172_FILE_OFF R11U172_DEPTH_OFF R11U172_SPAN_OFF NONE; do
    rm -f $T/x.uhdm; (cd $c && env $sw=1 $L $f --single-unit --nobuiltin -o $T/x.uhdm >/dev/null 2>&1)
    if cmp -s $T/x.uhdm $T/l.uhdm && cmp -s $T/x.uhdm $T/p.uhdm; then r=P=L; elif cmp -s $T/x.uhdm $T/p.uhdm; then r=P; elif cmp -s $T/x.uhdm $T/l.uhdm; then r=L; else r=MIX; fi
    line="$line $(printf '%-6s' $r)"
  done
  echo "$line"
done

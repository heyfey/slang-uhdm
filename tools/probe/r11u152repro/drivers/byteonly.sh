#!/bin/bash
# byteonly.sh <case>...: attribute a probe case whose database moved while its verdict did not.
# Runs the law binary with each r11u152 switch on the case (check_probe's arguments) and names the
# switch whose drop restores the pristine binary's bytes; also prints the pristine and law verdicts.
D=$(cd $(dirname $0)/../../../.. && pwd)
P=${PRIS:-/tmp/r11u152_bin/pris.bin}; L=${LAW:-/tmp/r11u152_bin/law2.bin}
W=${W:-/tmp/r11u152_byteonly}; mkdir -p $W
SWS="R11U152_C3_OFF R11U152_GENLPOPTS_OFF R11U152_FOLDCHAIN_OFF R11U152_TPELEMPAT_OFF R11U152_PKGELEMPAT_OFF R11U152_ELEMALIAS_OFF R11U152_TPOVRSTRUCT_OFF R11U152_GENCASE_OFF R11U152_DLYREAL_OFF R11U152_CGINITEND_OFF R11U152_CLSVARINIT_OFF R11U152_CLSNESTNAME_OFF R11U152_CLSPANOFILE_OFF R11U152_PKGLEAFLOC_OFF"
for c in "$@"; do
  k=$(echo $c | tr / _); cd $D/tests/probe/$c
  rm -f $W/$k.p.uhdm; $P dut.sv --single-unit --nobuiltin -o $W/$k.p.uhdm > /dev/null 2>&1
  hit=""
  for sw in $SWS; do
    rm -f $W/$k.s.uhdm; env $sw=1 $L dut.sv --single-unit --nobuiltin -o $W/$k.s.uhdm > /dev/null 2>&1
    cmp -s $W/$k.p.uhdm $W/$k.s.uhdm && hit="$hit ${sw#R11U152_}"
  done
  echo "$c:${hit:- (no single switch)}"
done

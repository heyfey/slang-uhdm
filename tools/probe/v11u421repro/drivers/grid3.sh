#!/bin/bash
# grid3.sh <out> <case dirs...> : pristine, law, verified; OFF switches
OUT=$1; shift; : > $OUT; H=/tmp/v11u421_drv; B=/tmp/v11u421_bin
sw() { case $1 in VE|EX) echo R11U421_EXPECTACT_OFF=1;; VH|HS) echo R11U421_HPIPSSYSARG_OFF=1;; VP|PB) echo R11U421_PISYSBS_OFF=1 R11U421_BITSDEFNOFOLD_OFF=1;; VB|BF) echo R11U421_BITSDEFNOFOLD_OFF=1;; esac; }
m() { echo "$1" | sed 's/.*rc=\([0-9]*\).*md5=\([0-9a-f]*\).*/\1:\2/'; }
for c in "$@"; do g=$(basename $(dirname $c))
 up=$(cd $c && timeout 60 $HOME/.local/bin/slang dut.sv --single-unit -q >/dev/null 2>&1; echo $?)
 p=$(bash $H/case.sh $c $B/pristine.bin); l=$(bash $H/case.sh $c $B/law.bin); v=$(bash $H/case.sh $c $B/verified.bin)
 o=$(bash $H/case.sh $c $B/verified.bin R11U421_OFF=1)
 x=$(bash $H/case.sh $c $B/verified.bin R11V421_OFF=1)
 w=$(bash $H/case.sh $c $B/verified.bin $(sw $g))
 echo "$g/$(basename $c) | slang=$up | P ${p#* } | L ${l#* } | V ${v#* } | Ueq=$([ "$(m "$v")" = "$(m "$l")" ] && echo y || echo N) OFF=pris:$([ "$(m "$o")" = "$(m "$p")" ] && echo y || echo N) V_OFF=law:$([ "$(m "$x")" = "$(m "$l")" ] && echo y || echo N) own=pris:$([ "$(m "$w")" = "$(m "$p")" ] && echo y || echo N)" >> $OUT
done

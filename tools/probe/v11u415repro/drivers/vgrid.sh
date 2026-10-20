#!/bin/bash
# v11u415 vgrid.sh <out> <case>... : upstream slang rc, pristine, law (case.sh lines with rc), R11U415_OFF and the group's own switch -> pristine bytes+rc, and the trace firings
P=/tmp/v11u415_bin/pristine; F=${LAWBIN:-/tmp/v11u415_bin/law}; OUT=$1; shift
sw() { case $1 in VT) echo R11U415_THISCALLMEMBER_OFF;; VB) echo R11U415_BADCASTSIZE_OFF;;
  VL) echo R11U415_PKGLET_OFF;; VA) echo R11U415_LABELCALL_OFF;;
  VD) echo "R11U415_DISABLEHIER_OFF R11U415_DISABLEHIERTASK_OFF";; VX) echo R11U415_EXTERNCALL_OFF;; *) echo R11U415_OFF;; esac; }
m() { echo "$1" | sed 's/.*rc=\([0-9]*\).*dmd5=\([0-9a-f]*\) sz=\([0-9]*\).*/\1:\2:\3/'; }
for c in "$@"; do c=$(readlink -f $c); g=$(basename $(dirname $c))
 TL=""; [ -f $c/TOP ] && TL="--top $(cat $c/TOP)"
 (cd $c && ~/.local/bin/slang dut.sv $TL --single-unit >/dev/null 2>&1); us=$?
 p=$(bash /tmp/v11u415_drv/case.sh $c $P)
 T=/tmp/v11u415_scr/tr_$(basename $c); rm -rf $T; mkdir -p $T
 f=$(bash /tmp/v11u415_drv/case.sh $c $F R11U415_TRACE=$T)
 tr=$(cat $T/* 2>/dev/null | sed 's/\t.*//' | awk '{print $NF}' | sort | uniq -c | tr -s ' ' | tr '\n' ';')
 o=$(bash /tmp/v11u415_drv/case.sh $c $F R11U415_OFF=1)
 env=""; for s in $(sw $g); do env="$env $s=1"; done
 w=$(bash /tmp/v11u415_drv/case.sh $c $F $env)
 # byte comparison pristine vs OFF: compare the dumps (outputs embed path)
 echo "$g/$(basename $c) upstream=$us | P ${p#* } | F ${f#* } | OFF=pris:$([ "$(m "$o")" = "$(m "$p")" ] && echo y || echo N) own=pris:$([ "$(m "$w")" = "$(m "$p")" ] && echo y || echo N) | trace: $tr" >> $OUT
done

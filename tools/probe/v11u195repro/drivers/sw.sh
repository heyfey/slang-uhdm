#!/bin/bash
# sw.sh <case dir>...: md5 of ours for law, fix, and fix with each refinement switch; prints L (=law) F (=fix) or * (neither)
. "$(dirname "$(realpath "$0")")"/env.sh
SW="R11V195_EVALOPND_OFF R11V195_EVALTERN_OFF R11V195_EVALRET_OFF R11V195_EVALVISIT_OFF R11V195_FCPSCOPE_OFF R11V195_FCPPOS_OFF"
for c in "$@"; do k=$(echo $c | md5sum | cut -c1-10); o=/tmp/v11u195_sw/$k; mkdir -p $o
  D=$c; SRC=dut.sv; [ -f $D/args ] && SRC=$(cat $D/args)
  run(){ rm -f $o/$1.uhdm; ( cd $D && env $2 $VB/$3 $SRC --single-unit --nobuiltin -o $o/$1.uhdm >/dev/null 2>&1 ); md5sum < $o/$1.uhdm | cut -c1-8; }
  L=$(run law "X=1" law.bin); F=$(run fix "X=1" fix1.bin); line="$(echo $c | sed 's#.*/cases/##')"
  for s in $SW; do m=$(run s "$s=1" fix1.bin); t='*'; [ "$m" = "$F" ] && t=F; [ "$m" = "$L" ] && t=L; [ "$L" = "$F" ] && t='='; line="$line ${s#R11V195_}:$t"; done
  echo "$line"; done

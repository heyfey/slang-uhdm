#!/bin/bash
# drops109.sh: run the LAW binary with each r11u109 kill switch over every grid109 arm
# (GRIDS = dirs of <arm>/dut.sv); compare path-normalised dumps against LAW and PRISTINE.
LAW=${LAW:?law binary}; PRIS=${PRIS:?pristine binary}; OUT=${OUT:-/tmp/r11u109_drops}
GRIDS=${GRIDS:-$(dirname "$(readlink -f "$0")")/grid/f1 $(dirname "$(readlink -f "$0")")/grid/f5 $(dirname "$(readlink -f "$0")")/grid/hp}
D=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
norm(){ $D "$1" 2>/dev/null | tail -n +2 | sed -E 's#/tmp/[^ ,)]*##g'; }
for v in OFF TPUNP_OFF ANONNET_OFF HPVS_OFF VOIDCAST_OFF VOIDCASTB_OFF CASTBIN_OFF STAMPTYPE_OFF PKGCALLFLAT_OFF OPDIGITS_OFF BITSONE_OFF; do
  nl=0; np=0; lst=""
  for g in $GRIDS; do for a in $g/*/; do a=${a%/}
    w=$OUT/$(basename $g)_$(basename $a); mkdir -p $w
    ( cd $a && env R11U109_$v=1 timeout 300 $LAW dut.sv --single-unit --nobuiltin -o $w/v.uhdm > $w/v.log 2>&1 )
    [ -f $w/law.dump ] || ( cd $a && timeout 300 $LAW dut.sv --single-unit --nobuiltin -o $w/l.uhdm > /dev/null 2>&1; norm $w/l.uhdm > $w/law.dump )
    [ -f $w/pris.dump ] || ( cd $a && timeout 300 $PRIS dut.sv --single-unit --nobuiltin -o $w/p.uhdm > /dev/null 2>&1; norm $w/p.uhdm > $w/pris.dump )
    norm $w/v.uhdm > $w/v.dump
    cmp -s $w/v.dump $w/law.dump || { nl=$((nl+1)); lst="$lst $(basename $a)"; }
    cmp -s $w/v.dump $w/pris.dump || np=$((np+1))
  done; done
  echo "DROP $v  differs-from-LAW=$nl  differs-from-PRIS=$np  arms:$lst"
done

#!/bin/bash
# switches.sh <law-bin> <pristine-bin> <dirs...>: for each dir, md5 of pristine, law, law with
# R11U483_OFF, law with each law switch; prints which switch restores pristine bytes
L=$1; P=$2; shift 2
for c in "$@"; do
  W=/tmp/r11u483_sw$(realpath $c); mkdir -p $W
  run(){ rm -f $W/$1.uhdm; (cd $c && env $2 "$3" dut.sv --single-unit --nobuiltin -o $W/$1.uhdm >/dev/null 2>&1 </dev/null); echo "$?:$(md5sum < $W/$1.uhdm | cut -c1-8)"; }
  p=$(run p X483=1 $P); l=$(run l X483=1 $L); o=$(run o R11U483_OFF=1 $L)
  a=$(run a R11U483_CLSOVRHS_OFF=1 $L); b=$(run b R11U483_IFACEVALNET_OFF=1 $L)
  echo "$c pris=$p law=$l OFF=$([ $o = $p ] && echo pristine || echo DIFF) CLSOVRHS_OFF=$([ $a = $p ] && echo pristine || ([ $a = $l ] && echo law || echo other)) IFACEVALNET_OFF=$([ $b = $p ] && echo pristine || ([ $b = $l ] && echo law || echo other))"
done

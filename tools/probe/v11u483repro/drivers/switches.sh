#!/bin/bash
# switches.sh <casedir>...: which binary's bytes each switch setting of the verified binary gives
P=/tmp/v11u483_bin/pristine; L=/tmp/v11u483_bin/law; V=/tmp/v11u483_bin/ver
hh() { md5sum < "$1" | cut -c1-8; }
for c in "$@"; do
  ( cd "$c" || exit
  rm -f /tmp/v11u483_vs_*.uhdm
  run() { o=$1; shift; env "$@" dut.sv --single-unit --nobuiltin -o $o >/dev/null 2>&1; }
  run /tmp/v11u483_vs_p.uhdm $P; run /tmp/v11u483_vs_l.uhdm $L; run /tmp/v11u483_vs_v.uhdm $V; rv=$?
  run /tmp/v11u483_vs_vo.uhdm R11V483_OFF=1 $V
  run /tmp/v11u483_vs_uo.uhdm R11U483_OFF=1 $V
  run /tmp/v11u483_vs_d.uhdm R11V483_DEFPARAM_OFF=1 $V
  run /tmp/v11u483_vs_n.uhdm R11V483_NESTMOD_OFF=1 $V
  p=$(hh /tmp/v11u483_vs_p.uhdm); l=$(hh /tmp/v11u483_vs_l.uhdm); v=$(hh /tmp/v11u483_vs_v.uhdm)
  which() { x=$(hh $1); if [ $x = $p ]; then echo pris; elif [ $x = $l ]; then echo law; elif [ $x = $v ]; then echo ver; else echo other; fi; }
  echo "$c ver=$(which /tmp/v11u483_vs_v.uhdm) V_OFF=$(which /tmp/v11u483_vs_vo.uhdm) U_OFF=$(which /tmp/v11u483_vs_uo.uhdm) DEFPARAM_OFF=$(which /tmp/v11u483_vs_d.uhdm) NESTMOD_OFF=$(which /tmp/v11u483_vs_n.uhdm)" )
done
